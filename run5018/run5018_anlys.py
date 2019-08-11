import mymodules as mod
import sys
import matplotlib
import matplotlib.pyplot as plt
matplotlib.rcParams.update({'font.size':14})

nn = int(sys.argv[1])   # initial time
dn = int(sys.argv[2])   # interval
keyword = sys.argv[3]      # select region (see mymodule.py)
key_pattern = sys.argv[4]      # pattern speed to use

print('########################')
print('Start...Initial Time = %d, Final Time = %d, in region %s'%(nn, (nn+dn), keyword))

#### PARAMETERS ####
# should test in jupyter first

DataBase = './data'

# model 5018, omega_bar = 0.542, omega_spiral = 0.228, CR_bar = 3.2 ,CR_spiral = 7.0
# to separate spiral particles: Sep = 5.5
# R_max = 8.

#### READ FILE ####

x, y, ang, da, Ej, dEj, flag = mod.get_data(DataBase, str(nn), str(nn+dn), keyword, key_pattern)

#### BACK-UP DATA ####
#output = open("test.dat", "w")
#for i in range(len(x)):
#    output.writelines('%f\t%f\t%f\t%f\t%f\t%f\n'%(x[i], y[i], ang[i], da[i], Ej[i], dEj[i]))

#### CONFIG E_J & L_Z RANGE ####
# E_J: ej_x = ej, ej_y = dej, dej_y = dej/ej
ej_x_min, ej_x_max, ej_y_min, ej_y_max, dej_y_min, dej_y_max = -4, 0 , -0.2, 0.2, -0.03, 0.03

# L_Z: lz_x = ang, lz_y = da, dlz_y = da/ang
lz_x_min, lz_x_max, lz_y_min, lz_y_max, dlz_y_min, dlz_y_max = -1, 7, -1.5, 1.5, -1.0, 1.0

#### dEj - Ej #### hist2D
fig1, ax1 = plt.subplots(figsize=(16, 10))
mod.hist2d_plot(Ej, dEj, ej_x_min, ej_x_max, ej_y_min, ej_y_max, ax = ax1)
lab = 'E_{J}'
ax1.set_xlabel('$%s$'%(lab),fontsize=18)
ax1.set_ylabel('$\Delta %s$'%(lab),fontsize=18)
ax1.set_title('Change of $%s$ in %s from T = %d to %d'%(lab, keyword, nn, nn+dn),fontsize=20)
fig1.savefig('./output/d%s_%s_t%d_t%d.png'%(lab, keyword, nn, nn+dn))

#### dEj/Ej - Ej #### hist2D
fig2, ax2 = plt.subplots(figsize=(16, 10))
mod.hist2d_plot(Ej, [mod.foo(dEj[i],Ej[i]) for i in range(len(Ej))], ej_x_min, ej_x_max, dej_y_min, dej_y_max, ax = ax2)
lab = 'E_{J}'
ax2.set_xlabel('$%s$'%(lab),fontsize=18)
ax2.set_ylabel('$\Delta %s / %s$'%(lab, lab),fontsize=18)
ax2.set_title('Change of $%s$ in %s from T = %d to %d'%(lab, keyword, nn, nn+dn),fontsize=20)
fig2.savefig('./output/d%s_%s_%s_t%d_t%d_.png'%(lab, lab, keyword, nn, nn+dn))

#### dLZ - LZ #### hist2D
fig3, ax3 = plt.subplots(figsize=(16, 10))
mod.hist2d_plot(ang, da, lz_x_min, lz_x_max, lz_y_min, lz_y_max, ax = ax3)
lab = 'L_{Z}'
ax3.set_xlabel('$%s$'%(lab),fontsize=18)
ax3.set_ylabel('$\Delta %s$'%(lab),fotsize=18)
ax3.set_title('Change of $%s$ in %s from T = %d to %d'%(lab, keyword, nn, nn+dn),fontsize=20)
fig3.savefig('./output/d%s_%s_t%d_t%d.png'%(lab, keyword, nn, nn+dn))

#### dLZ/LZ - LZ #### hist2D
fig4, ax4 = plt.subplots(figsize=(16, 10))
mod.hist2d_plot(ang, [mod.foo(da[i],ang[i]) for i in range(len(ang))], lz_x_min, lz_x_max, dlz_y_min, dlz_y_max, ax = ax4)
lab = 'L_{Z}'
ax4.set_xlabel('$%s$'%(lab),fontsize=18)
ax4.set_ylabel('$\Delta %s / %s$'%(lab, lab),fontsize=18)
ax4.set_title('Change of $%s$ in %s from T = %d to %d'%(lab, keyword, nn, nn+dn),fontsize=20)
fig4.savefig('./output/d%s_%s_%s_t%d_t%d.png'%(lab, lab, keyword, nn, nn+dn))
