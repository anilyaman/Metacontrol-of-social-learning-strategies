from scipy.integrate import odeint
import numpy as np
import math


# ODE solver parameters
abserr = 1.0e-9
relerr = 1.0e-7
numpoints = 1000
stoptime = 600.0

tt = [stoptime * float(i) / (numpoints - 1) for i in range(numpoints)]

piOpt = np.random.normal(0.8, 0.1, 10000)
piSOpt = np.random.normal(0.2, 0.1, 10000)



def piB1(t):
    if t < stoptime / 3 or t > 2*stoptime / 3:
        return piOpt[math.floor(t*10)]
    else:
        return piSOpt[math.floor(t*10)]


def piB2(t):
    if t < stoptime / 3 or t > 2*stoptime / 3:
        return piSOpt[math.floor(t*10)]
    else:
        return piOpt[math.floor(t*10)]


B1arr = []
B2arr = []
S1arr = []
S2arr = []
fS1arr = []
fS2arr = []
fB1arr = []
fB2arr = []
phiarr = []

Tarr = []

xB1 = []
xB2 = []
xSb1 = []
xSb2 = []



def system(w, t, p):
    B1, B2, S1, S2 = w
    eta = p

    fB1 = (1 - epsilon) * piB1(t) + epsilon * piB2(t)
    fB2 = (1 - epsilon) * piB2(t) + epsilon * piB1(t)


    d = 10
    a = 0.5

    B1arr.append(B1)
    B2arr.append(B2)
    S1arr.append(S1)
    S2arr.append(S2)

    fB1arr.append(fB1)
    fB2arr.append(fB2)
    Tarr.append(t)

    inx = 0
    if(t-d<=0):
        xSb1.append(0)
        xSb2.append(0)
    else:
        tempArr = np.abs(np.array(Tarr) - (t - d))
        tempArr = tempArr.tolist()
        inx = tempArr.index(min(tempArr))
        if(inx > len(xSb1)-1):
            inx = len(xSb1)-1
        xSb1.append(B1arr[inx] + S1arr[inx])
        xSb2.append(B2arr[inx] + S2arr[inx])
        xSb1norm = pow(xSb1[len(xSb1) - 1], a)
        xSb2norm = pow(xSb2[len(xSb2) - 1], a)
        xSb1[len(xSb1) - 1] = (xSb1norm / (xSb1norm + xSb2norm))
        xSb2[len(xSb2) - 1] = (xSb2norm / (xSb1norm + xSb2norm))

        #if(xSb1[len(xSb1) - 1] > xSb2[len(xSb2) - 1]):
        #    xSb1[len(xSb1) - 1] = a
        #    xSb2[len(xSb1) - 1] = (1-a)
        #else:
        #    xSb1[len(xSb1) - 1] = (1-a)
        #    xSb2[len(xSb1) - 1] = a
        #print([xSb1[len(xB1)-1], xSb2[len(xB2)-1]])





    fS1 = xSb1[len(xSb1)-1]  * piB1(t)
    fS1arr.append(fS1)
    fS2 = xSb2[len(xSb2)-1] * piB2(t)
    fS2arr.append(fS2)



    phi = B1 * fB1 + B2 * fB2 + S1 * fS1 + S2 * fS2
    phiarr.append(phi)

    #Q = [[0.998, 0, 0.001, 0.001], [0, 0.998, 0.001, 0.001], [0.0005, 0.0005, 0.999, 0], [0.0005, 0.0005, 0, 0.999]]
    Q = [[0.98, 0, 0.01, 0.01], [0, 0.98, 0.01, 0.01], [0.01, 0.01, 0.98, 0], [0.01, 0.01, 0, 0.98]]


    f = np.array([(B1 * fB1 * Q[0][0] + B2 * fB2 * Q[1][0] + S1 * fS1 * Q[2][0] + S2 * fS2 * Q[3][0]) - B1 * phi,
                  (B1 * fB1 * Q[0][1] + B2 * fB2 * Q[1][1] + S1 * fS1 * Q[2][1] + S2 * fS2 * Q[3][1]) - B2 * phi,
                  (B1 * fB1 * Q[0][2] + B2 * fB2 * Q[1][2] + S1 * fS1 * Q[2][2] + S2 * fS2 * Q[3][2]) - S1 * phi,
                 (B1 * fB1 * Q[0][3] + B2 * fB2 * Q[1][3] + S1 * fS1 * Q[2][3] + S2 * fS2 * Q[3][3]) - S2*phi])

    return f


# Initial conditions and parameters
B10 = 0.25
B20 = 0.25
S10 = 0.25
S20 = 0.25
epsilon = 0.1
piBStar = 0
piBHat = 0
eta = epsilon

fB1 = []
fB2 = []
fS1 = []
fS2 = []

p = [eta]
w0 = [B10, B20, S10, S20]

fS1arr.append(0)
fS2arr.append(0)

# ODE solver.
wsol = odeint(system, w0, tt, args=(p,),
              atol=abserr, rtol=relerr)

T = []
B1 = []
B2 = []
S1 = []
S2 = []
I = []
for t1, w1 in zip(tt, wsol):
    T.append(t1)
    B1.append(w1[0])
    B2.append(w1[1])
    S1.append(w1[2])
    S2.append(w1[3])

# !pip install pylab
from pylab import figure, plot, xlabel, grid, legend, title, show, subplot
from matplotlib.font_manager import FontProperties

figure(1, figsize=(6, 4.5))

#print(sum(evaluated))
for i in range(1,len(phiarr)-1, 1):
    if(phiarr[i] == 0 and phiarr[i-1] != 0):
        fB1arr[i] = fB1arr[i-1]
        fB2arr[i] = fB2arr[i-1]
        fS1arr[i] = fS1arr[i-1]
        fS2arr[i] = fS2arr[i-1]
        phiarr[i] = phiarr[i-1]

xlabel('t')
lw = 2
subplot(2,1,1)
#plot(tt, B1, 'b', linewidth=lw)
#plot(tt, B2, 'g', linewidth=lw)
#plot(tt, S1, 'k', linewidth=lw)
#plot(tt, S2, 'y', linewidth=lw)
plot(tt, np.array(B1)+np.array(B2), 'r', linewidth=lw)
plot(tt, np.array(S1)+np.array(S2), 'm', linewidth=lw)
#plot(np.array(B1)+np.array(B2), np.array(S1)+np.array(S2), 'm', linewidth=lw)
#legend((r'$B1$', r'$B2$', r'$S1$', r'$S2$', r'$IL$', r'$SL$'), prop=FontProperties(size=16))
legend(( r'$IL$', r'$SL$'), prop=FontProperties(size=16))


subplot(2,1,2)
plot(tt, B1, 'b', linewidth=lw)
plot(tt, B2, 'g', linewidth=lw)
plot(tt, S1, 'k', linewidth=lw)
plot(tt, S2, 'y', linewidth=lw)
legend((r'$B1$', r'$B2$', r'$S1$', r'$S2$'), prop=FontProperties(size=16))

#plot(fB1arr, 'b', linewidth=lw)
#plot(fB2arr, 'g', linewidth=lw)
#plot(fS1arr, 'k', linewidth=lw)
#plot(fS2arr, 'm', linewidth=lw)
#plot(phiarr, 'r', linewidth=lw)

legend((r'$fB1arr$', r'$fB2arr$', r'$fS1arr$',r'$fS2arr$', r'$phiarr$'), prop=FontProperties(size=16))
# title('test')
show()
