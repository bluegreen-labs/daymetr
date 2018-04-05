# daymetr 1.3

* Added vignettes as additional documentation
* Included support for monthly and average products in NCSS (netcdf) downloads
* Included netcdf to geotiff conversion script (handy utility)
* Renaming of functions daymet_tile_tmean() to daymet_grid_tmean()
  - includes support for all gridded data
* Renaming of daymet_tile_offset() to daymet_grid_offset()
  - includes support for ncss data
* Implemented unity checks through testthat for all functions
* Included code coverage checks and status badge [![codecov](https://codecov.io/gh/khufkens/daymetr/branch/master/graph/badge.svg)](https://codecov.io/gh/khufkens/daymetr)
* Travis CI warnings == errors

# daymetr 1.2

* Added a `NEWS.md` file to track changes to the package
* Added NCSS subset support
# daymetr 1.1

* Migration to Daymet V3
* Move to httr for download routines
* Added tile subsetting routines

# daymetr 1.0

* First release