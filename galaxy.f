      program galaxy
c  Copyright (C) 2015, Jerry Sellwood
      use aarrays
      implicit none
c main driving program for simulation of an isolated galaxy
c
c    This program is free software: you can redistribute it and/or modify
c    it under the terms of the GNU General Public License as published by
c    the Free Software Foundation, either version 3 of the License, or
c    (at your option) any later version.
c
c    This program is distributed in the hope that it will be useful,
c    but WITHOUT ANY WARRANTY; without even the implied warranty of
c    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
c    GNU General Public License for more details.
c
c    You should have received a copy of the GNU General Public License
c    along with this program.  If not, see <http://www.gnu.org/licenses/>.
c
c A variety of methods are available to determine the gravitational field
c   from the particles, including the possibility of composite combinations
c   of some methods
c
c The simulation must first be set up from a .pcs file by running pcs2dmp,
c   after which this program can be executed as often as desired
c
c common blocks
c
      include 'inc/params.f'
c
      include 'inc/admin.f'
c
      include 'inc/lunits.f'
c
      include 'inc/bdpps.f'
c
      include 'inc/grids.f'
c
      include 'inc/model.f'
c
      include 'inc/supp.f'

c external
      character elapsd*24
c      real potgrd
c
c local variables
      character*80 line
      integer i, ilast, jrun
      real t

      integer n_sp, isnapfreq, ileap, iq,j,k
      parameter (isnapfreq = 1)
c Zhong Liu
      integer m_sp
      parameter(m_sp = 1000000)
      real mass(m_sp), mang(m_sp), mpe(m_sp), mte(m_sp)
      common /myanls/ mass, mang, mpe, mte
      integer nnsn
      real sn( m_sp * 3), snv( m_sp * 3 )
      real tmpcord(3)
c
      call setnag
c read run number from standard input and open main ASCII I/O files
      call getset
      call boilrp
      if( numprocs .gt. 1 )call crash( 'MAIN', 'not parallel version' )
      call second( t )
c read .dat file (ASCII input)
      call msetup
      call grdset
      call setrun
      call getline( ni, line )
      read( line( 11:40 ), * )ilast
c ensure last step is for a top zone
      i = nstep( nzones )
      ilast = i * ( ( ilast - 1 ) / i + 1 )
      close( ni )
c SFP methods
      if( sf2d .or. sf3d )then
        lsfpr = nrtab
        lsfpl = lsfpr * maxn * maxn
        allocate ( sfprad( lsfpr ) )
        allocate ( sfplst( 2, lsfpl ) )
        call sfptab
      else if( lgrd )then
c create or check Greens function file for grid methods
        call greenm( .false. )
      end if
c reserve space
      call setspc
c read the .dmp file
      jrun = irun
      call restrt
      if( irun .ne. jrun )then
        print *, 'Files muddled'
        print *, '.dmp file from run', irun, ' but .dat file for run',
     +             jrun
        call crash( 'GALAXY', 'Files muddled' )
      end if
      print *, 'Run', irun, ' restarted at step no', istep
      print *, 'Run will stop after step ', ilast
c open old results file
      call opnfil( nphys, 'res', 'unformatted', 'old', 'append', i )
c open and write header on new results file if previous open failed
      if( i .ne. 0 )then
        call opnfil( nphys, 'res', 'unformatted', 'new', 'seq', i )
        call hedrec( nphys, .false. )
      end if
      if( dr3d )call masset
c set up the snapshot file
        nnsn = 35
        call opnfil( nnsn, 'snp', 'unformatted', 'unknown','seq', i )
        call hedrec( nnsn, .false. )
c set up flag file
      nflg = 3
      call opnfil( nflg, 'flg', 'formatted', 'unknown', 'seq', i )
      write( nflg, * )ilast
      close( unit = nflg )
      lprint = master
      phys = mod( istep, iphys ) .eq. 0
c main time-step sequence
      do while ( istep .le. ilast )
        lprint = .false.
        lprint = lprint .and. master
        call second( t )
        if( master )print *,
     +                    'Starting step', istep, ' after ', elapsd( t )
c save density information before it is used
        if( phys )call densty
c calculate gravitational field
c if phys = .true. (i.e. analysis step), potential will be calculated
        call findf( phys )
c find coords of the selected particles for their positions and velocities
        if( isnapfreq .ne. 1) stop 'isnapfreq .ne. 1'
        ileap = 1.
        if(phys)then
           do i = 0, lpf, nwpp*ileap
               j=i / ( nwpp * ileap )
               if( j .gt. m_sp ) stop 'j is tooo large'
               do k = 1, 3
                   tmpcord(k) = ptcls(i+k) - 0.5 * ptcls(i+k+3)
               end do
               sn(3*j+1) = (tmpcord(1)-xcen(1,1))/lscale
               sn(3*j+2) = (tmpcord(2)-xcen(2,1))/lscale
               sn(3*j+3) = (tmpcord(3)-xcen(3,1))/lscale
               snv(3*j+1) = ptcls(i+4)*gvfac
               snv(3*j+2) = ptcls(i+5)*gvfac
               snv(3*j+3) = ptcls(i+6)*gvfac
            end do
            n_sp = j + 1
            print*,irun,'SNAP',istep,n_sp,(istep*ts)
c            print*, 'before step', istep
            write(nnsn)irun,'SNAP',istep,n_sp,(istep*ts)
            write(nnsn)(sn(iq),iq=1,n_sp*3)
            write(nnsn)(snv(iq),iq=1,n_sp*3)
        end if
c move particles
        call step
c write down Zhong Jan 28 2019
        if(phys)then
c analysis step
c                do i = 1, n_sp
c                  print *, 'after step'
c                  print *, 'mass=', mass(i), 'ang=', mang(i)
c                  print *, 'pe=', mpe(i), 'te=', mte(i)
c                end do
c                print *, 'after step',istep
c                write(nnsn)irun,'SNAP',istep,n_sp,(istep*ts)
c                write(nnsn)(sn(iq),iq=1,n_sp*3)
c                write(nnsn)(snv(iq),iq=1,n_sp*3)
                write(nnsn)(mass(iq),iq=1, n_sp)
                write(nnsn)(mang(iq),iq=1, n_sp)
                write(nnsn)(mpe(iq),iq=1, n_sp)
                write(nnsn)(mte(iq),iq=1, n_sp)
        end if
        if( phys .and. master )then
          close( unit = nphys )
          call opnfil( nphys, 'res', 'unformatted', 'old', 'append', i )
        end if
c check whether to continue (deleting runxxx.flg causes a graceful stop)
        i = 10
        if( nstep( nzones ) .gt. 1 )i = nstep( nzones )
        if( mod( istep, i ) .eq. 0 )then
          if( master )then
            call opnfil( nflg, 'flg', 'formatted', 'old', 'seq', i )
            if( i .eq. 0 )then
              read( nflg, *, iostat = i )ilast
              close( unit = nflg )
              if( i .ne. 0 )ilast = istep - 1
            else
              ilast = istep - 1
            end if
c ensure last step is for a top zone
            i = nstep( nzones )
            ilast = i * ( ( ilast - 1 ) / i + 1 )
          end if
        end if
c decide whether next step is a main or a sub-step
        phys = mod( istep, iphys ) .eq. 0
        if( ( mod( istep, nstep( nzones ) ) .eq. 0 ) .and.
     +        master )write( no, * )'starting step no ', istep
c update dump file every 25 analysis steps or if this is the last chance
c        if( ( mod( istep, 25 * iphys ) .eq. 0 ) .or.
c     +      ( istep .eq. ilast ) )call dumpp
         if(istep .eq. ilast) call dumpp
      end do
c finish up
      if( master )print *, 'Run stopped after step no', istep - 1
      call second( t )
      if( master )print *, 'Total cpu time was ', elapsd( t )
      stop
      end
