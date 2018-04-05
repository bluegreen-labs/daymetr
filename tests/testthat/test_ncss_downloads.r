# Daymetr unit tests

# freeform gridded data download check
test_that("freefrom gridded download (ncss) checks",{
  
  # download daily data
  df_daily = try(download_daymet_ncss(param = "tmin",
                                      frequency = "daily",
                                      path = tempdir(),
                                      silent = TRUE,
                                      force = TRUE))
  
  # download monthly data, bad location
  df_monthly_loc = try(download_daymet_ncss(location = c(34, -82, 33.75),
                                        param = "tmin",
                                        frequency = "monthly",
                                        path = tempdir(),
                                        silent = TRUE))

  # download monthly data
  df_monthly = try(download_daymet_ncss(param = "tmin",
                                        frequency = "monthly",
                                        path = tempdir(),
                                        silent = TRUE))
  
  # download out of range checks for years (min)
  df_monthly_min_year = try(download_daymet_ncss(param = "tmin",
                                        frequency = "monthly",
                                        start = 1970,
                                        path = tempdir(),
                                        silent = TRUE))
  
  # download out of range checks for years (max)
  df_monthly_max_year = try(download_daymet_ncss(param = "tmin",
                                        frequency = "monthly",
                                        end = 2100,
                                        path = tempdir(),
                                        silent = TRUE))
  
  # download annual data
  df_annual = try(download_daymet_ncss(param = "tmin",
                                       frequency = "annual",
                                       path = tempdir(),
                                       silent = TRUE))
  
  # download annual data for all data types
  df_all_annual = try(download_daymet_ncss(param = "ALL",
                                           frequency = "annual",
                                           path = tempdir(),
                                           silent = FALSE))
  # download the data
  df_all_daily = try(download_daymet_ncss(param = "ALL",
                                          frequency = "daily",
                                          path = tempdir(),
                                          silent = FALSE))
  
  # see if any of the runs failed
  check = !inherits(df_daily, "try-error") &
          !inherits(df_monthly, "try-error") &
          inherits(df_monthly_loc, "try-error") &
          !inherits(df_annual, "try-error") &
          !inherits(df_all_annual, "try-error") &
          !inherits(df_all_daily, "try-error") &
          inherits(df_monthly_max_year, "try-error")
          inherits(df_monthly_min_year, "try-error")  
  
  # check if no error occured
  expect_true(check)
})