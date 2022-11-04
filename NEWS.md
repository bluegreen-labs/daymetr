# daymetr 1.7

* API endpoint update with v4 release
* move to terra

# daymetr 1.6

* SSL CA override to deal with stale certificates at ORNL
* new website layout
* removed website ping function and check

# daymetr 1.5

* better error trapping in single pixel downloads using http status codes
* migration to bluegreen-labs project page
* R >= 3.6 requirement
* removed faulty keywords
* migration to github actions instead of Travis CI
* migration to v4 API endpoints
* switch from sp to sf (GDAL3 / PROJ6)

# daymetr 1.4.1

* fix bug in the tiles download function
  - badly formatted url caused all tiles except the first to fail

# daymetr 1.4

* include Hawaii and Puerto Rico mosaics into the NCSS subset function
* switch from nested list structure to a tidy data frame (tibble) as a default
* changed = to <-
* use http_error() instead of try() wrappers
* trap server errors in unit checks, will skip if service is down
* skip ancillary functions on CRAN (conflicts and issues)
* code cov back to ~94% (local / Travis), 57% on CRAN builds

# daymetr 1.3.3

* future proofed the read_daymet() function, to make things worry free
* new addition of a function by calc_nd() to calculate nr. days which adhere to certain conditions
* additional platform checks using r-hub (tip by Colin Fay)

# daymetr 1.3.2

* Move to new API base url
* Simplified download commands + error trapping
* Simplified the extraction of header meta-data
* new function to aggregate gridded data: daymet_grid_agg()
* robust header detection until # prefix is in place
* new function to read in single pixel data: read_daymet() 

# daymetr 1.3.1

* Formal CRAN submission
* additional documentation

# daymetr 1.3.0

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