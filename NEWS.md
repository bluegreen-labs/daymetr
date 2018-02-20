# daymetr 1.2

* Released to CRAN?
* Added a `NEWS.md` file to track changes to the package
* Included support for monthly and average products in NCSS (netcdf) downloads
* Renaming of functions daymet_tile_tmean() to daymet_grid_tmean()
  - includes support for all gridded data
* Renaming of daymet_tile_offset() to daymet_grid_offset()
  - includes support for ncss data
* Implemented unity checks through testthat for all functions
* Added a netcdf to geotiff conversion script (handy utility)

# daymetr 1.1

* Migration to Daymet V3
* Move to httr for download routines
* Added tile subsetting routines

# daymetr 1.0

* First release