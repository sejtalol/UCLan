      subroutine fldout3( itime )
      implicit none
      integer itime
c
c common blocks
c
      include 'inc/params.f'
c
      include 'inc/admin.f'
c
      include 'inc/grids.f'
c
      include 'inc/scm.f'
c
      real rad( 101 )
      common / trcdent / rad
c
c external
      external cdentr
c
c local variables
      integer ibase, ipm, ips, ispac, itype, jrf, jrs, krf, krs, ntypes
      integer i, j, k, l, m, n, nsct
      real a( 10 ), area, c, freq, grofu, r1, r2, sigmaf, xn, xx
      character fcsfile*80
c

c      call opnfil( 20, 'fcs', 'unformatted', 'unknown', 'seq', i )
      write(fcsfile, '(a3,i4,a4,i4.4)') 'run', irun, '.fcs', itime
      open( 20, file = fcsfile, status = 'unknown',
     +          form = 'unformatted', iostat = i )

c set up table of radii for plotting only
      do i = 1, nr( 1 )
        r2 = i
        rad( i ) = grofu( r2 - 1. )
      end do
c$$$      call jsbgn
      do itype = 1, 4
        ips = ipt( itype, 1 )
        ipm = ipt( 5, 1 )
c scale to external units
        c = 1. / ( lscale * ts**2 )
        if( itype .eq. 4 )c = 1. / ( lscale * ts )**2
        do i = 1, mesh( 1 )
          scm( ipm + i ) = c * scm( ips + i )
        end do
c write out values
        write( 20 )( scm( i ), i = ipm + 1, ipm + mesh( 1 ) )

c  comment out the figure-plotting diagnosis.
c$$$        call jspage
c$$$        xx = rgrid
c$$$        call jsescl( -xx, xx, -xx, xx )
c$$$        call jsaxis( 'x', 'x', 1 )
c$$$        call jsaxis( 'y', 'y', 1 )
c$$$        call jscirc( 0., 0., xx )
c$$$        xx = -100
c$$$        xn = 100
c$$$        do i = 1, nr * na
c$$$          if( itype .eq. 1 )scm( ipm + i ) = -scm( ipm + i )
c$$$          xx = max( xx, scm( ipm + i ) )
c$$$          xn = min( xx, scm( ipm + i ) )
c$$$        end do
c$$$        print *, itype, ', min & max vals', xn, xx
c$$$        xx = max( xx, -xn )
c$$$        n = 5
c$$$        do i = 1, n
c$$$          a( i ) = ( real( i ) - .5 ) * xx / real( n )
c$$$        end do
c$$$        call jscont( scm( ipm + 1 ), na, nr, a, n, cdentr )
c$$$c        do i = 1, n
c$$$c          a( i ) = -a( 1 )
c$$$c        end do
c$$$c        call jsdash( 0, 1, 0, 1 )
c$$$c        call jscont( scm( ipm + 1 ), na, nr, a, n, cdentr )
c$$$c        call jsdash( 0, 0, 0, 0 )

      end do
      close( 20 )
c$$$      call jsend
c      stop
      end
