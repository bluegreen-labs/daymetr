Dear CRAN team,

This is a small (resubmission) update to {daymetr}, the interface to the ORNL
digital active archive center API for querying DAYMET climate data.

There was a small change in latest API endpoint, for US island
naming conventions. This needed a processing update. This has now been
implemented and the package is fully functional again.

Additional changes were made to the citation style to be in line with
current CRAN policy. Issues do exist with macOS on the systems I use for
testing. Thsi is due to either compilation errors or limited netcdf support
on Github Actions and rhub (see log file link below).

https://builder.r-hub.io/status/original/daymetr_1.7.1.tar.gz-02510e69bf5f4a11b0a37477619efd66

Ignoring this is at your discretion, as these seem to be non package related
issues (however hard to confirm given the use of VM state of libraries)

--- 

I have read and agree to the the CRAN policies at:
http://cran.r-project.org/web/packages/policies.html

## local, github actions and r-hub

- Ubuntu 22.04 install on R 4.2.2
- Ubuntu 20.04 on github actions (devel / release)
- windows (release) on github actions and rhub
- MacOS (release) on rhub (FAILS, see notes below)
- codecove.io code coverage at ~95%

## rhub / github actions R CMD check results

0 errors | 0 warnings | 0 notes
