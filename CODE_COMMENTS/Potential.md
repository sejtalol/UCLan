Potential Solution for P3D
----
The grid have N<sub>R</sub> arbitrarily spaced rings, N<sub>a</sub>  equally spaced azimuthal divisions and N<sub>z</sub> planes spaced equally by the distance h<sub>z</sub>.

The solution of the potential is:  
1.use subroutine **p3manl** to do a double Fourier analysis of the masses <em>w(t, u, v)</em> assigned to each ring and plan <em>u, v</em>.  
2.followed by radial convolution of each separate sectoral harmonic <em>m</em> in **p3conv** (eq. 46).
3.completed by Fourier synthesis of the potential coefficients on each ring and plane <em>j, k</em> in subroutine **p3fsyn** (eq. 45).  

<p><img src="P3D_pot.png"</p>

in code _p3fndf.f_
----
#### 1.determine the number of active sectoral harmonics

~~~
j = 0
do i = 1, ng
	if( .not. lg( i ) )j = j + 1
end do
ntypes = 3
if( potl )ntypes = 4
~~~
if potential is required, ntypes = 4  
if j > 0, then do next, else force free grid  

~~~
do itype = 1, ntypes
	do i = 1, mesh( jgrid )
		grdfld( i, itype ) = 0
	end do
end do
~~~

#### 2.determine radial range which contains all sources

~~~
jrs = nr( jgrid )
krs = 0
do i = 1, nzones
	jrs = min( jrs, jrad( i ) )
	krs = max( krs, krad( i ) )
	if( i .gt. 1 )krad( i ) = max( krad( i ), krs )
end do
~~~

### 3.copy mass array to work space

~~~
ispac = ( krs - jrs + 1 ) * na * ngz
ips = ngz * na * ( jrs - 1 )
call blkcpy( grdmss( ips + 1, 1 ), grdmss( 1, 0 ), ispac )
~~~
>call blkcpy(x, y, n) \# copy x(n) into y(n)

### 4.form double Fourier transform of mass array  
**p3manl** do Fourier analysis of each vector in turn  

>call p3manl(jrs, krs)  

~~~
j = 1
do m = 1, nrs * nm
	call sfftf1( mtrig, w( j ), trig, trig( mtrig + 1 ), trig( 2 * mtrig + 1 ) )
	j = j + mtrig
end do
~~~

### 5.assume forces are required over the whole grid unless told otherwise  

~~~
jrf = 1
if( ( jzone .gt. 0 ) .and. ( jrad( jzone ) .lt. nr( jgrid ) ) )jrf = jrad( jzone )
krf = nr( jgrid )
if( ( kzone .le. nzones ) .and. ( .not. wholeg ) )then
	krf = krad( kzone )
	do while ( krf .lt. jrf )
		kzone = kzone + 1
		if(kzone .gt. nzones )call crash( 'P3FNDF', 'kzone > nzones' )
		krf = krad( kzone )
	end do
end if
~~~

### 6.work over ntypes
no azimuthal forces when m = 0 only is selected  
>grdfld(mesh(jgrid), 2)=0 \# azimuthal force when itype = 2

else do radial convolution **p3conv**

>call p3conv( itype, jrs, krs, jrf, krf )

and re-synthesize

>call p3fsyn( itype, jrf, krf )

in code _findf.f_
----
use **p3fndf**
>call p3fndf(jzone, kzone)  
>call polcat \# convert to Cartesian components

set flag that gravitational fields are now current
>isfld = istep

## Computing the gravitational field of the particles  

1.Grid methods
----
* the polar coordinate geometies that concentrate spatial resolution at the geometric center of the grid, which coincides with the highest density of particles in simulations of galaxies.  
* a significant limitationof grid methods is that self-consistent forces cannot be computed for particles outside the grid volume. (but their motion can be advanced using one of a number of different approximations).  

2.Field methods
----
* compute the field from an expansion in some suitably chosen set of basis functions, which is called 'smooth-field particle' method (SFP).  
* these methods are ideal for checking the stability of equilibrium models, or for measuring relaxation rates in equilibrium models, but for little else.

3.Direct methods
----
* the least efficient, but most flexible methods determine the gravitational forces directly from the particles.  
* it is the direct summation of the forces over all particles pairs.
* tree codes approximate the forces from distant groupings of particles, and therefore do not yield quite such accurate forces, but the approximation leads to a substantial speed up over the direct-N approach (the tree code offered here is not well optimized, better looking for a state-of-art tree code somewhere else).
* it is very useful to introduce a set of very heavy particles whose motion and interactions with more numerous lighter particles and be computed directly.

4.hybrid
----
<dl>
<dt>hybrid = T<dt>
<dd>two concentric grids</dd>
this is useful when computing a disk (cylindrical polar grid) + a bulge/halo component (sherical grid). (also see Sellwood 2003)
<dt>twogrd = T</dt>
<dd>two grids with different centers.</dd>
This is used to compute the internal dynamics of two interacting but initially separate systems (this option still needs further improvement).
<dt>heavies = T</dt>
useful to compute a sea of light particles using a grid method while including a small number of heavy particles whose attractions are computed directly. (also see Jardel & Sellwood 2009)
</dl>

Grid noise in Polar Grids
----
The collisionless simulations are not concerned with forces between individual particles, since each particle is supposed to experience only the mean attraction of large-scale mass distribution. The variation of the forces between individual particles re not a cause for concern. However, for calculations that yield important results, the user should rerun with a finer grid in order to verify that grid noise is not affecting results.  

Local buffer
----
#### The code advances particles in groups of up to 1000, keeping a wide variety of information about each in a local buffer. They are processed in the following manner:  
<ol>
	<li>A call to <b>gather</b> collects the next group of particles in the current chain from the main array <b>ptcls</b>. This routine places a copy of their coordinates at the start of the step in the local array <b>oldc</b> and also decodes any flags.</li>
	<li>The accelerations to be applied to each of these particles are determined in a call to <b>getacc</b> and stored in array <b>acc</b>. They are generally interpolated from the grid and may include externally applied accelerations.</li>
	<li>If this is an analysis step, a call to <b>anlgrp</b> will cause the contributions of this group of particles to be added to the cumulative analysis of the model. The needed initial coordinates and accelerations have previously been assemebled.</li>
	<li>The motion of each particle is advanced in a call to <b>stpgrp</b>, which places the updated coordinates in the array <b>newc</b>. This routine also flags any particles that leave the grid at this step.</li>
	<li>A call to <b>scattr</b> copies the updated coordinates of each particle in the group, temporarily stored in array <b>newc</b>, back to its original location in the main particle array, and updates the linked list for whichever zone they are in.</li>
	<li>Finally, the mass of each particle at its updated position is assigned to the grid array that accumulates the masses of particles in each zone by a call to <b>massgn</b>.</li>
</ol>

### gather
>calling arguments - input value of jst is ignored, returned value is the actual number of particles gathered.  The maximum is set by the parameter mbuff which is used to dimension the workspace arrays.  

ncl = cell number  
loc = location (inext)  
iz  = i zone  
label = jlist  
ipln = i plane  
iflag = ptcls( inext + nwpp - 1 )   

~~~
jst = 0
c gather particles from linked list
      do while ( jst .lt. mbuff )
        jst = jst + 1
c set unstored info
        ncl( jst ) = 0
        loc( jst ) = inext
        iz( jst ) = izone
        label( jst ) = jlist
        ipln( jst ) = iplane
c pick up coordinates
        do i = 1, ncoor
          oldc( i, jst ) = ptcls( inext + i )
        end do
c particle weight, if not uniform
        if( uqmass )pwt( jst ) = ptcls( inext + ncoor + 1 )
c Barnes-Hut tree loc
        if( bht )then
          a = ptcls( inext + nwpp - 2 )
          ltree( jst ) = ia
        end if
c pick up flag
        a = ptcls( inext + nwpp - 1 )
        iflag( jst ) = ia
c pick up next pointer
        a = ptcls( inext + nwpp )
        inext = ia
c check for end of list
        if( inext .lt. 0 )return
      end do
      return
~~~

step.f
----
<q> Main driving routine for advancing all the particles forward by one step. </q>  
The <b>acceleration components</b> over the entire grid should have been determined previously by a call to <b>FINDF</b>.  
The particles are processed in groups, each group being worked through the following sequence of calls:  
>GATHER:  collect the next group from the main particle storage area  
>GETACC:  look up acceleration components to be applied  
>STPGRP:  advance positions and velocities  
>(ANLGRP:  include contributions of these particles to measurements)  
>SCATTR:  replace new coordinates in the main particle storage area  
>MASSGN:  assign mass to the grid using new positions OR determine new maxr for SFP code using new positions  

~~~
c work through all lists
      do ilist = 1, nlists
c find zone and grid code for this list
        call interpret
        call switch( jlist )
        inext = islist( 1, ilist, n )
c work through groups of particles
        do while ( inext .ge. 0 )
          isubst = 1
          call gather( jst )
c get accelerations
          call getacc( jst )
c analysis
          if( phys )then
            call anlgrp( jst, nact, lprop, prop, nbplot, dispy,
     +                   lglen, alspi, jlen, besc, nLbin, nLa,
     +                   lzman, zman, lzpr, zpbin, lmoni, ehmon,
     +                   nwring, wring, llz, Lzval )
          end if
c step forward
          call stpgrp( jst )
c rezone
          call rezgrp( jst )
c update labels etc
          call relabl( jst )
c store new coordinates
          call scattr( jst )
        end do
      end do
~~~

The routine begins with calls to MASSCL to zero out the mass array(s) in readiness for the new values MEASURE to initialise the analysis software  
After all particles have been processed:  
>STARCT checks the number of particles assigned to the grid  
>SCALED mulitplies the mass array(s) by the appropriate normalisation factor  
>(MEASURE is called again to complete the analysis and save the information)  
>MEASURE and ANLGRP are called only if this is an analysis step  
>REZGRP is needed only if multiple time steps are in use  

~~~
c check particle count and rescale density distribution
        call ncheck
        call scaled
~~~

In the 3-D Cartesian code, the particles are <b>sorted by planes of the grid</b> to enable all those in one plane to be processed before beginning the next.  

This is so that acceleration components can be determined from the potential more efficiently by a single call to DIFPOT for each plane.  

The particles in each zone are located through a linked list with the initial location stored in the <b>array ISLIST</b> and the last particle has a <b>zero pointer</b>.  A new linked list is created for the new positions, and the initial locations are copied over the original set after all particles have been processed.



off-grid particles
----
if the evolution remains of interest after a significant fraction (5%) of the particles have left the grid, the user should restart the simulation with a smaller value of <b>lscale</b> in order that the initial particle distribution occupies a smaller fraction of the grid volume.

Grids in GALAXY15
----
## smfield.f  
#### using the grid to compute the field of component  
1.initialize grid parameters
>call grdset  
call setrun  

2.create or check Greens function file for grid methods
>call green( .false. )  

3.allocate space
>call space  

4.assign mass to grids
>phys = .true.
>lprint = .true.
>dist( j ) = .false.
>call smmass #create a smooth density distribution on the grid from the analytic mass distribution

5.determine gravitational field  
>call findf( .true. )  

6.create and save tables of potential and central attraction (include contributions from rigid components)  

~~~  
nradt = 1001
do i = 1, nradt
	rs = .999 * rgrid(jgrid) * real(i-1) / real( nradt -1 )
	r = rs / lscale
	radt( i ) = r
	Phtt(i) = meanph2(rs, 0.d0) * gvfac **2
	frtt(i) = meanrf2(rs) / (lscale * ts**2 )
end do
~~~

### Set the grids  
<dl>
	<dt>grdset.f</dt>
	<dd>driving routine to read the parameters and then to set up the requested field determination method(s)</dd>
</dl>

>call grdset  

in p3d case, it simply do:
>call p3dset  
>call filset #setup sectors, Fourier fileter, etc  
>call setgrd(.true.)  
>call switch(0) #do nothing if there is only one grid   

### 1.p3dset
<dl>
	<dt>p3dset.f</dt>
	<dd>routine to read in grid parameters for 3-D polar grid (from .dat file)</dd>
</dl>  

>call p3dset  

it reads in the parameters
>grid size	nr(jgrid) na, ngz    
>z spacing	dzg  
>HASH			ng  
>\# highest active sectoral harmonic  
>POWE			gamma  
>\# ring spacing exponent  
>UOFF			uoffs  
>\# inner edge of grid - default is no inner hole (uoffs = 0)  
>INTE			jmass  
>\# interpolation scheme (2 - default or 3)  
>SOFT			softl, tsoft  
>\#softening length (softl), and rule (tsoft): 1 for Plummer and 2 for cubic spline - default  

And return the values to grdset.  

### 2.filset
<dl>
	<dt>filset.f</dt>
	<dd>routine to set up filter for Fourier harmonics. When m=0 terms filtered out, the analytic radial acceleration will be applied to every particle</dd>
</dl>  

>call filset  

### 3.setgrd
<dl>
	<dt>setgrd.f</dt>
	<dd>routine to set up the grid to be used for the field determination. </dd>
</dl>  

>call setgrd   

Called from either GRDSET, CMPRUN or HEDREC  

1.set default value for all (grid) methods
> rinh(jgrid) = 0.  

2.estimate outer boundary
> amax = 1.1 * rmax  
> if(amax .eq. 0 )amax = 10  

3.ensure that grid contains an even number of points in angle
> na = 2 * ( na / 2 )  

4.ensure that grid contains an suitable number of verticle mesh points  

~~~
if( p3d )then
	i = 0
	do while ( mod( ngz, 3 ) .eq. 0 )
		i = i + 1
		ngz = ngz / 3
	end do
	j = 0
	do while ( mod( ngz, 5 ) .eq. 0 )
		j = j + 1
		ngz = ngz / 5
	end do
	if( ngz .ne. 1 )then
		if( master )write( no, '( ''ngz ='', i4, '' x 3**'',' ' i1, '' x 5**'', i1 )' )ngz, i, j
		call crash( 'SETGRD', 'ngz must be a multiple of 3 & 5' )
	end if
	ngz = 3**i * 5**j
else
	ngz = 1
end if
~~~

5.grid size and Fourier harmonics  
> mesh(jgrid) = nr(jgrid) * na * ngz  
> \# read from setrun.f  
> mmax = na / 2 + 1  
> alpha = 2. * pi / real(na)  
> &theta; for every spoke  
> ng = min( ng, mmax )

6.grid spacing exponent  

~~~  
gamma = min( gamma, 1. )  
logrid = abs( 1. - gamma ) .lt. 0.01
if( logrid )then
	gamma = 1
	ibeta = 0
	beta = -1
	if( lout )write( no, * )' Spacing of grid rings is logarithmic'
else
	if( lout )write( no, '( 5x, ''gamma ='', f6.3 )' )gamma
	beta = 1. / ( 1. - gamma )
	ibeta = 1. - gamma
	if( lout )write( no,'('' Power law spacing of grid rings with exponent'', f8.3 )')beta
end if
~~~  
if gamma ~ 1 then logrid = .true. (logarithmic spacing) or logrid = .false. power-law spacing.

7.linear interpolation

>jmass = 2, linear interpolation  
>jmass = 3, quadratic interpolation  

8.radial grid boundary
>rinh(jgrid), inner hole  
>rgrid(jgrid), outer edge

9.vertical grid boundary
>a = 0.5 * dzg * real(ngz + 1 - jmass)  

10.softening length   
<ul>
<li>set constants to be used in interpolation</li>

~~~  
thmax = na  
~~~

<li>allow for subdivision into sectors</li>

~~~  
thmax = thmax / real( nsect )
~~~

<li>check for sensible grid cell sizes in relation to softl</li>

~~~
a = nr( jgrid ) - 2
a = rgrid( jgrid ) - grofu( a )
~~~
>grofu( a ): returns the cylindrical radius at for the input grid  

If a > 3 &#215; softl, it means the grid cell is sensible to the softening length.

</ul>

p3test
----
<dl>
	<dt>p3chkf</dt>
		<dd>Routine to check the solution for the field on the 3-D polar code by direct convolution for a few point masses.</dd>
</dl>