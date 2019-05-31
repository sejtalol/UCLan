      program mytest
      implicit none

      integer i,j,k
      integer ios
      integer m_sp, n_sp, snp, irun, istep, ileap, iq
      integer nnsn,nnch
      parameter( m_sp =1000000)
      real sn(m_sp*3), snv(m_sp*3)
      real mass(m_sp), mang(m_sp), mpe(m_sp), mte(m_sp)
      real tmptime, tmpa
      integer nw, tmpn
      parameter( nw = 10000)
      real myrad(nw), myomega(nw), mykappa(nw), mykappaz(nw)
      integer setstep, iunit
      character*20 filename
      character*3 arg
      real*8 pi
c      parameter( rs = 8.55, vs=220, lfac = 1.9 , vscale=310 ,ls0 = 20.)
c      parameter( setstep= 20000 )
c      parameter( pi =3.141592653589793238462643d0)
      
      call get_command_argument(1,arg)
      read (arg,'(I3)') iunit
      setstep = iunit * 40
c here iunit is the time
c      print *,iunit

      nnsn=35
      open (nnsn,file='run5018.snp',form='unformatted')

      read(nnsn)
      read(nnsn)
      read(nnsn)
      read(nnsn)
c      read(nnsn)irun,snp,istep,n_sp,tmptime
c      print *, snp, istep, n_sp
c      read(nnsn)(sn(iq),iq=1,n_sp*3)
c      read(nnsn)(snv(iq),iq=1,n_sp*3)

c      read(nnsn)tmpn
c      do i = 1, tmpn, 1
c        read(nnsn) istep, myrad(i), myomega(i), mykappa(i), mykappaz(i)
c      end do

c      do i=1,n_sp,1
c         ri(i)=sqrt(sn(3*i-2)*sn(3*i-2)+sn(3*i-1)*sn(3*i-1))
c      enddo

       nnch=36
       write(filename,"('ptcls_info_t',I3.3,'.dat')")iunit
       open(nnch,file=filename,status='unknown')

       do 
        read(nnsn,iostat=ios)irun,snp,istep,n_sp,tmptime
c        print *, snp, istep, n_sp
        if(istep .gt. setstep )exit
        read(nnsn)(sn(iq),iq=1,n_sp*3)
        read(nnsn)(snv(iq),iq=1,n_sp*3)
        read(nnsn)(mass(iq),iq=1,n_sp)
        read(nnsn)(mang(iq),iq=1,n_sp)
        read(nnsn)(mpe(iq),iq=1,n_sp)
        read(nnsn)(mte(iq),iq=1,n_sp)

        read(nnsn) tmpn
c        print *, tmpn
        do i = 1, tmpn, 1
                read(nnsn) myrad(i), myomega(i), mykappa(i), mykappaz(i)
        end do
c        print *,istep
       enddo

       do i=1,n_sp,1
c calculate the angular momentum!
c        tmpa = mass(i) * (sn(3*i-2)*snv(3*i-1)-sn(3*i-1)*snv(3*i-2) )
c        print *, mass(i)
        write(nnch,10) sn(3*i-2),sn(3*i-1),snv(3*i-2),snv(3*i-1),       &
     &  snv(3*i), mass(i), mpe(i)
10      format(2X,F15.8,F15.8,F15.8,F15.8,F15.8,F15.8,F15.8)
       enddo

       end
