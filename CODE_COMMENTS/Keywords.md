Analysis Keyword
----
It should be a 4 letter keyword, appended to the list in subroutine **datnam**, after increasing by one the parameter **mtype** that is include file **params.f**. Then the output to the **.res** file at each time the analysis is performed should be in the form of two records of binary data:  

* A record header that contains just 5 values:  
	&nbsp;&nbsp;&nbsp;&nbsp;**irun, bhol, istep, i1, i2**  
	&nbsp;&nbsp;&nbsp;&nbsp;**irun** and **istep** are variables in the common block **/admin/**,  
	&nbsp;&nbsp;&nbsp;&nbsp;**bhol** is 4 character keyword chosen by the user that is written as a Hollerith string (old 4-byte character string type in early Fortran, use swap.f to transfer it into the normal string type).  
	&nbsp;&nbsp;&nbsp;&nbsp;**i1**, **i2** are usually integers that can be used to deduce the length of the next data record (nextrec.f)  
* A single record that can be of any (reasonable) length containing the values from the analysis. This is typically an array of values, with **i1** and **i2** from the previous record specifying the array dimensions.  

Then edit the **setrun** file, to enable it to be controlled from the .dat file. Again it will require a new keyword for input together with 1 or 2 values that will control the analysis.

setrun.f
----
>data a / 'LSCA', 'ICMP', 'TIME', 'ANAL', 'SAVE', 'UQMA', 'ZONE', 'GUAR', 'CNTD', 'PERT', 'SUPP', 'PLOT', 'LGSP', 'DVEL', 'HVEL', 'HBIN', 'SPHB', 'ZANL', 'MONI', 'ZPRF', 'RNGS', 'RHOR', 'OFFG', 'REST', 'FRQS', 'END ', 'trap' /  
  
LSCA = lscale  
ICMP = i component icmp 
##### use setp(N,icmp) to label the following keywords  
>1.NPAR = number of particles in this pop (nsp(icmp))  
2.STAR = start type instructions for given pop  
3.PGRD = grid number for this pop (igrd(icmp))  
4.Z0IN = vertical thickness of pop (z0init(icmp))  
5.CPOP = Population center (comi(i, icmp), i = 1, 3)   
6.VPOP = Population velocity (comi(i, icmp), i = 4, 6)  
7.TAPE = optional disk outer taper (Lztapr(icmp)=.True.)  

TIME = length of timestep (ts)  
ANAL = iphys determines the number of time-steps between model analyses (iphys)  
SAVE = hysical data are to be saved on a file  
>**DANL**: sectoral harmonic coeffcients on each grid ring (p2d and p3d only), danl=.True.  
>**DNST**: the density of particles assigned to the grid, which is usually projected to the mid-plane, dnst = .true.  
>**FRQS**: optional keyword requesting that the values of omega, kappa, and (if 3D) nu be evaluated at a set of radii from azimuthally averaged forces in the mid-plane of the simulation (manual eq. 121). Requires a parameter which is the number of values to be computed per scale length (e.g. 20).  
>**INTG**: total of kinetic and potential energies, virial of Clausius, angular momenta, linear momenta, and center of mass, computed separately for each population of each particles, as well as Ostriker's t value (manual eq. 127).  
>**MOIT**: compute the moment of inertia tensor for non-disk particle populations (manual eq. 122). The particles of each population are divided into 10 groups ranked by their binding energies and the MoI tensor computed for each.
>**PNTL**: the values of potential at every grid point.
>**S3DC**: the values of coefficients of the surface harmonic expansion used in the S3D method only.
>**LVAL**  
>**UQMA**: variable particle mass (uqmass)  
>**ZONE**: number and radii of zones (nzones)  
>**GUAR**: guard radii (nguard)  
>**CNTD**: grid cener option (icstp = time step integral between grid recenterings, j = indicate which rule is to be used to find the center, e.g. ltroid, lbind, lheavy)
>**PERT**: perturbing or central mass option (pertbn).  
>>Option 'BAR' = a rigid bar that is a homogeneous, prolate spheroid assumed centered on the grid and rotating about its minor axis. More values are the bar mass, the bar semi-major axis, its initial value of patter speed, and the bar ellipticity.  
>>Option 'SPIR' = a rigid spiral pattern to perturb the disk. The two further values are the spiral pattern speed and an amplitude scale.  
>>Option 'GNRC' a generic perturber (see manual).
>>Halo: a rigid external perturber, ask for mass, scale, and POSition and VELOcity.  
 
>**SUPP**: supplementary forces (suppl). To supplement the central attraction on each particle with the difference from the theoretical Newtonian attraction and the mean centralattraction of the start.  
>**REST**: recnetering options at outset only (netcom, netlmo).  
>**PLOT**: step interval for plot file (ipict). The maxium number saved for this analysis never exceeds 10^4 in each component.  
>**LGSP**: logarithmic spirals to be determined. Optional keywords are (i) the number of different pitch angles (np), and (ii) the number of sectoral harmonics for this analysis (nm).  
>**DVEL**: control parameters for analysis of disc particle velocity field. Optional keyword requesting the first and second moments be computed in cylindrical polar bins (ndrad, ndang).  
>**HVEL**:control parameters for analysis of halo particle velocity field (vflh, nhrbin, nhzbin).  
>**HBIN**: number of angular momentum bins (angm, maxLz).  
>**SPHB**: spherical Bessel functions (jnmax, jlmax, s3lmax, s3ntm, sphb).  
>**ZANL**: azimuthal mid-plane variations (vertical bending anlysis) (nrz, nmz, zanl).  
>**MONI**: particle monitoring for integral conservation - input is sride (moni, nmskip).  
>**ZPRF**: vertical profile analysis for disk.  
>**RNGS**: rings option, introduce rings of massless test particles.  
>**RHOR**: density profile option (mprho, rhor).  
>**OFFG**: off-grid particle option (offanl, offor, offthf, offmnp).  

Parameters
----
>gvfac2 = gvfac * gvfac  
pmfac = pmass / ( lscale**3 * ts**2 )  

set_scale.f
----
~~~
include 'inc/admin.f'  
c choose scaling to GALAXY units  
      call set_scale  
      lunit = lunit / unit_L  
      munit = munit * 1.e-10 / unit_M  
      vunit = vunit / unit_V
~~~  
Inc/params.f
----
### mcmp
maximum number of distinct mass components
>integer mcmp  
parameter ( mcmp = 10 )  

### mbuff
maximum number of particles in a group for time stepping
>integer mbuff  
parameter ( mbuff = 1000 )

MONI ( itype = 12 )
----
<dl>
	<dt>MONItor</dt>
	<dd>if particle motion is confined to a plane (2D), this option saves <i>E</i>, <i>Lz</i>, <i>x</i>, and <i>v</i> for a fraction of particles. In 3D, only <i>E</i> and the three components of <i>L</i> are saved.</dd>
</dl>  

>nmonit = number of particles monitored  

in 2D  
>ehmon(1, i) = E  
ehmon(2, i) = Lz  
ehmon(3, i) = x  
ehmon(4, i) = y  
ehmon(5, i) = vx  
ehmon(6, i) = vy  

in 3D  
>ehmon(1, i) = E  
ehmon(2, i) = Lz  
ehmon(3, i) = Ly  
ehmon(4, i) = Lz 

The following code is written in _phyprp.f_  

```
if( twod )then
	do i = 1, nmonit
		ehmon( 1, i ) = ehmon( 1, i ) * gvfac**2
		ehmon( 2, i ) = ehmon( 2, i ) * gvfac / lscale
		ehmon( 3, i ) = ehmon( 3, i ) / lscale
		ehmon( 4, i ) = ehmon( 4, i ) / lscale
		ehmon( 5, i ) = ehmon( 5, i ) * gvfac
		ehmon( 6, i ) = ehmon( 6, i ) * gvfac
	end do
	write( nphys )irun, bhol, istep, 6, nmonit
	write( nphys )( ( ehmon( j, i ), j = 1, 6 ), i = 1, nmonit )
else
	do i = 1, nmonit
		ehmon( 1, i ) = ehmon( 1, i ) * gvfac**2
		ehmon( 2, i ) = ehmon( 2, i ) * gvfac / lscale
		ehmon( 3, i ) = ehmon( 3, i ) * gvfac / lscale
		ehmon( 4, i ) = ehmon( 4, i ) * gvfac / lscale
	end do
	write( nphys )irun, bhol, istep, 4, nmonit
	write( nphys )( ( ehmon( j, i ), j = 1, 4 ), i = 1, nmonit )
end if
```

In phyprp.f
----
<dl>
	<dt>phyprp.f</dt>
	<dd>Routine to reduce, and save into the .res file, data accumulated during an analysis step.  
	Summary results are printed if requested.  
	Called from MEASURE.</dd>
</dl>  

Data types processed are:  
>ANGM - the binned distribution of the z-component of angular momentum  
INTG - mainly the global integrals of the system  
LGSP - normalized results of the log spiral analysis  
MONI - specific energies and z-angular momenta of a sample of particles  
RNGS - rings of test particles  
SPHB - normalized results of the spherical Bessel fn analysis  
VFLD - binned means and dispersions of the disc velocity components  
VFLH - binned means and dispersions of the halo velocity components  
ZANL - normalized results of the sectorial bending analysis  

## _Lz_ (ANGM) in _phyprp.f_

## Integrals of the system (INTG) in _phyprp.f_

## Log spiral analysis (LGSP) in _phyprp.f_

## Integrals of a sample of particles (MONI) in _phyprp.f_
ipp = i component 
cm = center of mass  
pp = linear momenta  
ang = angular momenta  
for = total force  
pe = potential energy  
ke = kinetic energy  
ketot = total kinetic energy (ketot = ke( 1 ) + ke( 2 ))  
te = petot + ketot  
claus = virial of Clausius   
petot = total potential (petot = selfe + pe( 2 ) + pe( 1 ))  
<blockquote> selfe = self energy of halo  
pe( 1 ) = disk  
pe( 2 ) = cross term </blockquote>  

### Scaling for each term  
~~~
cm( i, ipp ) = cm( i, ipp ) / ( lscale * popm( ipp ) )
pp( i, ipp ) = pp( i, ipp ) * pmfac * gvfac
for( i, ipp ) = for( i, ipp ) / ( lscale * ts**2 )
	ang( i, ipp ) = ang( i, ipp ) * pmfac / ( lscale**2 * ts )
end do
ke( ipp ) = .5 * ke( ipp ) * pmfac * gvfac2
pe( ipp ) = pe( ipp ) * pmfac * gvfac2
~~~

### Write into files  
~~~
do ipp = 1, ncmp
	n = nspop( ipp )
	if( n .gt. 0 )then
		do i = 1, 3
			cm( i, ipp ) = cm( i, ipp ) / ( lscale * popm( ipp ) )
			pp( i, ipp ) = pp( i, ipp ) * pmfac * gvfac
			for( i, ipp ) = for( i, ipp ) / ( lscale * ts**2 )
			ang( i, ipp ) = ang( i, ipp ) * pmfac / ( lscale**2 * ts )
		end do
		ke( ipp ) = .5 * ke( ipp ) * pmfac * gvfac2
		pe( ipp ) = pe( ipp ) * pmfac * gvfac2
		if( lprint )then
			write( no,'(/i10, '' particles analysed for icmp ='', i4 )' )n, ipp
			write( no, '( '' Total force components'', 3f10.5 )' )( for( i, ipp ), i = 1, 3 )
			write( no, '( ''         Centre of mass'', 3f10.5 )' )( cm( i, ipp ), i = 1, 3 )
			write( no, '( ''  Linear mom components'', 3f10.5 )' )( pp( i, ipp ), i = 1, 3 )
			write( no, '( '' Angular mom components'', 3f10.5 )' )( ang( i, ipp ), i = 1, 3 )
			write( no, '( '' Potential energy'', f10.4 )' )pe( ipp )
			write( no, '( ''   Kinetic energy'', f10.4 )' )ke( ipp )
		end if
	end if
end do
~~~

## Spherical Bessel fn analysis (SPHB) in _phyprp.f_

## Disk velocity & velocity dispersion (VFLD) in _phyprp.f_

## Halo velocity & velocity dispersion (VFLH) in _phyprp.f_

## Sectoral bending analysis (ZANL) in _phyprp.f_  


Grdfld
----
<dl>
<dt>grdfld(i, itype)</dt>
<dd>Gravitational Potential at a P3D grid field point:</dd>
<dd>
<li>i = grid point in mesh(jgrid);</li>
<li>itype = 1, radial force</li>
<li>itype = 2, azimuthal force</li>
<li>itype = 3, vertical force</li>
<li>itype = 4, potential</li>
</dd>
</dl>

Potgrd
----
<dl>
<dt>potgrd.f</dt>
<dd>returns potential on the grid at arbitrary field point by computing the work required from the centre. The work required is determined by computing a line integral of the grid force starting from centre and moving outward in directions parallel to the mesh axes. </dd>
</dl>