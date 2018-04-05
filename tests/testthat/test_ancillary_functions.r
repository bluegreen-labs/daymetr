# Daymetr unit tests

# grid offset routine
test_that("check offset routine",{
  
  # download the data
  df_daily = try(download_daymet_ncss(param = "tmin",
                                      frequency = "daily",
                                      path = tempdir(), 
                                      start = 1981,
                                      end = 1982,
                                      silent = TRUE))
  
  # create a stack of the downloaded data
  st = raster::stack(paste(tempdir(),
                           c("tmin_daily_1981_ncss.nc",
                             "tmin_daily_1982_ncss.nc"),
                           sep = "/"))
  
  # correct offset
  offset_check = try(daymet_grid_offset(st))
  
  # corrupted offset
  offset_check_corrupt = try(daymet_grid_offset(raster::dropLayer(st, 1)))
  
  # see if any of the runs failed
  check = !inherits(df_daily,"try-error") &
    !inherits(offset_check,"try-error") &
    inherits(offset_check_corrupt, "try-error") # no ! reversal
  
  # check if no error occured
  expect_true(check)
})

# check the calculation of a mean values
test_that("tmean grid checks",{
  
  # download the data
  try(download_daymet_ncss(param = c("tmin","tmax"),
                           frequency = "monthly",
                           path = tempdir(),
                           silent = TRUE))
  
  try(download_daymet_tiles(path = tempdir(),
                            param = c("tmin","tmax"),
                            silent = TRUE))
  
  # run the function which calculates mean temperature
  # for a gridded daymet product
  tmean_ncss = try(daymet_grid_tmean(path = tempdir(),
                                     product = "monavg",
                                     year = 1980))
  
  tmean_ncss_internal = try(daymet_grid_tmean(path = tempdir(),
                                     product = "monavg",
                                     year = 1980,
                                     internal = TRUE))
  
  tmean_tile = try(daymet_grid_tmean(path = tempdir(),
                                     product = 9753,
                                     year = 1980))
  
  tmean_no_year = try(daymet_grid_tmean(path = tempdir(),
                                     product = 9753,
                                     year = NULL))
  
  # remove one file of the temperature pair (tmin)
  file.remove(list.files(tempdir(),
                         "*tmin*",
                         full.names = TRUE))
  
  # try to do a tmean composite again (will fail)
  tmean_missing_data = try(daymet_grid_tmean(path = tempdir(),
                                                  product = "monavg",
                                                  year = 1980))
  
  # see if any of the runs failed
  check = !inherits(tmean_ncss, "try-error") &
          !inherits(tmean_ncss_internal, "try-error") &
          inherits(tmean_no_year,"try-error") &
          inherits(tmean_missing_data,"try-error") &
          !inherits(tmean_tile, "try-error")
  
  # check if no error occured
  expect_true(check)
})

# check conversion to geotiff
test_that("tile download and format conversion checks",{
  
  # download the data
  try(download_daymet_ncss(param = "tmin",
                           frequency = "daily",
                           path = tempdir(),
                           silent = TRUE))
  
  # download the data
  
  try(download_daymet_ncss(param = "tmin",
                           frequency = "monthly",
                           path = tempdir(),
                           silent = TRUE))
  
  # download the data
  try(download_daymet_ncss(param = "tmin",
                           frequency = "annual",
                           path = tempdir(),
                           silent = TRUE))
  
  # check conversion to geotiff of all
  # data types (daily, monthly, annual)
  df_tif_overwrite = try(nc2tif(path = tempdir(),
                                overwrite = TRUE))
  
  # check conversion to geotiff of all
  # data types (daily, monthly, annual)
  df_tif = try(nc2tif(path = tempdir(),
                      overwrite = FALSE))
  
  # see if any of the runs failed
  check = !inherits(df_tif, "try-error") &
          !inherits(df_tif_overwrite, "try-error")
  
  # check if no error occured
  expect_true(check)
})


