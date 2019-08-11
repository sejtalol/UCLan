import mymodules as mod
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import sys
matplotlib.rcParams.update({'font.size':14})

nn = int(sys.argv[1])   # initial time
dn = int(sys.argv[2])   # interval

DataBase = './data'

x1, y1, ang1, da1, Ej1, dEj1, flag1 = mod.get_data(DataBase, str(nn), str(nn+dn), 'bar', 'bar')
x2, y2, ang2, da2, Ej2, dEj2, flag2 = mod.get_data(DataBase, str(nn), str(nn+dn), 'interm', 'spiral')
x3, y3, ang3, da3, Ej3, dEj3, flag3 = mod.get_data(DataBase, str(nn), str(nn+dn), 'spiral', 'spiral')

#### CONFIG E_J & L_Z RANGE ####
# E_J: ej_x = ej, ej_y = dej, dej_y = dej/ej
ej_x_min, ej_x_max, ej_y_min, ej_y_max, dej_y_min, dej_y_max = -5, 0 , -0.05, 0.05, -0.05, 0.05

# L_Z: lz_x = ang, lz_y = da, dlz_y = da/ang
lz_x_min, lz_x_max, lz_y_min, lz_y_max, dlz_y_min, dlz_y_max = -1, 7, -1.25, 1.0, -0.5, 0.4

fig1 = plt.figure(figsize=(16, 10))
ax1 = fig1.add_subplot(121)
xmin = -8
xmax = 8
ymin = -8
ymax = 8
norm = matplotlib.colors.Normalize(vmin=lz_y_min, vmax=lz_y_max)
gci=mod.xy_plot(x1,y1,da1,xmin,xmax,ymin,ymax, 200, norm, ax1)
mod.xy_plot(x2,y2,da2,xmin,xmax,ymin,ymax, 200, norm, ax1)
mod.xy_plot(x3,y3,da3,xmin,xmax,ymin,ymax, 200, norm, ax1)
ax1.set_xlabel('x',fontsize=18)
ax1.set_ylabel('y',fontsize=18)
ax1.set_title('$\Delta L_{Z}$',fontsize=20)
#plt.colorbar(gci)
mod.plot_r('bar', ax1)

ax2 = fig1.add_subplot(122)
xmin = -8
xmax = 8
ymin = -8
ymax = 8
norm = matplotlib.colors.Normalize(vmin=ej_y_min, vmax=ej_y_max)
gci=mod.xy_plot(x1,y1,dEj1,xmin,xmax,ymin,ymax, 200, norm, ax2)
mod.xy_plot(x2,y2,dEj2,xmin,xmax,ymin,ymax, 200, norm, ax2)
mod.xy_plot(x3,y3,dEj3,xmin,xmax,ymin,ymax, 200, norm, ax2)
ax2.set_xlabel('x',fontsize=18)
ax2.set_ylabel('y',fontsize=18)
ax2.set_title('$\Delta E_{J}$',fontsize=20)
#plt.colorbar(gci)
mod.plot_r('bar', ax2)
fig1.savefig('./output/xy_t%3.3d_%3.3d.png'%(nn,(nn+dn)))

fig2 = plt.figure(figsize=(16, 10))
ax1 = fig2.add_subplot(121)
xmin = -4
xmax = 4
ymin = -4
ymax = 4
norm = matplotlib.colors.Normalize(vmin=lz_y_min, vmax=lz_y_max)
gci=mod.xy_plot(x1,y1,da1,xmin,xmax,ymin,ymax, 200, norm, ax1)
mod.xy_plot(x2,y2,da2,xmin,xmax,ymin,ymax, 200, norm, ax1)
mod.xy_plot(x3,y3,da3,xmin,xmax,ymin,ymax, 200, norm, ax1)
ax1.set_xlabel('x',fontsize=18)
ax1.set_ylabel('y',fontsize=18)
ax1.set_title('$\Delta L_{Z}$',fontsize=20)
#plt.colorbar(gci)
mod.plot_r('bar', ax1)

ax2 = fig2.add_subplot(122)
xmin = -4
xmax = 4
ymin = -4
ymax = 4
norm = matplotlib.colors.Normalize(vmin=ej_y_min, vmax=ej_y_max)
gci=mod.xy_plot(x1,y1,dEj1,xmin,xmax,ymin,ymax, 200, norm, ax2)
mod.xy_plot(x2,y2,dEj2,xmin,xmax,ymin,ymax, 200, norm, ax2)
mod.xy_plot(x3,y3,dEj3,xmin,xmax,ymin,ymax, 200, norm, ax2)
ax2.set_xlabel('x',fontsize=18)
ax2.set_ylabel('y',fontsize=18)
ax2.set_title('$\Delta E_{J}$',fontsize=20)
#plt.colorbar(gci)
mod.plot_r('bar', ax2)
fig2.savefig('./output/xy_t%3.3d_%3.3d_small.png'%(nn,(nn+dn)))

