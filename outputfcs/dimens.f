      subroutine dimens
      implicit none
c
      include 'inc/dim1.f'
c
c model parameters
      include 'pars.f'
c
c / angmom /
      parameter ( hpar = 150 )
c / bins /
      parameter ( dpar = 100 * 12 * 9 )
c / falcON /
      parameter ( mfalc = 1 )
c / green /
      parameter ( lgpar = mr * mr )
c / hvbins /
      parameter ( hbpar = 35 * 15 * 9 )
c / ldata /
      parameter ( ldpar = 1 )
c / logspi /
      parameter ( mm = 4, mp = 61 )
c / monint /
      parameter ( mmonit = mst / 10 )
c / plot /
      parameter ( mdisp = 200000 )
c / prfrad /
      parameter ( mprfrd = mst )
c / ptcls /
      parameter ( lpar = mwst * mst,
     +            zpar = max( 1, 2 * mmesh * ( mzns - 1 ) ) )
c / rings /
      parameter ( mwring = 6000 )
c / scm /
      parameter ( spar = max( mmesh * ( mzns + 5 ), 28000 ) )
c / sphbsf /
      parameter ( jl = 4, jn = 15 )
c / splcff /
      parameter ( mrspl = 250, mzspl = 250 )
c / trig /
      parameter ( tpar = 2 * ( ma + 2 * mz ) )
c / wrkspc /
      parameter ( wpar = max( 4 * mmesh, 28000, mst ) )
c / zmeana /
c      parameter ( km = 0, kr = 1 )
      parameter ( km = 5, kr = 45 )
c / zrbin /
      parameter ( mbzr = 1, mbzz = 1 )
c
      include 'inc/dim2.f'
      s3ntm = s3mtmd
      return
      end
