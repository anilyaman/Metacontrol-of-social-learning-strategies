from scipy.integrate import odeint
from pylab import *
import numpy as np
from ddeint import ddeint

T = 10

def piStar(t):
    return 0.8

def piHat(t):
    return 0.1

tmp = 0

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
    
    bS.append([0 0])
    xbStar.append((1-epsilon)*ICarr[0])
    xbHat.append(epsilon*ICarr[0]+IWarr[0])
    
    
    for i in np.arange(start, 5, t):
    start=t%d
    counter = start;start = 
    if((1-epsilon)*ICarr[len(bS)-d????] >= epsilon*ICarr[len(bS)-d????]+IWarr[len(bS)-d????])):
        bS.append([1 0])
     else:
        bS.append([0 1])   
     xbStar.append((1-epsilon)*ICarr[len(bS)-1] + Sarr[len(bS)-1] * bS[len(bS)-1,1])
     xbHat.append(epsilon*ICarr[len(bS)-1]+IWarr[len(bS)-1] + Sarr[len(bS)-1] * bS[len(bS)-1,2])
    
        
        
        
    

# zero delay:
#     if (1-epsilon)*ICd >= epsilon*ICd+IWd and t-d>0:
        # fs = piStar(t)
        # phi = IC * fic + IW * fiw + S * fs
    # else:
        # fs = piHat(t)
        # phi = IC * fic + IW * fiw + S * fs

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
# tt = np.linspace(0,T,10)
tt = np.array([0,1,2,3,4,5,6,7,8,9,10])
print(tt)

fig,ax=subplots(1)

for d in [5]:
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
