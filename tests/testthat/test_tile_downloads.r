context("test tile downloads")
server_check <- daymet_running(tile_server())

test_that("download tile",{
  skip_if_not(server_check)
  expect_message(download_daymet_tiles(
    tiles = 9753,
    start = 1980,
    end = 1980,
    param = "ALL",
    path = tempdir(),
    silent = FALSE,
    force = TRUE))
})

test_that("bad start year",{
  skip_if_not(server_check)
  expect_error(download_daymet_tiles(
    tiles = 9753,
    start = 1970,
    end = 1980,
    param = "tmin",
    path = tempdir(),
    silent = FALSE))
})

test_that("bad end year",{
  skip_if_not(server_check)
  expect_error(download_daymet_tiles(
    tiles = 9753,
    start = 1980,
    end = 2100,
    param = "tmin",
    path = tempdir(),
    silent = FALSE))
})

test_that("download tiles by bounding box",{
  skip_if_not(server_check)
  expect_message(download_daymet_tiles(
    location = c(18.9103, -114.6109, 18.6703, -114.2181),
    start = 1980,
    end = 1980,
    param = "tmin",
    path = tempdir(),
    silent = TRUE))
})

test_that("missing coordinate value",{
  skip_if_not(server_check)
  expect_error(    download_daymet_tiles(
    location = c(18.9103,
                 -114.6109,
                 18.6703), 
    start = 1980,
    end = 1980,
    param = "tmin",
    path = tempdir(),
    silent = TRUE))
})

test_that("out of range bbox coordinates",{
  skip_if_not(server_check)
  expect_error(download_daymet_tiles(
    location = c(0,0,0.1,0.1),
    start = 1980,
    end = 1980,
    param = "tmin",
    path = tempdir(),
    silent = TRUE))
})

test_that("out of range coordinate pair",{
  skip_if_not(server_check)
  expect_error(download_daymet_tiles(
    location = c(0, 0),
    start = 1980,
    end = 1980,
    param = "tmin",
    path = tempdir(),
    silent = TRUE))
})
