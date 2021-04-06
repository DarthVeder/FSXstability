from isa.temperature import temperature 
from isa.pressure import pressure 
from isa.asound import asound 
from isa.density import density 
import numpy as np
import matplotlib.pyplot as plt


hmax = 31000  # m
h = np.linspace(0, hmax, int(hmax/1000))
T = np.zeros(len(h))
d = np.zeros(len(h))
p = np.zeros(len(h))
a = np.zeros(len(h))
for i in range(len(h)):
    T[i] = temperature(h[i])
    p[i] = pressure(h[i])
    d[i] = density(h[i])
    a[i] = asound(h[i])


fig, axs = plt.subplots(2, 2)
fig.suptitle('ISA Atmosphere')
axs[0, 0].plot(d, h)
axs[0, 0].set_xlabel('Density (kg/m^3)')
axs[0, 1].plot(p, h)
axs[0, 1].set_xlabel('Pressure (Pa)')
axs[1, 0].plot(a, h)
axs[1, 0].set_xlabel('Sound speed (m/s)')
axs[1, 1].plot(T, h)
axs[1, 1].set_xlabel('Temperature (K)')

plt.show()
