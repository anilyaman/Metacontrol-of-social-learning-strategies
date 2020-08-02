from scipy.integrate import odeint

def vectorfield(w, t, p):
    IC, IW, S = w
    fic, fiw, fs, eta = p


    phi = IC * fic + IW * fiw + S * fs
    f = [IC * ( fic - phi ) + eta * IW,   \
         IW * ( fiw - phi) - eta * IW,   \
         S  * ( fs  - phi)]
    return f

# Initial conditions and parameters
IC0 = 0.2
IW0 = 0.3
S0 = 0.5
epsilon = 0.1
piBStar = 0.8
piBHat = 0.1
eta = epsilon

fic = (1-epsilon) * piBStar + epsilon * piBHat
fiw = epsilon * piBHat 
fs = fic

# ODE solver parameters
abserr = 1.0e-8
relerr = 1.0e-6
stoptime = 40.0
numpoints = 1000

# Create the time samples for the output of the ODE solver.
t = [stoptime * float(i) / (numpoints - 1) for i in range(numpoints)]

# Pick up the parameters and initial conditions:
p = [fic, fiw, fs, eta]
w0 = [IC0, IW0, S0]

# Call the ODE solver.
wsol = odeint(vectorfield, w0, t, args=(p,),
              atol=abserr, rtol=relerr)

# Write solution to file
with open('sol.dat', 'w') as f:
    # Print & save the solution.
    for t1, w1 in zip(t, wsol):
        print >> f, t1, w1[0], w1[1], w1[2]
