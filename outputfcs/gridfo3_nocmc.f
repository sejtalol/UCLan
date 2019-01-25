      subroutine gridfo3( x, y, z, fx, fy, fz, pot )
c     modified from ~/weakening/5001/gridfo3.f
      implicit none
c
c calling arguments
      real*8 fx, fy, fz, pot, x, y,z
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
      include 'inc/model.f'
c
c      logical lcmc
c     real*8 m_cmc, cmc_eps 
c     common /cmc/ lcmc, m_cmc, cmc_eps 

c
c externals
      real uofgr
      real*8 frhalo, phihal
c
c local arrays
      integer ic( 8 )
      real acc( 4 ), w( 8 )
c
c local variables
      integer i, itype, iu, iuse, iv, iz, j, k, ncl, jcmp
      logical end
      real du, dudv, dv, dz, gz, r, u, v
      save iuse

      real*8 tx, ty, tz, rr, fr, rsph
      real*8 tmp1, tmp2
c
      if( iuse .eq. 0 )then
        call opnfil( 20, 'fcs', 'unformatted', 'old', 'seq', i )
c read in data
        k = 0
        do itype = 1, 4
          ipt( itype, 1 ) = k
          j = k + 1
          k = k + mesh( 1 )
          read( 20 )( scm( i ), i = j, k )
        end do
        close( 20 )
        iuse = 1
      end if
c convert to grid coordinates
      r = sqrt( x * x + y * y )
      rsph = sqrt( x * x + y * y + z * z)
      u = uofgr( r * lscale )
      v = atan2( y, x ) / alpha
      if( v .lt. 0. )v = v + real( na )
c compute cell number and weights
      iu = u
      iv = v
c  note zm(1) is in internal grid units, so z*lscale is needed
      gz = ( z * lscale + zm( 1 ) ) / dzg
      iz = gz
      iz = max( iz, 0 )
      iz = min( iz, ngz - 2 )
      ncl = ( iu * ngz + iz ) * na + iv + 1
c compute weights
      du = u - real( iu )
      dv = v - real( iv )
      dz = gz - real( iz )
      w( 1 ) = ( 1. - dv ) * ( 1. - dz ) * ( 1. - du )
      w( 2 ) =        dv   * ( 1. - dz ) * ( 1. - du )
      w( 3 ) = ( 1. - dv ) *        dz   * ( 1. - du )
      w( 4 ) =        dv   *        dz   * ( 1. - du )
      w( 5 ) = ( 1. - dv ) * ( 1. - dz ) *        du
      w( 6 ) =        dv   * ( 1. - dz ) *        du
      w( 7 ) = ( 1. - dv ) *        dz   *        du
      w( 8 ) =        dv   *        dz   *        du
c tabulate locations of cell corners in each array
      end = mod( ncl, na ) .eq. 0
      do i = 1, 4
        ic( 1 ) = ipt( i, 1 ) + ncl
        ic( 3 ) = ic( 1 ) + na
        ic( 2 ) = ic( 1 ) + 1
        if( end )ic( 2 ) = ic( 2 ) - na
        ic( 4 ) = ic( 2 ) + na
        ic( 5 ) = ipt( i, 1 ) + ncl + ngz * na
        ic( 7 ) = ic( 5 ) + na
        ic( 6 ) = ic( 5 ) + 1
        if( end )ic( 6 ) = ic( 6 ) - na
        ic( 8 ) = ic( 6 ) + na
c evaluate accelerations and potential
        acc( i ) = 0
        do j = 1, 8
          k = ic( j )
          acc( i ) = acc( i ) + scm( k ) * w( j )
        end do
      end do

c add halo contribution
      jcmp = icmp
      icmp = 2  ! the halo cmp's icmp, which is needed in frhalo.f
      fr = frhalo( rsph ) 
c add halo's contribution only when the rsph is not tiny.
      if( rsph .gt. 1.e-20 ) then
        acc( 1 ) = acc( 1 ) + fr * r / rsph
        acc( 3 ) = acc( 3 ) + fr * z / rsph
        pot = -acc( 4 ) + phihal( rsph )
      else
        pot = -acc( 4 )
      end if

c resolve forces into Fx and Fy
      if( r .gt. 1.e-20 )then
        fx = ( acc( 1 ) * x - acc( 2 ) * y ) / r
        fy = ( acc( 1 ) * y + acc( 2 ) * x ) / r
      else
        fx = 0
        fy = 0
      end if
      fz = acc( 3 )
c restore original icmp
      icmp = jcmp

cccc consider CMC too, did not use the values read from the header, since 
c    it may not be the latest values

c     if ( lcmc ) then
c     CMC at center
c        tx = -x
c        ty = -y
c        tz = -z
c        rr = cmc_eps ** 2 + tx ** 2 + ty ** 2 + tz ** 2
c        rr = ( rr ) ** 1.5
c        fx = fx + m_cmc * tx / rr
c        fy = fy + m_cmc * ty / rr
c        fz = fz + m_cmc * tz / rr
c CMC potential
c        rr = cmc_eps ** 2 + tx ** 2 + ty ** 2 + tz ** 2
c        rr = sqrt( rr ) 
c        pot = pot - m_cmc / rr
c     end if

c      print *, 'force ends'

      return
      end
