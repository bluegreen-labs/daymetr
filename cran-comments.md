Dear CRAN team,

This is a small update to {daymetr}, the interface to the ORNL
digital active archive center API for querying DAYMET climate data.

There was a small change in latest API endpoint, for US island
naming conventions. This needed a processing update. This has now been
implemented and the package is fully functional again.

I have read and agree to the the CRAN policies at:
http://cran.r-project.org/web/packages/policies.html

## test environments, local, CI and r-hub

- Ubuntu 22.04 install on R 4.2.2
- Ubuntu 20.04 on github actions (devel / release)
- windows (release) on github actions and rhub
- MacOS (release) on rhub
- codecove.io code coverage at ~95%

## local / github actions R CMD check results

0 errors | 0 warnings | 0 notes
