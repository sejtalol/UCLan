c model parameters
c polar grid
      integer ma, mmesh, mg, mr, mz, mst, mwst, mzns
      parameter ( mr = 58, ma = 64, mg = 9, mz = 375,
     +            mmesh = mr * ma * mz,
     +            mst = 2000000, mwst = 8, mzns = 1 )

c s3d grid
c      integer ma, mmesh, mg, mr, mz, mst, mwst, mzns
c      parameter ( mr = 201, ma = 1, mg = 1, mz = 21,
c     +            s3maxld = 4, mst = 10000000, mwst = 9, mzns = 5 )
c      parameter ( s3mtmd = ( ( s3maxld + 2 ) * ( s3maxld + 1 ) ) / 2 )
c      parameter ( mmesh = 4 * s3mtmd * mr )
