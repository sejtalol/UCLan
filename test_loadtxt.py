# used to test if np.loadtxt get the correct split
import numpy as np
filename='./data_bar/ptcls_info_t400.dat'
file=open(filename,'r')
x1=[]
y1=[]
vx1=[]
vy1=[]
vz1=[]
m1=[]
pe1=[]
for line in file:
    values = line.split()     #break each line into a list
    if (len(values)!=7):
       print(values)

