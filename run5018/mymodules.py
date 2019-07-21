import matplotlib, os, sys
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as stats

################Function Block######################
def get_data(filepath, arg1, arg2, key1, key2):     # arg1: initial time, arg2: final time; key1: for select; key2: for pattern speed
    x = []
    y = []
    ang = []
    da = []
    Ej = []
    dEj = []
    # read in file
    x1, y1, vx1, vy1, vz1, m1, pe1 = searchFile(filepath, arg1)
    x2, y2, vx2, vy2, vz2, m2, pe2 = searchFile(filepath, arg2)
    # select for initial in the spiral
    print("Getting Angular Momentum & Jacobi Energy...")
    index = select(x1, y1, vx1, vy1, vz1, m1, pe1, key1)
    for m in range(len(index)):
        i = index[m]
        ang1 = x1[i]*vy1[i]-y1[i]*vx1[i]
        ang2 = x2[i]*vy2[i]-y2[i]*vx2[i]
        ang.append(ang1)
        da.append((ang2 - ang1))
        if(key2=='spiral'):
            Ej1 = pe1[i]+0.5*(vx1[i]**2+vy1[i]**2+vz1[i]**2)+omega_spiral*(vx1[i]*y1[i]-vy1[i]*x1[i])-0.5*omega_spiral**2*np.sqrt(x1[i]**2+y1[i]**2)**2
            Ej2 = pe2[i]+0.5*(vx2[i]**2+vy2[i]**2+vz2[i]**2)+omega_spiral*(vx2[i]*y2[i]-vy2[i]*x2[i])-0.5*omega_spiral**2*np.sqrt(x2[i]**2+y2[i]**2)**2
        elif(key2=='bar'):
            Ej1 = pe1[i]+0.5*(vx1[i]**2+vy1[i]**2+vz1[i]**2)+omega_bar*(vx1[i]*y1[i]-vy1[i]*x1[i])-0.5*omega_bar**2*np.sqrt(x1[i]**2+y1[i]**2)**2
            Ej2 = pe2[i]+0.5*(vx2[i]**2+vy2[i]**2+vz2[i]**2)+omega_bar*(vx2[i]*y2[i]-vy2[i]*x2[i])-0.5*omega_bar**2*np.sqrt(x2[i]**2+y2[i]**2)**2
        else:
            raise Exception('Please give the pattern speed keyword: bar, spiral. You used keyword:{}'.format(key2))
        Ej.append(Ej1)
        dEj.append((Ej2-Ej1))
        x.append(x1[i])
        y.append(y1[i])
    return(x, y, ang, da, Ej, dEj)

def searchFile(filepath, arg):      # filepath, arg should be string
    import os
    pathDir = os.listdir(filepath)
    for each in pathDir:
        each_file = filepath + os.sep + each
        if arg in each:
            x, y, vx, vy, vz, m, pe = readFile(each_file)
#           x, y, vx, vy, vz, m, pe = np.loadtxt(each_file,usecols=[0,1,2,3,4,5,6],unpack=True)
#           print('open file ...', each_file)
        if os.path.isdir(each_file):
            serchFile(each_file, arg)
    return(x, y, vx, vy, vz, m, pe)

#### 2. read file
def readFile(filepath):
    flag = 0                        # record data with problem
    n = 0
    x = []
    y = []
    vx = []
    vy = []
    vz = []
    m = []
    pe = []
    f = open(filepath, "r")
    for line in f:
        n = n + 1
        values = line.split()       # break each line into a list
        if (len(values) != 7):
            flag = flag +1
            print('No. %6d particle lost some info in the data file!')
        else:
            x.append(float(values[0]))
            y.append(float(values[1]))
            vx.append(float(values[2]))
            vy.append(float(values[3]))
            vz.append(float(values[4]))
            m.append(float(values[5]))
            pe.append(float(values[6]))
    return(x, y, vx, vy, vz, m, pe)

#### 3. selection function
def select(x0, y0, vx0, vy0, vz0, m0, pe0, keyword):
    flag = 0
    ind = []
    print('In selecting...')
    if(keyword=='spiral'):
        for i in range(len(x0)):
            r = np.sqrt(x0[i]**2 + y0[i]**2)
            if(r > Sep and r < R_max):
#           if(r > Sep):
                ind.append(i)
                flag = flag + 1
    elif(keyword=='bar'):
        for i in range(len(x0)):
            r = np.sqrt(x0[i]**2 + y0[i]**2)
            if(r < CR_bar):
                ind.append(i)
                flag = flag + 1
    elif(keyword=='interm'):
        for i in range(len(x0)):
            r = np.sqrt(x0[i]**2 + y0[i]**2)
            if(r > CR_bar and r < Sep):
                ind.append(i)
                flag = flag + 1
    elif(keyword=='disk'):
        for i in range(len(x0)):
            ind.append(i)
            flag = flag + 1
    else:
        raise Exception('Please give the REGION keyword: bar, spiral, interm. You used keyword:{}'.format(keyword))
    print("selected %d particles in %s region"%(flag, keyword))
    return(ind)

#### 4. plots
def hist2d_plot(x, y, x_min, x_max, y_min, y_max, ax):
    import matplotlib.cm as cm
    ax.cla()
#   norm= matplotlib.colors.Normalize(vmin=0,vmax=5)
    H,xedges,yedges = np.histogram2d(y, x,bins=(100,100),range=([y_min, y_max],[x_min, x_max]))
    X,Y = np.meshgrid(xedges,yedges)
    ax.imshow(np.log(H),interpolation='nearest',origin='lower', extent=[x_min, x_max, y_min, y_max], cmap=cm.get_cmap('jet'))
    ax.grid(True)

def kde_plot(x, y, x_min, x_max, y_min, y_max, ax):
    from sklearn.neighbors import KernelDensity
    xy = np.vstack([ang, da/ang])
    d = xy.shape[0]
    n = xy.shape[1]
    bw = (n * (d + 2) / 4.)**(-1. / (d + 4)) # silverman
#   bw = n**(-1./(d + 4)) # scott
    cmap=plt.cm.get_cmap('Reds')
    kde = KernelDensity(bandwidth=bw, metric='euclidean', kernel='gaussian', algorithm='ball_tree')
    kde.fit(xy.T)
    X, Y = np.mgrid[x_min:x_max:200j, y_min:y_max:200j]
    positions = np.vstack([X.ravel(), Y.ravel()])
    Z = np.reshape(np.exp(kde.score_samples(positions.T)), X.shape)
    ax.imshow(np.rot90(Z), cmap = cmap, extent=[x_min, x_max, y_min, y_max])
#   contour
    ax.contour(X, Y, Z)
    ax.grid(True)
    ax.set_xlim(x_min, x_max)
    ax.set_ylim(y_min, y_max)

    #### 5. rotate
def rotate(x0, y0, vx0, vy0, phase):
#   phase = np.pi * (80.) / 180.
    x = [x0[i]*np.cos(phase) - y0[i]*np.sin(phase) for i in range(len(x0))]
    y = [x0[i]*np.sin(phase) + y0[i]*np.cos(phase) for i in range(len(x0))]
    vx = [vx0[i]*np.cos(phase) - vy0[i]*np.sin(phase) for i in range(len(vx0))]
    vy = [vx0[i]*np.sin(phase) + vy0[i]*np.cos(phase) for i in range(len(vx0))]
    return(x, y, vx, vy)

#### 6. is_in_region(point, bot left grid, top left grid, top right grid, bot right grid )
def is_in_region(x, y, a1, a2, b1, b2, c1, c2, d1, d2):
    from shapely.geometry import Point
    from shapely.geometry.polygon import LinearRing,Polygon
    point = Point(x,y)
    polygon = Polygon([(a1,a2), (b1,b2), (c1,c2), (d1,d2)])
    return polygon.contains(point)

#### 7. L_Z, E_J
def get_ang(x, y, vx, vy):
    return([x[i] * vy[i] - y[i] * vx[i] for i in range(len(x))])

def get_ej(x, y, vx, vy, vz, pe, keyword):
    ej = []
    if(keyword=='spiral'):
        ej = [pe[i]+0.5*(vx[i]**2+vy[i]**2+vz[i]**2)+omega_spiral*(vx[i]*y[i]-vy[i]*x[i])-0.5*omega_spiral**2*np.sqrt(x[i]**2+y[i]**2)**2 for i in range(len(x))]
    elif(keyword=='bar'):
        ej = [pe[i]+0.5*(vx[i]**2+vy[i]**2+vz[i]**2)+omega_bar*(vx[i]*y[i]-vy[i]*x[i])-0.5*omega_bar**2*np.sqrt(x[i]**2+y[i]**2)**2 for i in range(len(x))]
    else:
        raise Exception('Please give the pattern speed keyword: bar, spiral. You used keyword:{}'.format(keyword))
    return ej

####################################################
# read in time step from arg
global xmin, xmax, ymin, ymax, omega_bar, omega_spiral, CR_bar, CR_spiral, Sep, R_max
#nn = int(sys.argv[1])   # ini timestep
#dn = int(sys.argv[2])   # timestep interval

omega_bar = 0.542
omega_spiral = 0.228
CR_bar = 3.2
CR_spiral = 7.0
Sep = 5.5
R_max = 8.
