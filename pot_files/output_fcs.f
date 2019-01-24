      program output_fcs
c     JS 2015-08-20 modified from ~/weakening/5001/m_p3getf_v12.f

      implicit none
c     
c     common block
c     
      include 'inc/params.f'
c     
      include 'inc/admin.f'
c     
      include 'inc/grids.f'
c     
      include 'inc/lunits.f'
c     
c     local variables
      character*80 line
      integer i, jrun
      real*8 dtheta
      integer t_st, t_end, ddt
      integer iii
      real*8 omegap
      character dmpfile*60
      include 'inc/pi.f'

      integer nmoments
c     
      integer mtot, ntot, kgrid, kpop, index
      parameter( mtot = 5000000 )
      real x0( mtot ), y0( mtot ), z0( mtot )
      real vx0( mtot ), vy0( mtot ), vz0( mtot )
      integer pop0( mtot )

c     read run number from standard input and open main ASCII I/O files
      call getset
c     store the sizes of the main common arrays
      call dimens
c     read .dat file (ASCII input)
      call msetup
      call grdset
      call setrun
      close( ni )
c     check or create data files or tables for field method
c     call greenm( .false. )

      call switch( 1 )
      call p3grnm( .false. )
      call switch( 0 )

      print *, 'first time step? integer please'
      read(*, *) t_st
      print *, 'last time step? integer please'
      read(*, *) t_end
      print *, 'time step interval? integer please'
      read(*, *) ddt

      ddt = max( ddt , 1 )
      nmoments = ( t_end - t_st ) / ddt + 1
      print *, 'USING ', nmoments, ' moments'

      do iii = t_st, t_end, ddt
         dtheta = 0.d0
         write(dmpfile, '(a3,i4,a4,i4.4)') 'run', irun, '.dmp', iii
c     read the .dmp files
         jrun = irun
         print *, ''
         print *, 'Reading ', dmpfile
         print *, ''
         call restrt_rotate( dmpfile, dtheta )
         
         if( irun .ne. jrun )then
            print *, 'Files muddled'
            print *, '.dmp file from run',irun,' but .dat file for run',
     +           jrun
            call crash( 'output_fcs', 'Files muddled' )
         end if
         print *, 'Run', irun, ' restarted at step no', istep

         kgrid = 1
         kpop = 1
         call readoutdmp(kpop, kgrid, x0, y0, z0, vx0, vy0, vz0,
     +        pop0, mtot, ntot)

c     assign masses for the current particle positions in older versions only
         print = .true.
         phys = mod( istep, iphys ) .eq. 0
         print *, 'phys', phys
*     * JS 02-28-2003 The following is important, otherwise will use old mass array
c     flag old mass arrays as useless
         if( nzones .gt. 1 )then
            do i = 2, nzones
               lstep( 1, i - 1 ) = -1
               lstep( 2, i - 1 ) = -1
            end do
         end if

         call masset 

c     main time-step sequence
         iwarn = 0
 1       print = .false.
         print *, 'Starting step', istep
c     calculate gravitational field
c     call findf( phys )

c     Do we need these two lines? then also need inlcude grids.f
         jrad(mzone) = 1
         krad(mzone) = nr(1)

         call switch( 1 )
         call mzfield( phys )
         call switch( 0 )

         call fldout3(iii)

      end do

      end

      include 'dimens.f'

      include 'fldout3.f'
      include 'restrt_rotate.f'
      include 'readoutdmp.f'

      subroutine polcat
      print *, 'Skipping polcat'
      return
      end

