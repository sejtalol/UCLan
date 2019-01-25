      program testf

      include 'inc/params.f'
      include 'inc/admin.f'
      include 'inc/model.f'

      real*8 x, y, z, fx, fy, fz, phi

c     read data files and set initial variable, for later use in 
c     force+pot evaluation
      call getset
      call dimens
c     read .dat file (ASCII input)
      call msetup
      call grdset
      call setrun

      x = 2.d0
      y = 2.d0
      z = 0.d0

      call gridfo3(x, y, z, fx, fy, fz, phi)

      print *, x, y, z, fx, fy, fz, phi
      end

      include 'gridfo3_nocmc.f'
      include 'dimens.f'

