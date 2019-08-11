import mymodules as mod
import numpy as np
import sys
import matplotlib
import matplotlib.pyplot as plt

nn = int(sys.argv[1])   # initial time
dn = int(sys.argv[2])   # interval
keyword = sys.argv[3]       # select region (see mymodule.py)
key_pattern = sys.argv[4]      # pattern speed to use

# step
step_interval = 20

print('########################')
print('Start...Initial Time = %d, Final Time = %d, in region %s'%(nn, (nn+dn), keyword))

#### PARAMETERS ####

DataBase = './data'

#### GET_DATA
x, y, ang, da, Ej, dEj, flag = mod.get_data(DataBase, str(nn), str(nn+dn), keyword, key_pattern)

#### GET RANDOM ORBIT
orb_t, orb_x, orb_y, orb_vx, orb_vy, orb_vz, orb_pe, orbit_number = mod.get_orbit(DataBase, str(nn), str(nn+dn), Ej, dEj, flag)

orb_r = [np.sqrt(orb_x[i]**2+orb_y[i]**2) for i in range(len(orb_x))]
Lz = mod.get_ang(orb_x, orb_y, orb_vx, orb_vy)
Ej = mod.get_ej(orb_x, orb_y, orb_vx, orb_vy, orb_vz, orb_pe, key_pattern)

fig = plt.figure(figsize=(16, 10), dpi=72, facecolor="white")

# set font
font = {'family' : 'Times New Roman',
        'color'  : 'darkred',
        'weight' : 'normal',
        'size'   : 20,
        }

ax1 = fig.add_subplot(311)
ax1.tick_params(direction='out',labelsize=18)
ax1.set(xlabel = 'Time', ylabel = 'Radius')
plt.plot(orb_t, orb_r)
plt.setp(ax1.get_xticklabels())

ax2 = fig.add_subplot(312, sharex=ax1)
ax2.tick_params(direction='out',labelsize=18)
ax2.set(ylabel = '$L_{Z}$')
plt.plot(orb_t, Lz)
plt.setp(ax2.get_xticklabels(), visible = False)

ax3 = fig.add_subplot(313, sharex=ax1)
ax3.tick_params(direction='out',labelsize=18)
ax3.set(ylabel = '$E_{J}$')
plt.plot(orb_t, Ej)
plt.setp(ax3.get_xticklabels(), visible = False)

figname = 'orb_no_%d_%s_%s'%(orbit_number, keyword, key_pattern)
plt.savefig(figname)
