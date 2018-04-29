I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## test environments, local and r-hub

- local OSX / Ubuntu 16.04 install on R 3.4.3
- Ubuntu 14.04 on Travis-CI (devel / release)
- codecove.io code coverage at ~97%
- Windows Server 2008 R2 SP1, R-release, 32/64 bit, i.e. check_on_windows()
- Debian Linux, R-release, GCC, i.e. check_on_linux()

## local / Travis CI R CMD check results

0 errors | 0 warnings | 0 notes

## r-hub R CMD check results

0 errors | 0 warnings | 1 note

Namespaces in Imports field not imported from:
  ‘ncdf4’ ‘rgdal’ ‘rgeos’

Due to dependencies in the raster library which aren't enforced.
[mentioned libraries aren't installed by default although used]