Grids in GALAXY15
----
##smfield.f  
####using the grid to compute the field of component  
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

###Set the grids  
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

###1.p3dset
<dl>
	<dt>p3dset.f</dt>
	<dd>routine to read in grid parameters for 3-D polar grid (from .dat file)</dd>
</dl>  

>call p3dset  

it reads in the parameters
>grid size	nr(jgrid) na, ngz    
>z spacing	dzg  
>HASH			ng  
>\#highest active sectoral harmonic  
>POWE			gamma  
>\#ring spacing exponent  
>UOFF			uoffs  
>\#inner edge of grid - default is no inner hole (uoffs = 0)  
>INTE			jmass  
>\#interpolation scheme (2 - default or 3)  
>SOFT			softl, tsoft  
>\#softening length (softl), and rule (tsoft): 1 for Plummer and 2 for cubic spline - default  

And return the values to grdset.  

###2.filset
<dl>
	<dt>filset.f</dt>
	<dd>routine to set up filter for Fourier harmonics. When m=0 terms filtered out, the analytic radial acceleration will be applied to every particle</dd>
</dl>  

>call p3dset  
