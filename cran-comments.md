Dear CRAN team,

This is a small (resubmission) update to {daymetr}, the interface to the ORNL
digital active archive center API for querying DAYMET climate data.

There was a small change in latest API endpoint, for US island
naming conventions. This needed a processing update. This has now been
implemented and the package is fully functional again. This resubmission also
addresses the issues on MacOS, unit test on github actions and rhub
now pass.

Additional changes were made to the citation style to be in line with
current CRAN policy (citentry to bibentry conversion).

Kind regards,
Koen Hufkens

--- 

I have read and agree to the the CRAN policies at:
http://cran.r-project.org/web/packages/policies.html

## local, github actions and r-hub

- Ubuntu 22.04 install on R 4.3
- Ubuntu 20.04 on github actions (devel / release)
- windows (release) on github actions and rhub
- codecove.io code coverage at ~96%

## github actions R CMD check results

0 errors | 0 warnings | 0 notes
