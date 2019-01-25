      subroutine restrt_rotate( dmpfile, dtheta ) 
      implicit none
      character*(*) dmpfile
c     dtheta should be in radians, not degrees
      real*8 dtheta
c Restores the information from a previous dump to resume the simulation.
c Many parameters are read in by a call to subroutine HEDREC, after which
c   this routine reads back the:
c      starting points for the linked lists
c      table of supplementary forces and potentials (if needed)
c      most recent mass array (to enable a perfect restart)
c      old mass arrays (only if multiple time step zones are in use)
c   and finally
c      the current phase space positions of all the particles
c
c common blocks
c
      include 'inc/params.f'
c
      include 'inc/admin.f'
c
      include 'inc/anlsis.f'
c
      include 'inc/bdpps.f'
c
      include 'inc/buffer.f'
c
      include 'inc/grids.f'
c
      include 'inc/lunits.f'
c
      include 'inc/model.f'
c
      include 'inc/ptcls.f'
c
      include 'inc/scm.f'
c
      include 'inc/supp.f'
c
c external
      real version
c
c local arrays
      integer nia, nxa
      parameter ( nia = 9, nxa = 4 )
      integer ia( nia )
      real*8 xa( nxa )
c
c local variables
      integer i, ih, izon, j, k, l, n
      real dt
      real*8 ttx, tty, cc, ss
      integer pnext
      include 'inc/pi.f'
c
c check header
c      call opnfil( ndump, 'dmp', 'unformatted', 'old', 'seq', i )
c      if( i .ne. 0 )call crash( 'RESTRT', 'No .dmp file found' )
      open(ndump, file=dmpfile, form='unformatted', status='old')
      call hedrec( ndump, .true. )
      if( version( 0 ) .lt. 10.999 )call crash( 'RESTRT',
     +                       'old .dmp files not backwards compatible' )
c set self-force tables etc
      call slfset
c restore pointer and halo data
      read( ndump )irun, istep, noff, ncen, nshort, nrsup, suppl, n,
     +       ( islist( 1, i, 1 ), i = 1, nlists ), angoff, amoff, rguard
      if( suppl )read( ndump )hrfac,
     +                     ( ( htab( j, i ), j = 1, 3 ), i = 1, nrsup )
      if( pertbn )then
        if( explum )then
          read( ndump )pertbr
        else if( extbar )then
          read( ndump )omegab, bphase, accptb( 1 ),
     +             ( accpz( 1, 1, i ), accpz( 1, 2, i ), i = 1, nzones )
        else
          call crash( 'RESTRT', 'Unrecognized perturber' )
        end if
        if( nzones .gt. 1 )read( ndump )
     +               ( lstep( 1, i ), lstep( 2, i ), i = 1, nzones - 1 )
      end if
c read moving grid centre information and initialize
      if( centrd )then
        read( ndump )icstp, kci, ipast, pastp
        call cenpth
c estimate position of grid center
        dt = real( istep - ipast( 1 ) ) / real( icstp )
        do j = 1, ngrid
          do i = 1, 3
            xcen( i, j ) = cenfit( 1, i, j ) * dt +
     +                     cenfit( 2, i, j ) * ( 1. - dt )
          end do
        end do
      end if
c restore random generator information
      read( ndump )ia, xa
      call g05cgf( ia, nia, xa, nxa, i )
c restore most recent mass array
      do ih = 1, ngrid
        call switch( ih )
        if( ncode .gt. 10 )call crash( 'RESTRT', 'Unrecognised method' )
        if( .not. ( none .or. tr3d ) )then
c set pointers
          if( sf2d )then
            j = ipt( 1, ih ) + 1
            k = ipt( 1, ih ) + mesh( ih ) + 1
          else if( sf3d )then
            j = ipt( 1, ih ) + 1
            k = ipt( 1, ih ) + 2 * mesh( ih )
          else if( p2d .or. c2d .or. p3a )then
            j = ipt( 4, ih ) + 1
            k = ipt( 4, ih ) + mesh( ih )
          else if( p3d )then
            j = ipt( 5, ih ) + 1
            k = ipt( 5, ih ) + mesh( ih )
          else if( c3d .or. s3d .or. scf )then
            j = ipt( 1, ih ) + 1
            k = ipt( 1, ih ) + mesh( ih )
          else
            call crash( 'RESTRT', 'Mass array pointers not set' )
          end if
          if( scf .or. sf2d .or. sf3d )then
            read( ndump )( scm2( i ), i = j, k )
            if( sf2d )then
              newmaxr = scm2( k )
              maxr = max( newmaxr, minmaxr )
            end if
          else
            read( ndump )( scm( i ), i = j, k )
          end if
c extra array for hybrid method
          if( hybrid .and. ( ih .gt. 1 ) )then
            if( s3d )then
              j = ipt( 2 + nzones, ih ) + 1
              k = ipt( 2 + nzones, ih ) + mesh( ih )
            else
              call crash( 'RESTRT', '2nd mass array pointers not set' )
            end if
            read( ndump )( scm( i ), i = j, k )
          end if
c set jrad & krad
          if( p2d .or. p3d )then
            do i = 1, nzones
              jrad( i ) = 1
              krad( i ) = nr( ih )
            end do
          end if
        end if
      end do
      call switch( 0 )
c number of zones for next step
      do i = 1, nzones
        if( mod( istep, nstep( i ) ) .eq. 0 )mzone = i
      end do
c restore old mass arrays (if any)
      if( ( nzones .gt. 1 ) .and. ( .not. none ) )then
        do ih = 1, ngrid
          do izon = 2, nzones
            do l = 1, 2
              j = lpt( l, izon - 1, ih )
              k = j + mesh( ih )
              if( scf )k = k + mesh( ih )
              j = j + 1
              read( ndump )lstep( l, izon - 1 ),
     +                      ( zmass( i ), i = j, k )
              if( hybrid .and. ( ih .eq. 2 ) )then
                j = lpt( l, izon - 1, 3 )
                k = j + mesh( ih )
                if( scf )k = k + mesh( ih )
                j = j + 1
                read( ndump )lstep( l, izon - 1 ),
     +                        ( zmass( i ), i = j, k )
              end if
            end do
          end do
        end do
      end if
c
      if( parallel )call crash( 'RESTRT', 'parallel version needed' )
c recover particle data
      lpf = nbod * nwpp
      l = n * nwpp
      k = 0
    1   j = k + 1
        k = k + l
        k = min( k, lpf )
        read( ndump )( ptcls( i ), i = j, k )
      if( k .lt. lpf )go to 1
c recover offgrid particle index list if present
      if( offfor .and. ( noff .gt. 0 ) )read( ndump )
     +                                       ( loco( i ), i = 1, noff )

      cc = cos ( dtheta )
      ss = sin ( dtheta )
      do i = 1, nbod
         pnext = (i-1) * nwpp
c     still in internal uints!
         ttx =  ptcls( pnext + 1 )
         tty =  ptcls( pnext + 2 )
         ptcls( pnext + 1 ) = ttx * cc + tty * ss
         ptcls( pnext + 2 ) = tty * cc - ttx * ss
c     Note Vx and Vy need to be rotated as well!
         ttx =  ptcls( pnext + 4 )
         tty =  ptcls( pnext + 5 )
         ptcls( pnext + 4 ) = ttx * cc + tty * ss
         ptcls( pnext + 5 ) = tty * cc - ttx * ss
      end do

      print *, 'ROTATED', dtheta*180.d0/pi, ' degrees'

      close( unit = ndump )
      return
      end
