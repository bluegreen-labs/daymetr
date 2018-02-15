# A complete set of daymetr unit tests
# to ensure that code changes do not break
# the functionality and download behaviour.
# This allows checks to see if server paths
# are still ok, and if overall the functions
# don't act up.

# standard pixel extraction test
test_that("pixel location download check",{
  
  # download the data
  df = try(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           quiet = TRUE))
  
  # check if no error occured
  expect_true(!inherits(df,"try-error"))
})

# check single tile download
test_that("tile download checks",{
  
  # download the data
  df = try(download_daymet_tiles(path = tempdir(),
                                 param = "tmin"))
  
  # check if no error occured
  expect_true(!inherits(df,"try-error"))
})

# freeform gridded data download check
test_that("freefrom gridded download (ncss) checks",{
  
  # download the data
  df_daily = try(download_daymet_ncss(param = "tmin",
                                frequency = "daily",
                                path = tempdir()))
  
  # download the data
  df_monthly = try(download_daymet_ncss(param = "tmin",
                                      frequency = "monthly",
                                      path = tempdir()))

  # download the data
  df_annual = try(download_daymet_ncss(param = "tmin",
                                        frequency = "annual",
                                        path = tempdir()))
  
  # see if any of the runs failed
  check = any(!inherits(df_daily,"try-error") |
              !inherits(df_monthly,"try-error") |
              !inherits(df_annual,"try-error"))
  
  # check if no error occured
  expect_true(check)
})

# check the calculation of a mean values
test_that("freefrom gridded download (ncss) checks",{
  
  # download the data
  try(download_daymet_ncss(param = c("tmin","tmax"),
                           frequency = "monthly",
                           path = tempdir()))
  
  tmean = try(daymet_grid_tmean(path = tempdir(),
                                product = "monavg",
                                year = 1988))
  
  # check if no error occured
  expect_true(!inherits(tmean,"try-error"))
})

