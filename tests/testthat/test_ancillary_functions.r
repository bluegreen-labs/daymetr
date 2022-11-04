context("test ancillary functions")

test_that("check offset routine, file conversions",{
  skip_on_cran()
  
  # download the data
  expect_message(
    download_daymet_ncss(
      param = "tmin",
      frequency = "daily",
      path = tempdir(), 
      start = 1981,
      end = 1982,
      silent = TRUE
      )
    )
  
  # create a stack of the downloaded data
  st <- suppressWarnings(
    c(
      terra::rast(file.path(tempdir(), c("tmin_daily_1981_ncss.nc"))),
      terra::rast(file.path(tempdir(), c("tmin_daily_1981_ncss.nc")))
      )
    )
  
  # convert nc to tif
  expect_message(nc2tif())
  expect_silent(nc2tif(silent = TRUE))
  expect_message(nc2tif())
  expect_message(nc2tif(overwrite = TRUE))
  
  # correct offset
  expect_silent(daymet_grid_offset(st))
  
  # corrupted offset
  expect_error(daymet_grid_offset(terra::subset(st, 1)))
})

# check the calculation of a mean values
test_that("tmean grid checks",{
  skip_on_cran()
  
  # download the data
  expect_message(
    download_daymet_ncss(
      param = c("tmin","tmax"),
      frequency = "monthly",
      path = tempdir(),
      silent = TRUE
      )
    )
  
  expect_message(
    download_daymet_tiles(
      path = tempdir(),
      param = c("tmin","tmax"),
      silent = TRUE
      )
    )
  
  # run the function which calculates mean temperature
  # for a gridded daymet product
  expect_message(
    daymet_grid_tmean(
      path = tempdir(),
      product = "monavg",
      year = 1980
      )
    )
  
  expect_message(
    daymet_grid_tmean(
      path = tempdir(),
      product = "monavg",
      year = 1980,
      internal = TRUE
      )
    )
  
  expect_error(
    daymet_grid_tmean(
      path = tempdir(),
      product = 0,
      year = 1980
      )
    )
  
  expect_error(
    daymet_grid_tmean(
      path = tempdir(),
      product = 0,
      year = NULL
      )
    )
  
  # remove one file of the temperature pair (tmin)
  file.remove(
    list.files(
      tempdir(),
      "*tmin*",
      full.names = TRUE
      )
    )
  
  # try to do a tmean composite again (will fail)
  expect_error(daymet_grid_tmean(path = tempdir(),
              product = "monavg",
              year = 1980))
})

# check conversion to geotiff
test_that("tile download and format conversion checks",{
  skip_on_cran()
  
  # download the data
  expect_message(
    download_daymet_ncss(
      param = "tmin",
      frequency = "annual",
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # check conversion to geotiff of all
  # data types (daily, monthly, annual)
  expect_message(
    nc2tif(
      files = file.path(tempdir(),"tmin_annavg_1980_ncss.nc"),
      overwrite = TRUE
      )
    )
})

# check aggregation
test_that("tile aggregation checks",{
  skip_on_cran()
  
  # download the data
  expect_message(
    download_daymet_ncss(
      param = "tmin",
      frequency = "daily",
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # download the data
  expect_message(
    download_daymet_ncss(
      param = "tmin",
      frequency = "monthly",
      path = tempdir(),
      silent = TRUE
      )
    )
  
  # seasonal aggregation
  expect_silent(
    daymet_grid_agg(
      file = file.path(tempdir(),
                       "/tmin_daily_1980_ncss.nc"),
      int = "seasonal",
      fun = "mean",
      internal = TRUE
      )
    )
  
  # seasonal aggregation
  expect_silent(
    daymet_grid_agg(
      file = file.path(tempdir(),
                       "/tmin_daily_1980_ncss.nc"),
      int = "seasonal",
      fun = "mean"
      )
    )
  
  # seasonal aggregation non daily
  expect_silent(
    daymet_grid_agg(
      file = file.path(tempdir(),
                       "/tmin_daily_1980_ncss.nc"),
      int = "monthly",
      fun = "mean"
      )
    )
  
  # seasonal aggregation non daily
  expect_silent(
    daymet_grid_agg(
      file = file.path(tempdir(),
                       "/tmin_daily_1980_ncss.nc"),
      int = "annual",
      fun = "mean"
      )
    )
  
  # using a tif file (convert nc files first)
  nc2tif(
      path = tempdir(),
      files = file.path(tempdir(),"/tmin_daily_1980_ncss.nc"),
      overwrite = TRUE
    )
  
  expect_silent(
    daymet_grid_agg(
      file = file.path(tempdir(),
                       "/tmin_daily_1980_ncss.tif"),
      int = "seasonal",
      fun = "mean"
      )
    )
  
  # non daily file, should skip / error
  expect_error(
    daymet_grid_agg(
      file = file.path(
        tempdir(),
        "/tmin_monavg_1980_ncss.tif"),
      int = "seasonal",
      fun = "mean"))
  
  # seasonal aggregation missing file
  expect_error(
    daymet_grid_agg(fun = "mean")
    )
  
  # seasonal aggregation non existing file
  expect_error(
    daymet_grid_agg(
      file = "test.nc",
      fun = "mean")
    )
})

# test read_daymet header formatting
test_that("read_daymet checks of meta-data",{
  skip_on_cran()
  
  # download verbose and external
  download_daymet(
    start = 1980,
    end = 1980,
    internal = FALSE,
    path = tempdir(),
    silent = TRUE
    )
  
  df <- read_daymet(
    file.path(tempdir(),"/Daymet_1980_1980.csv"),
    simplify = FALSE
    )
  
  expect_output(
    str(
      read_daymet(
        file.path(tempdir(),"/Daymet_1980_1980.csv"),
        skip_header = TRUE
        )
      )
    )
  
  # check read tile and coordinate info
  expect_true(is.numeric(df$tile))
  expect_true(is.numeric(df$latitude))
  expect_true(is.numeric(df$altitude))
  expect_true(is.numeric(df$altitude))
  
  # drop header
  write.table(df$data, file.path(tempdir(),"no_header.csv"),
              sep = ",",
              col.names = TRUE,
              row.names = FALSE,
              quote = FALSE)
  
  # read in headerless file
  expect_message(read_daymet(file.path(tempdir(),"no_header.csv"),
                                 skip_header = TRUE))
  
  # file does note exist
  expect_error(read_daymet(file.path(tempdir(),"/Daymet_1980_1981.csv")))
  
  # not provided
  expect_error(read_daymet())
})

# calc_nd checks
test_that("calc_nd checks",{
  skip_on_cran()
  
  # download daily gridded data
  # using default settings (data written to tempdir())
  download_daymet_ncss()
  
  # read in the Daymet file and report back the number
  # of days in a year with a minimum temperature lower
  # than 15 degrees C
  expect_output(
    str(
      calc_nd(
        file = file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
        criteria = "<",
        value = 15,
        internal = TRUE
        )
      )
    )
  
  # internal processing
  expect_output(
    str(
      calc_nd(
        file = file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
        criteria = "<",
        value = 15,
        start_doy = 40,
        end_doy = 80,
        path = tempdir(),
        internal = FALSE
        )
      )
    )
  
  # criteria fail
  expect_error(
    calc_nd(
      file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
      criteria = "a",
      value = 15,
      start_doy = 40,
      end_doy = 80,
      internal = TRUE
      )
    )
  
  expect_error(
    calc_nd(
      file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
      criteria = "<",
      value = 15,
      start_doy = 100,
      end_doy = 80,
      internal = TRUE
      )
    )
})
