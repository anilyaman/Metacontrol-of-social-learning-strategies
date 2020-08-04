
from scipy.integrate import odeint
import numpy as np


T = 20
changeEnv = 1

def piStar(t):
    return 0.8

def piHat(t):
    return 0.1


def system(w, t, p):
    IC, IW, S = w
    fic, fiw, fs, eta = p

    fic = (1-epsilon) * piStar(t) + epsilon * piHat(t)
    fiw = piHat(t)

    phi = IC * fic + IW * fiw 
    fs = 0
    d=8
    
    ICarr = []
    IWarr = []
    Sarr = []


    ICarr.append(IC)
    IWarr.append(IW)
    Sarr.append(S)

    xbStar = [] 
    xbHat = [] 
    bS = []
    Icounter = [0]

    bS.append([0,0])
    xbStar.append((1-epsilon)*ICarr[0])
    xbHat.append(epsilon*ICarr[0]+IWarr[0])
    
    if d!=0:
        if t-d >= t%d:
            for i in np.arange(t%d, t, d):
                Icounter.append(i)
                if xbStar[len(xbStar)-1] >= xbHat[len(xbHat)-1]:
                    bS.append([1,0])
                else:
                    bS.append([0,1])  

                xbStar.append((1-epsilon)*ICarr[len(ICarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][0])
                xbHat.append(epsilon*ICarr[len(ICarr)-1] + IWarr[len(IWarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][1])

        #fs = bS[len(bS)-1][0] * piStar(t) + bS[len(bS)-1][1] * piHat(t)  #copy most common
        fs = S * (bS[len(bS)-1][0] * piStar(t) + bS[len(bS)-1][1] * piHat(t)) + IC*fic + IW*fiw #proportional copy
        
        
        
    phi = IC * fic + IW * fiw + S * fs

    # zero delay:
    #if d==0:
    #if (1-epsilon)*ICd >= epsilon*ICd+IWd and t-d>0:
    #  fs = piStar(t)
    #  phi = IC * fic + IW * fiw + S * fs
    #else:
    #  fs = piHat(t)
    #  phi = IC * fic + IW * fiw + S * fs

    f = np.array([IC * ( fic - phi ) + eta * IW,   \
         IW * ( fiw - phi) - eta * IW,   \
         S  * ( fs  - phi)])
    return f


# Initial conditions and parameters
IC0 = 0.01
IW0 = 0.01
S0 = 0.98
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
abserr = 1.0e-8
relerr = 1.0e-6
stoptime = 200.0
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


#!pip install pylab
from pylab import figure, plot, xlabel, grid, legend, title
from matplotlib.font_manager import FontProperties



figure(1, figsize=(6, 4.5))

xlabel('t')
lw = 2

plot(t, IC, 'b', linewidth=lw)
plot(t, IW, 'g', linewidth=lw)
plot(t, S, 'k', linewidth=lw)
plot(t, I, 'y', linewidth=lw)

legend((r'$IC$', r'$IW$', r'$S$', r'$I (=IC+IW)$'), prop=FontProperties(size=16))
# title('test')