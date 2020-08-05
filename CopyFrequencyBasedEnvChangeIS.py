from scipy.integrate import odeint
import numpy as np

stoptime = 300.0


def piStar(t):
    if t < stoptime / 2:
        return 0.8
    else:
        return 0.1


def piHat(t):
    if t < stoptime / 2:
        return 0.1
    else:
        return 0.8


# Q += ((np.random.rand(3,3)-0.5)/0.5)*0.05
# Q[Q<0]=0
# Q[Q>1]=1
# Q = Q/Q.sum(axis=1)[:,None]

def system(w, t, p):
    IC, S = w
    fic, fs, eta = p

    if t < stoptime / 2:
        fic = (1 - epsilon) * piStar(t) + epsilon * piHat(t)
    else:
        fic = (1 - epsilon) * piHat(t) + epsilon * piStar(t)

    phi = IC * fic 
    fs = 0
    d = 1
    a = 1.3

    ICarr = []
    Sarr = []

    ICarr.append(IC)
    Sarr.append(S)

    xbStar = []
    xbHat = []
    bS = []

    bS.append([10e-8, 10e-8])
    xbStar.append((1 - epsilon) * ICarr[0])
    xbHat.append(epsilon * ICarr[0])
    if d != 0:
        if t - d >= t % d:
            for i in np.arange(t % d, t, d):
                if i <stoptime/2:
                  bS.append([xbStar[len(xbStar) - 1], xbHat[len(xbHat) - 1]])
                  xbStar.append((1 - epsilon) * ICarr[len(ICarr) - 1] + Sarr[len(Sarr) - 1] * bS[len(bS) - 2][0])
                  xbHat.append(epsilon * ICarr[len(ICarr) - 1] + Sarr[len(Sarr) - 1] * bS[len(bS) - 2][1])
                else:
                  bS.append([xbStar[len(xbStar) - 1], xbHat[len(xbHat) - 1]])
                  xbStar.append(epsilon * ICarr[len(ICarr) - 1] + Sarr[len(Sarr) - 1] * bS[len(bS) - 2][0])
                  xbHat.append((1 - epsilon) * ICarr[len(ICarr) - 1] + Sarr[len(Sarr) - 1] * bS[len(bS) - 2][1])

        xbStarPow = pow(bS[len(bS) - 1][0], a)
        xbHatPow = pow(bS[len(bS) - 1][1], a)
        print(xbStarPow)
        print(xbHatPow)
        xbSum = xbStarPow + xbHatPow
        fs = (xbStarPow * piStar(t) + xbHatPow * piHat(t)) / xbSum

    phi = IC * fic + S * fs

    Q = [[0.999, 0.0005], [0.0005, 0.999]]
    # Q = np.identity(n=3)
    # f = np.array([IC * (fic - phi) + eta * IW, \
    # IW * (fiw - phi) - eta * IW, \
    # S * (fs - phi)])

    # Q = np.transpose(Q)
    # sum_j Qij = 1

    f = np.array([(IC * fic * Q[0][0] + S * fs * Q[1][0]) - IC * phi, \
                  (IC * fic * Q[0][1] + S * fs * Q[1][1]) - S * phi])
    return f


# Initial conditions and parameters
IC0 = 0.5
S0 = 0.5
epsilon = 0.1
piBStar = 0.8
piBHat = 0.1
eta = epsilon

fic = (1 - epsilon) * piBStar + epsilon * piBHat
fs = fic

p = [fic, fs, eta]
w0 = [IC0, S0]

# ODE solver parameters
abserr = 1.0e-8
relerr = 1.0e-6
numpoints = 1000

t = [stoptime * float(i) / (numpoints - 1) for i in range(numpoints)]
# ODE solver.
wsol = odeint(system, w0, t, args=(p,),
              atol=abserr, rtol=relerr)

T = []
IC = []
S = []
I = []
for t1, w1 in zip(t, wsol):
    T.append(t1)
    IC.append(w1[0])
    S.append(w1[1])

# !pip install pylab
from pylab import figure, plot, xlabel, grid, legend, title, show
from matplotlib.font_manager import FontProperties

figure(1, figsize=(6, 4.5))

xlabel('t')
lw = 2

plot(t, IC, 'b', linewidth=lw)
plot(t, S, 'k', linewidth=lw)

legend((r'$IC$', r'$S$'), prop=FontProperties(size=16))
# title('test')
show()
