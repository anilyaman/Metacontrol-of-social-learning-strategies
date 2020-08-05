from scipy.integrate import odeint
import numpy as np

stoptime = 300.0


def piB1(t):
    if t < stoptime / 2:
        return 0.8
    else:
        return 0.1


def piB2(t):
    if t < stoptime / 2:
        return 0.1
    else:
        return 0.8



def system(w, t, p):
    B1, B2, S = w
    fB1, fB2, fs, eta = p

    if t < stoptime / 2:
        fB1 = (1 - epsilon) * piB1(t) + epsilon * piB2(t)
        fB2 = (1-epsilon) * piB2(t)
    else:
        fB1 = (1-epsilon) * piB2(t)
        fB2 = (1 - epsilon) * piB2(t) + epsilon * piB1(t)

    phi = B1 * fB1 + B2 * fB2
    fs = 0
    d = 1
    a = 1.5

    B1arr = []
    B2arr = []
    Sarr = []

    B1arr.append(B1)
    B2arr.append(B2)
    Sarr.append(S)

    xB1 = []
    xB2 = []
    bS = []

    bS.append([10e-8, 10e-8])
    xB1.append((1 - epsilon) * B1arr[0])
    xB2.append(epsilon * B1arr[0] + B2arr[0])
    if d != 0:
        if t - d >= t % d:
            for i in np.arange(t % d, t, d):
                if i < stoptime/2:
                    bS.append([xB1[len(xB1) - 1], xB2[len(xB2) - 1]])
                    xB1.append((1 - epsilon) * B1arr[len(B1arr) - 1] + Sarr[len(Sarr) - 1] * bS[len(bS) - 2][0])
                    xB2.append(epsilon * B1arr[len(B1arr) - 1] + (1-epsilon) * B2arr[len(B2arr) - 1] + Sarr[len(Sarr) - 1] * bS[len(bS) - 2][1])
                else:
                    bS.append([xB1[len(xB1) - 1], xB2[len(xB2) - 1]])
                    xB1.append(epsilon * B2arr[len(B2arr) - 1] + (1-epsilon) * B1arr[len(B1arr) - 1] + Sarr[len(Sarr) - 1] *bS[len(bS) - 2][0])
                    xB2.append((1 - epsilon) * B2arr[len(B2arr) - 1] + Sarr[len(Sarr) - 1] * bS[len(bS) - 2][1])

        xB1Pow = pow(bS[len(bS) - 1][0], a)
        xB2Pow = pow(bS[len(bS) - 1][1], a)
        xbSum = xB1Pow + xB2Pow
        fs = (xB1Pow * piB1(t) + xB2Pow * piB2(t)) / xbSum

    phi = B1 * fB1 + B2 * fB2 + S * fs

    Q = [[0.999, 0, 0.001], [0, 0.999, 0.001], [0.0005, 0.0005, 0.999]]
    # Q = np.identity(n=3)
    # f = np.array([B1 * (fB1 - phi) + eta * B2, \
    # B2 * (fB2 - phi) - eta * B2, \
    # S * (fs - phi)])

    # Q = np.transpose(Q)
    # sum_j Qij = 1

    if t < stoptime / 2:
        f = np.array([(B1 * fB1 * Q[0][0] + B2 * fB2 * Q[1][0] + S * fs * Q[2][0]) - B1 * phi + eta * B2, \
                      (B1 * fB1 * Q[0][1] + B2 * fB2 * Q[1][1] + S * fs * Q[2][1]) - B2 * phi - eta * B2, \
                      (B1 * fB1 * Q[0][2] + B2 * fB2 * Q[1][2] + S * fs * Q[2][2]) - S * phi])
    else:
        f = np.array([(B1 * fB1 * Q[0][0] + B2 * fB2 * Q[1][0] + S * fs * Q[2][0]) - B1 * phi - eta * B1, \
                      (B1 * fB1 * Q[0][1] + B2 * fB2 * Q[1][1] + S * fs * Q[2][1]) - B2 * phi + eta * B1, \
                      (B1 * fB1 * Q[0][2] + B2 * fB2 * Q[1][2] + S * fs * Q[2][2]) - S * phi])

    return f


# Initial conditions and parameters
B10 = 0.01
B20 = 0.01
S0 = 0.01
epsilon = 0.1
piBStar = 0
piBHat = 0
eta = epsilon

fB1 = []
fB2 = []
fs = []

p = [fB1, fB2, fs, eta]
w0 = [B10, B20, S0]

# ODE solver parameters
abserr = 1.0e-8
relerr = 1.0e-6
numpoints = 1000

t = [stoptime * float(i) / (numpoints - 1) for i in range(numpoints)]
# ODE solver.
wsol = odeint(system, w0, t, args=(p,),
              atol=abserr, rtol=relerr)

T = []
B1 = []
B2 = []
S = []
I = []
for t1, w1 in zip(t, wsol):
    T.append(t1)
    B1.append(w1[0])
    B2.append(w1[1])
    S.append(w1[2])
    I.append(w1[0] + w1[1])

# !pip install pylab
from pylab import figure, plot, xlabel, grid, legend, title, show
from matplotlib.font_manager import FontProperties

figure(1, figsize=(6, 4.5))

xlabel('t')
lw = 2

plot(t, B1, 'b', linewidth=lw)
plot(t, B2, 'g', linewidth=lw)
plot(t, S, 'k', linewidth=lw)
#plot(t, I, 'y', linewidth=lw)

legend((r'$B1$', r'$B2$', r'$S$', r'$I (=B1+B2)$'), prop=FontProperties(size=16))
# title('test')
show()
