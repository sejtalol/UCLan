      subroutine readoutdmp( kpop, kgrid, 
     +     x0, y0, z0, vx0, vy0, vz0, pop0, mtot, ntot )
      implicit none
cc    I have taken tare of the time-centering of postions. JS Feb-09-2007

      integer kpop, ntot, kgrid, mtot
c     kgrid is used to determine xcen( X, kgrid )
      real x0( mtot ), y0( mtot ), z0( mtot )
      real vx0( mtot ), vy0( mtot ), vz0( mtot )
      integer pop0( mtot )

c     
c     common blocks
c     
      include 'inc/params.f'
c     
      include 'inc/admin.f'
c     
      include 'inc/buffer.f'
c     
      include 'inc/ptcls.f'
c     
c      include 'inc/dim1.f'
c     externals
      logical gtlogl
      real grofu, version, tsfac

      integer is, it, jst, nsel, i
      real tsfac0
      logical all


      all = .false.
      if( kpop .le. 0 ) all = .true.
      if( kgrid .le. 0 .or. kgrid .ge. 10 ) stop 'check your kgrid'

      ntot = 0
      nsel = 0
      print *, 'XCEN  ', xcen( 1, kgrid ), xcen( 2, kgrid )
     +     ,xcen( 3, kgrid ), centrd
c      print *, '   mtot      ', mtot
c     work through all lists except that of particles off the grid
      do ilist = 1, nlists - 1
         call interpret

c     JS Oct-10-2008, tsfac0 is necessary when we have more than one zones, or having gaurd radii.
         tsfac0 = tsfac( izone )
         gvfac = 1. / ( lscale * ts ) / tsfac0

         inext = islist( 1, ilist, 1 )
         do while ( inext .ge. 0 )
            call gather( jst )
c     pick out desired particles
            do is = 1, jst
               ntot = ntot + 1
               if( (iflag( is ) .eq. kpop) .or. all )then 
                  nsel = nsel + 1
                  pop0( nsel ) = iflag( is )

c     Here x_{istep+0.5} and v_{istep}, the positions are half step ahead of velocities. So you just back up the positions by half step while leave the vel alone. 
                  do i = 1, 3
                    oldc( i, is ) = oldc( i, is ) - 0.5*oldc( i+3, is )
                  end do

                  x0( nsel ) = ( oldc( 1, is ) - xcen( 1, kgrid ) ) 
     +                 / lscale
                  y0( nsel ) = ( oldc( 2, is ) - xcen( 2, kgrid ) )
     +                 / lscale
                  z0( nsel ) = ( oldc( 3, is ) - xcen( 3, kgrid ) )
     +                 / lscale
                  vx0( nsel ) = oldc( 4, is ) * gvfac
                  vy0( nsel ) = oldc( 5, is ) * gvfac
                  vz0( nsel ) = oldc( 6, is ) * gvfac
               end if
            end do
         end do
      end do

      print *, nsel, ' particles selected out of ', ntot
      ntot = nsel

      end 
