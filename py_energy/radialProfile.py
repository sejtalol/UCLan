import numpy as np

def azimuthalAverage(x, y, phi, Rmax, bin_size):

    ra = np.sqrt(x**2+y**2)
    r = ra[ra < Rmax]
    lt = len(r) - 1
    
    # Get sorted radii
    ind = np.argsort(r.flat)
    r_sorted = r.flat[ind]
    i_sorted = phi.flat[ind]

    # Get the integer part of the radii
    r_int = r_sorted // bin_size
    r_int = r_int.astype(int)

    # Find all pixels that fall within each radial bin.
    deltar = r_int[1:] - r_int[:-1]  # Assumes all radii represented
    rind = np.where(deltar)[0]       # location of changed radius (e.g from 0, 0 --> 0, 1, 1)
    # Add first and last number
    rind = np.insert(rind,0,0)
    rind = np.insert(rind,len(rind),lt)
    nr = rind[1:] - rind[:-1]        # number of radius bin
    
    # Cumulative sum to figure out sums for each radius bin
    csim = np.cumsum(i_sorted, dtype=float)
    print (csim)
    tbin = csim[rind[1:]] - csim[rind[:-1]]
    print (tbin)

    radial_prof = tbin / nr * bin_size

    return radial_prof
