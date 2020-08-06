from scipy.integrate import odeint
import numpy as np
import math


# ODE solver parameters
abserr = 1.0e-8
relerr = 1.0e-6
numpoints = 200
stoptime = 300.0

tt = [stoptime * float(i) / (numpoints - 1) for i in range(numpoints)]


def piB1(t):
    if t < stoptime / 2:
        return 0.8
    else:
        return 0.2


def piB2(t):
    if t < stoptime / 2:
        return 0.2
    else:
        return 0.8


B1arr = np.zeros(len(tt))
B2arr = np.zeros(len(tt))
S1arr = np.zeros(len(tt))
S2arr = np.zeros(len(tt))
fS1arr = np.zeros(len(tt))
fS2arr = np.zeros(len(tt))
fB1arr = np.zeros(len(tt))
fB2arr = np.zeros(len(tt))
phiarr = np.zeros(len(tt))
evaluated = np.zeros(len(tt))




def system(w, t, p):
    B1, B2, S1, S2 = w
    eta = p

    fB1 = (1 - epsilon) * piB1(t) + epsilon * piB2(t)
    fB2 = (1 - epsilon) * piB2(t) + epsilon * piB1(t)


    d = 1
    a = 2

    tempArr = np.abs(np.array(tt) - t)
    tempArr = tempArr.tolist()
    inx = tempArr.index(min(tempArr))
    #if(tempArr[inx] > t):
    #    inx = inx - 1

    if(math.isnan(B1)):
        print(B1)

    B1arr[inx] = B1
    B2arr[inx] = B2
    S1arr[inx] = S1
    S2arr[inx] = S2

    fB1arr[inx] = fB1
    fB2arr[inx] = fB2

    xB1 = []
    xB2 = []
    xSb1 = []
    xSb2 = []

    xSb1.append(0)
    xSb2.append(0)
    for i in np.arange(inx%d, inx, d):
        #if Tarr[i] < stoptime/2:
        appInx = i
        if(math.isnan(B1arr[i])) or B1arr[i] == 0:
            for j in range(i-1,0,-1):
                if(not  math.isnan(B1arr[j]) and  B1arr[j]!=0):
                    appInx = j
                    break

        #xB1.append((1-epsilon) * B1arr[appInx] + epsilon * B2arr[appInx] + S1arr[appInx] * xSb1[len(xSb1) - 1])
        #xB2.append((1-epsilon) * B2arr[appInx] + epsilon * B1arr[appInx] + S2arr[appInx] * xSb2[len(xSb2) - 1])
        #xB1norm = pow(xB1[len(xB1) - 1], a)
        #xB2norm = pow(xB2[len(xB2) - 1], a)
        #xSb1.append((xB1norm / (xB1norm + xB2norm)))
        #xSb2.append((xB2norm / (xB1norm + xB2norm)))

        xB1.append((1-epsilon) * B1arr[appInx] + epsilon * B2arr[appInx] + S1arr[appInx] * xSb1[len(xSb1) - 1])
        xB2.append((1-epsilon) * B2arr[appInx] + epsilon * B1arr[appInx] + S2arr[appInx] * xSb2[len(xSb2) - 1])

        if(xB1[len(xB1) - 1] > xB2[len(xB2) - 1]):
            xSb1.append(1)
            xSb2.append(0)
        else:
            xSb1.append(0)
            xSb2.append(1)

    fS1 = xSb1[len(xSb1)-1] * piB1(t)
    fS1arr[inx] = fS1
    fS2 = xSb2[len(xSb2)-1] * piB2(t)
    fS2arr[inx] = fS2
    evaluated[inx] = 1



    phi = B1 * fB1 + B2 * fB2 + S1 * fS1 + S2 * fS2
    phiarr[inx] = phi

    Q = [[0.998, 0, 0.001, 0.001], [0, 0.998, 0.001, 0.001], [0.0005, 0.0005, 0.999, 0], [0.0005, 0.0005, 0, 0.999]]


    f = np.array([(B1 * fB1 * Q[0][0] + B2 * fB2 * Q[1][0] + S1 * fS1 * Q[2][0] + S2 * fS2 * Q[3][0]) - B1 * phi,
                  (B1 * fB1 * Q[0][1] + B2 * fB2 * Q[1][1] + S1 * fS1 * Q[2][1] + S2 * fS2 * Q[3][1]) - B2 * phi,
                  (B1 * fB1 * Q[0][2] + B2 * fB2 * Q[1][2] + S1 * fS1 * Q[2][2] + S2 * fS2 * Q[3][2]) - S1 * phi,
                 (B1 * fB1 * Q[0][3] + B2 * fB2 * Q[1][3] + S1 * fS1 * Q[2][3] + S2 * fS2 * Q[3][3]) - S2*phi])

    return f


# Initial conditions and parameters
B10 = 0.01
B20 = 0.01
S10 = 0.01
S20 = 0.01
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

print(sum(evaluated))
#for i in range(1,len(evaluated)-1, 1):
#    if(evaluated[i] == 0 and evaluated[i-1] == 1):
#        evaluated[i] = evaluated[i-1]
#        fB1arr[i] = fB1arr[i-1]
#        fB2arr[i] = fB2arr[i-1]
#        fS1arr[i] = fS1arr[i-1]
#        fS2arr[i] = fS2arr[i-1]
#        phiarr[i] = phiarr[i-1]

xlabel('t')
lw = 2
subplot(2,1,1)
plot(tt, B1, 'b', linewidth=lw)
plot(tt, B2, 'g', linewidth=lw)
plot(tt, S1, 'k', linewidth=lw)
plot(tt, S2, 'm', linewidth=lw)
legend((r'$B1$', r'$B2$', r'$S1$', r'$S2$'), prop=FontProperties(size=16))

subplot(2,1,2)
plot(tt,fB1arr, 'b', linewidth=lw)
plot(tt,fB2arr, 'g', linewidth=lw)
plot(tt,fS1arr, 'k', linewidth=lw)
plot(tt,fS2arr, 'm', linewidth=lw)
plot(tt,phiarr, 'r', linewidth=lw)

legend((r'$fB1arr$', r'$fB2arr$', r'$fS1arr$',r'$fS2arr$', r'$phiarr$'), prop=FontProperties(size=16))
# title('test')
show()
