from scipy.integrate import odeint

def system(w, t, p):
    IC, IW, S = w
    fic, fiw, fs, eta = p

    fs = (IC*fic + IW*fiw)/(IC+IW)
    phi = IC * fic + IW * fiw + S * fs
    f = [IC * ( fic - phi ) + eta * IW,   \
         IW * ( fiw - phi) - eta * IW,   \
         S  * ( fs  - phi)]
    return f

# Initial conditions and parameters
IC0 = 0.3333
IW0 = 0.3333
S0 = 0.3333
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
stoptime = 40.0
numpoints = 1000

t = [stoptime * float(i) / (numpoints - 1) for i in range(numpoints)]
# ODE solver.
wsol = odeint(system, w0, t, args=(p,),
              atol=abserr, rtol=relerr)

# export to file
with open('sol.dat', 'w') as f:
    # Print & save the solution.
    for t1, w1 in zip(t, wsol):
        print >> f, t1, w1[0], w1[1], w1[2]
