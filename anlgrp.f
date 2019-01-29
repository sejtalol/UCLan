      subroutine anlgrp( jst, nact, lprop, prop, nbplot, dispy,
     +                   lglen, alspi, jlen, besc, nLbin, nLa,
     +                   lzman, zman, lzpr, zpbin, lmoni, ehmon,
     +                   nwring, wring, llz, Lzval )
c  Copyright (C) 2014, Jerry Sellwood
c  revise Zhong 2019
      use aarrays
      implicit none
c main analysis routine: it adds the contribution of current group of
c   particles to many different analysis procedures.
c For RVLF time centering, it needs to be called right after the
c   group has been accelerated, because that is the only moment when it is
c   possible to form time-centred velocities.  It is still called at this
c   moment for APLF time centering - but only so that (non-centered)
c   acceleration components can be included in ICHECK
c
c subroutine CENCDS evaluates Cartesian time centered coordinates that are
c   completely independent of the integration scheme, to save having to
c   worry about which scheme is being used in each analysis routine
c
c calling arguments
      integer jlen, jst, lglen, llz, lmoni, lprop, lzman, lzpr, nact
      integer nbplot, nlbin, nwring
      integer nLa( nact, nLbin )
      real alspi( nact, 2, lglen ), besc( nact, 2, jlen )
      real dispy( nbplot ), ehmon( 6, lmoni ), Lzval( llz )
      real prop( nact, lprop ), wring( nwring )
      real zman( nact, 2, lzman ), zpbin( nact, lzpr )
c
c common blocks
c
      include 'inc/params.f'
c
      include 'inc/admin.f'
c
      include 'inc/buffer.f'
c
      include 'inc/grids.f'
c
c externals
      real axipot, halpot, phcorr, satpot
c
c local allocatable array for time centered coordinates
      real, allocatable :: coords( :,: )
c
c common blocks by Zhong
      integer m_sp
      parameter(m_sp = 1000000)
      real*8 mass(m_sp),mang(m_sp), mpe(m_sp), mte(m_sp)
      common /myanls/ mass, mang, mpe, mte
c local variable (see emngrp.f)
      integer is, i, j, kgrd
      real Lz, ke, pe, x, y, z, vx, vy, vz, r
c      logical lfirst
c      save lfirst
c      data lfirst / .true. /
c
c allocate space
      allocate ( coords( 6, mbuff ) )
c get time-centered coordindates
      call cencds( jst, coords )
c
c Zhong Liu save results before the movement
c work through group
      do is = 1, jst
c ignore test particles
c        if( .not. testp( iflag( is ) ))then
c            kgrd = label( is )
c compute particle's specific energy
            ke = 0
            pe = 0
            r = 0
            do i = 1, ndimen
c the coords are already time-centered in cencds.f
               r = r + (coords( i, is ) - xcen( i, 1 ) )**2
               ke = ke + .5 * coords( i + ndimen, is )**2
            end do
            r = sqrt( r )
c exclude particles far from the current center (not doing here)
c            if( r .lt. lscale)then
               pe = pe + gpot( is )
               if( pertbn )pe = pe + satpot( is )
               if( fixrad .or. suppl .or. rigidh )then
                   r = 0
                   do i = 1, ndimen
                     r = r + coords( i, is)**2
                   end do
                   r = sqrt( r )
                   if( fixrad )pe = pe + axipot( r )
                   if( suppl  )pe = pe + phcorr( r )
                   if( rigidh )pe = pe + halpot( r )
                end if
c angular momenta
                Lz = coords( ndimen + 2, is ) * coords( 1, is ) -
     +         coords( ndimen + 1, is ) * coords( 2, is)
                Lz = pwt( is ) * Lz
c        end if
        j = loc( is ) / nwpp + 1
c should check this angular momentum
        mang( j ) = Lz * gvfac / lscale
        mpe( j ) = pe * gvfac**2
        mte( j ) = ( pe + ke ) * gvfac**2
        mass( j ) = pwt( is )
c analysis step
c        print *, '1.mass=', mass(j) , 'ang=', mang(j), 'mte', mte(j)
      end do     
c
c  integral conservation check
       call icheck( jst, coords, lmoni, ehmon, llz, Lzval )
c
c create picture file if requested
      if( plot )call disply( jst, coords, nbplot, dispy )
c
c adjust coordinates for grid shift
      if( centrd )then
        do is = 1, jst
          coords( 1, is ) = coords( 1, is ) - xcen( 1, jlist )
          coords( 2, is ) = coords( 2, is ) - xcen( 2, jlist )
          rr( is ) = coords( 1, is )**2 + coords( 2, is )**2
          if( threed )then
            coords( 3, is ) = coords( 3, is ) - xcen( 3, jlist )
            rr( is ) = rr( is ) + coords( 3, is )**2
          end if
          rr( is ) = sqrt( rr( is ) )
        end do
      end if
c
c contributions to velocity fields and angular momentum distribution
      call vlflda( jst, coords, nact, lprop, prop, nLbin, nLa )
c
c log spiral analysis of disc particles
      if( lgsp )call lgspia( jst, coords, nact, lglen, alspi )
c
c z distortion analysis of disc particles
      if( zanl )call zbenda( jst, coords, nact, lzman, zman )
c
c spherical Bessel function analysis of halo particles
      if( sphb )call sphbja( jst, coords, nact, jlen, besc )
c
c z-density profile of disc particles
      if( zprf )call zprofa( jst, coords, nact, lzpr, zpbin )
c
c rings option
      if( rngs )call ringsa( jst, coords, nwring, wring )
c
c return allocated space
      deallocate ( coords )
      return
      end
