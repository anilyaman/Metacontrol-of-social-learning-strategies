from scipy.integrate import odeint
from pylab import *
import numpy as np
from ddeint import ddeint

T = 100

def piStar(t):
    return 0.8

def piHat(t):
    return 0.1

ICarr = []
IWarr = []
Sarr = []

def system(Y, t, d):
    IC, IW, S = Y(t)
    ICd, IWd, Sd = Y(t-d)

    fic = (1-epsilon) * piStar(t) + epsilon * piHat(t)
    fiw = piHat(t)

    phi = IC * fic + IW * fiw 
    fs = phi
    
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
        start=t%d
        if t-d >= t%d:
            for i in np.arange(start, d, t):
                Icounter.append(i)
                if((1-epsilon)*ICarr[Icounter.index(i)-1] >= epsilon*ICarr[Icounter.index(i)-1]+IWarr[Icounter.index(i)-1]):
                    bS.append([1,0])
                else:
                    bS.append([0,1])   
                xbStar.append((1-epsilon)*ICarr[len(ICarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][0])
                xbHat.append(epsilon*ICarr[len(ICarr)-1]+IWarr[len(IWarr)-1] + Sarr[len(Sarr)-1] * bS[len(bS)-2][1])

        fs = bS[len(bS)-1][0] * piStar(t) + bS[len(bS)-1][1] * piHat(t)

    # zero delay:
    if d==0:
        if (1-epsilon)*ICd >= epsilon*ICd+IWd and t-d>0:
            fs = piStar(t)
            phi = IC * fic + IW * fiw + S * fs
        else:
            fs = piHat(t)
            phi = IC * fic + IW * fiw + S * fs

    f = np.array([IC * ( fic - phi ) + eta * IW,   \
         IW * ( fiw - phi) - eta * IW,   \
         S  * ( fs  - phi)])
    return f

# Initial conditions and parameters
IC0 = 0.2
IW0 = 0.6
S0 = 0.2
epsilon = 0.1
piS = 0.1
eta = epsilon

w0 = [IC0, IW0, S0]
g = lambda t : w0
tt = np.linspace(0,T,5000)
# tt = np.array([0,1,2,3,4,5,6,7,8,9,10])

fig,ax=subplots(1)

for d in [0, 5]:
    yy = ddeint(system,g,tt,fargs=(d,))
    if d==0:
        ax.plot(tt, yy[:,0],lw=2,label="IC delay = %.01f"%d)
        ax.plot(tt, yy[:,1],lw=2,label="IW delay = %.01f"%d)
        ax.plot(tt, yy[:,2],lw=2,label="S delay = %.01f"%d)
    else:
        ax.plot(tt, yy[:,2],lw=2,label="S delay = %.01f"%d)

legend()
show()

# export to file
# with open('sol.dat', 'w') as f:
    # # Print & save the solution.
    # for t1, w1 in zip(t, wsol):
        # print >> f, t1, w1[0], w1[1], w1[2]
