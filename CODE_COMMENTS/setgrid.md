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

