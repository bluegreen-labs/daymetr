context("Test nccs routine")

test_that("freefrom gridded download (ncss) checks",{
  skip_on_cran()
  
  # download daily data
  expect_message(
    download_daymet_ncss(
      param = "tmin",
      frequency = "daily",
      path = tempdir(),
      silent = TRUE,
      force = TRUE
      )
    )
  
  # download monthly data, bad location
  expect_error(
    download_daymet_ncss(
      location = c(34, -82, 33.75),
      param = "tmin",
      frequency = "monthly",
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # download monthly data
  expect_message(
    download_daymet_ncss(
      param = "tmin",
      frequency = "monthly",
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # download out of range checks for years (min)
  expect_error(
    download_daymet_ncss(
      param = "tmin",
      frequency = "monthly",
      start = 1970,
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # download out of range checks for years (max)
  expect_error(
    download_daymet_ncss(
      param = "tmin",
      frequency = "monthly",
      end = 2100,
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # download annual data
  expect_message(
    download_daymet_ncss(
      param = "tmin",
      frequency = "annual",
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # download annual data for all data types
  expect_message(
    download_daymet_ncss(
      param = "ALL",
      frequency = "annual",
      path = tempdir(),
      silent = FALSE
      )
    )
  
  # download the data
  expect_message(
    download_daymet_ncss(
      param = "ALL",
      frequency = "daily",
      path = tempdir(),
      silent = FALSE
      )
    )
})
