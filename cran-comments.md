I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## test environments, local, CI and r-hub

- local OSX / Ubuntu 16.04 install on R 3.4.3
- Ubuntu 14.04 on Travis-CI (devel / release)
- codecove.io code coverage at ~98%
- r-hub release versions (windows, centos, debian, ubuntu, fedora)

## local / Travis CI R CMD check results

0 errors | 0 warnings | 0 notes

## r-hub R CMD check results for:

- Windows Server 2008 R2 SP1, R-release, 32/64 bit
- CentOS 6, stock R from EPEL
- Ubuntu Linux 16.04 LTS, R-release, GCC
- Debian Linux, R-release, GCC

0 errors | 0 warnings | 0 notes

- Fedora

0 errors | 1 warning | 0 notes

Due to the lack of an X11 device (on the docker environment?),
which is then unable to start device PNG. This should not occur on a system
with a properly configured graphical interface.
