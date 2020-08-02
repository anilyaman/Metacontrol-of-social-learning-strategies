from numpy import loadtxt
from pylab import figure, plot, xlabel, grid, hold, legend, title, savefig
from matplotlib.font_manager import FontProperties

t, IC, IW, S = loadtxt('sol.dat', unpack=True)

figure(1, figsize=(6, 4.5))

xlabel('t')
lw = 2

plot(t, IC, 'b', linewidth=lw)
plot(t, IW, 'g', linewidth=lw)
plot(t, S, 'k', linewidth=lw)
plot(t, IC+IW, 'y', linewidth=lw)

legend((r'$IC$', r'$IW$', r'$S$', r'$I (=IC+IW)$'), prop=FontProperties(size=16))
# title('test')
savefig('sol.png', dpi=100)
