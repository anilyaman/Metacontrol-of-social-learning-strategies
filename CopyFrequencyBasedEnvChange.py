from scipy.integrate import odeint
import numpy as np

def piStar(t):
    return 0.8

def piHat(t):
    return 0.1

# Q += ((np.random.rand(3,3)-0.5)/0.5)*0.05
# Q[Q<0]=0
# Q[Q>1]=1
# Q = Q/Q.sum(axis=1)[:,None]

def system(w, t, p):
    IC, IW, S = w
    fic, fiw, fs, eta = p

    fic = (1-epsilon) * piStar(t) + epsilon * piHat(t)
    fiw = piHat(t)

    phi = IC * fic + IW * fiw 
    fs = 0
    a=2
    
    ICarr = []
    IWarr = []
    Sarr = []

    ICarr.append(IC)
    IWarr.append(IW)
    Sarr.append(S)

    xbStar = [] 
    xbHat = [] 
    bS = []

    bS.append([10e-8,10e-8])
    xbStar.append((1-epsilon)*ICarr[0])
    xbHat.append(epsilon*ICarr[0]+IWarr[0])

    if d!=0:
        if t-d >= t%d:
            for i in np.arange(t%d, t, d):
                if i <= change:
                    bS.append([xbStar[len(xbStar)-1],xbHat[len(xbHat)-1]])
                    xbStar.append((1-epsilon)*ICarr[len(ICarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][0])
                    xbHat.append(epsilon*ICarr[len(ICarr)-1] + IWarr[len(IWarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][1])
                else:
                    
                    bS.append([xbStar[len(xbStar)-1],xbHat[len(xbHat)-1]])
                    xbStar.append((1-epsilon)*IWarr[len(IWarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][0])
                    xbHat.append(epsilon*IWarr[len(IWarr)-1] + ICarr[len(ICarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][1])
               
        xbStarPow = pow(bS[len(bS)-1][0],a)
        xbHatPow = pow(bS[len(bS)-1][1],a)
        xbSum = xbStarPow + xbHatPow
        fs = (xbStarPow * piStar(t) + xbHatPow * piHat(t)) / xbSum
        
    phi = IC * fic + IW * fiw + S * fs

    Q = [[0.95, 0, 0.05], [0, 0.95, 0.05],[0.025, 0.025, 0.95]]
    # Q = np.identity(n=3)

    # f = np.array([IC * (fic - phi) + eta * IW, \
                 # IW * (fiw - phi) - eta * IW, \
                # S * (fs - phi)])

    # Q = np.transpose(Q)
    #sum_j Qij = 1
    
    f = np.array([(IC*fic*Q[0][0] + IW*fiw*Q[1][0] + S*fs*Q[2][0]) - IC * phi + eta * IW,   \
                  (IC*fic*Q[0][1] + IW*fiw*Q[1][1] + S*fs*Q[2][1]) - IW*phi - eta * IW,   \
                  (IC*fic*Q[0][2] + IW*fiw*Q[1][2] + S*fs*Q[2][2]) - S*phi])
    return f

# Initial conditions and parameters
IC0 = 0.1
IW0 = 0.6
S0 = 0.3
epsilon = 0.1
piBStar = 0.8
piBHat = 0.1
eta = epsilon

fic = (1-epsilon) * piBStar + epsilon * piBHat
fiw = epsilon * piBHat 
fs = fic

p = [fic, fiw, fs, eta]
w0 = [IC0, IW0, S0]

# ODE solver parameters
d=10
change = 100.0
abserr = 1.0e-8
relerr = 1.0e-6
stoptime = change
numpoints = 1000

t = [stoptime * float(i) / (numpoints - 1) for i in range(numpoints)]
# ODE solver.
wsol = odeint(system, w0, t, args=(p,),
              atol=abserr, rtol=relerr)

T=[]
IC=[]
IW=[]
S=[]
I=[]

for t1, w1 in zip(t, wsol):
  T.append(t1)
  IC.append(w1[0])
  IW.append(w1[1])
  S.append(w1[2])
  I.append(w1[0] + w1[1])

IC02 = IW[len(IW)-1]
IW02 = IC[len(IC)-1]
S02 = S[len(S)-1]

w0 = np.array([IC02, IW02, S02])

t2=np.array(t)+change
wsol2 = odeint(system, w0, t2, args=(p,),
              atol=abserr, rtol=relerr)

T2=[]
IC2=[]
IW2=[]
S2=[]
I2=[]

for t1, w1 in zip(t2, wsol2):
  T2.append(t1)
  IC2.append(w1[0])
  IW2.append(w1[1])
  S2.append(w1[2])
  I2.append(w1[0] + w1[1])

#!pip install pylab
from pylab import figure, plot, xlabel, grid, legend, title, show
from matplotlib.font_manager import FontProperties

figure(1, figsize=(6, 4.5))

xlabel('t')
lw = 2

plot(t, IC, 'b', linewidth=lw)
plot(t, IW, 'g', linewidth=lw)
plot(t, S, 'k', linewidth=lw)
plot(t, I, 'y', linewidth=lw)
plot(t2, IC2, 'g', linewidth=lw)
plot(t2, IW2, 'b', linewidth=lw)
plot(t2, S2, 'k', linewidth=lw)
plot(t2, I2, 'y', linewidth=lw)


legend((r'$IC$', r'$IW$', r'$S$', r'$I (=IC+IW)$'), prop=FontProperties(size=16))
# title('test')
show()