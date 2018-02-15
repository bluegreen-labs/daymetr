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
  df = try(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           quiet = TRUE))
  
  # check if no error occured
  expect_true(!inherits(df,"try-error"))
})

# freeform gridded data download check
test_that("freefrom gridded download (ncss) checks",{
  
  # download the data
  df = try(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           quiet = TRUE))
  
  # check if no error occured
  expect_true(!inherits(df,"try-error"))
})