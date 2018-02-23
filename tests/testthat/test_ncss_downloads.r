# Daymetr unit tests

# check single tile download and conversion to geotiff
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
  check = !inherits(df, "try-error") &
    !inherits(df_tif, "try-error") &
    !inherits(df_tif_overwrite, "try-error")
  
  # check if no error occured
  expect_true(check)
})

# freeform gridded data download check
test_that("freefrom gridded download (ncss) checks",{
  
  # download the data
  df_daily = try(download_daymet_ncss(param = "tmin",
                                      frequency = "daily",
                                      path = tempdir(),
                                      silent = TRUE))
  
  # download the data
  df_monthly = try(download_daymet_ncss(param = "tmin",
                                        frequency = "monthly",
                                        path = tempdir(),
                                        silent = TRUE))
  
  # download the data
  df_annual = try(download_daymet_ncss(param = "tmin",
                                       frequency = "annual",
                                       path = tempdir(),
                                       silent = TRUE))
  
  # see if any of the runs failed
  check = !inherits(df_daily, "try-error") &
    !inherits(df_monthly, "try-error") &
    !inherits(df_annual, "try-error")
  
  # check if no error occured
  expect_true(check)
})