context("test ancillary functions")

test_that("check offset routine",{
  skip("ncss issues")
  
  # download the data
  df_daily <- try(download_daymet_ncss(param = "tmin",
                                      frequency = "daily",
                                      path = tempdir(), 
                                      start = 1981,
                                      end = 1982,
                                      silent = TRUE))
  
  # create a stack of the downloaded data
  st <- raster::stack(paste(tempdir(),
                           c("tmin_daily_1981_ncss.nc",
                             "tmin_daily_1982_ncss.nc"),
                           sep = "/"))
  
  # correct offset
  offset_check <- try(daymet_grid_offset(st))
  
  # corrupted offset
  offset_check_corrupt <- try(daymet_grid_offset(raster::dropLayer(st, 1)))
  
  # see if any of the runs failed
  check <- !inherits(df_daily,"try-error") &
    !inherits(offset_check,"try-error") &
    inherits(offset_check_corrupt, "try-error") # no ! reversal
  
  # check if no error occured
  expect_true(check)
})

# check the calculation of a mean values
test_that("tmean grid checks",{
  skip("ncss issues")
  
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
  skip("ncss issues")
  
  # download the data
  try(download_daymet_ncss(param = "tmin",
                           frequency = "annual",
                           path = tempdir(),
                           silent = TRUE))
  
  # check conversion to geotiff of all
  # data types (daily, monthly, annual)
  expect_message(nc2tif(path = tempdir(),
                                overwrite = TRUE))
  
  # check conversion to geotiff of all
  # data types (daily, monthly, annual)
  expect_error(nc2tif(path = tempdir(),
                      overwrite = FALSE))
  
  # check if no error occured
  expect_true(check)
})

# check aggregation
test_that("tile aggregation checks",{
  skip("ncss issues")
  
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
  
  # seasonal aggregation
  df_agg_internal = try(daymet_grid_agg(file = paste0(tempdir(),
                                        "/tmin_daily_1980_ncss.nc"),
                                        int = "seasonal",
                                        fun = "mean",
                                        internal = TRUE))
  
  # seasonal aggregation
  df_agg = try(daymet_grid_agg(file = paste0(tempdir(),
                               "/tmin_daily_1980_ncss.nc"),
                               int = "seasonal",
                               fun = "mean"))
  
  # seasonal aggregation non daily
  df_agg_monthly = try(daymet_grid_agg(file = paste0(tempdir(),
                               "/tmin_daily_1980_ncss.nc"),
                               int = "monthly",
                               fun = "mean"))
  
  # seasonal aggregation non daily
  df_agg_annual = try(daymet_grid_agg(file = paste0(tempdir(),
                                       "/tmin_daily_1980_ncss.nc"),
                                       int = "annual",
                                       fun = "mean"))
  
  # using a tif file (convert nc files first)
  nc2tif(path = tempdir(), files = paste0(tempdir(),
                                          "/tmin_daily_1980_ncss.nc"),
         overwrite = TRUE)
  df_agg_tif = try(daymet_grid_agg(file = paste0(tempdir(),
                                             "/tmin_daily_1980_ncss.tif"),
                               int = "seasonal",
                               fun = "mean"))
  
  # non daily file, should skip / error
  df_agg_non_daily = try(daymet_grid_agg(file = paste0(tempdir(),
                                    "/tmin_monavg_1980_ncss.tif"),
                                   int = "seasonal",
                                   fun = "mean"))
  
  # seasonal aggregation missing file
  df_agg_file_missing = try(daymet_grid_agg(fun = "mean"))
  
  # seasonal aggregation non existing file
  df_agg_file_exists = try(daymet_grid_agg(file = "test.nc",
                                           fun = "mean"))
  
  # see if any of the runs failed
  check = !inherits(df_agg_internal, "try-error") &
          !inherits(df_agg, "try-error") &
          !inherits(df_agg_tif, "try-error") &
          !inherits(df_agg_monthly, "try-error") &
          !inherits(df_agg_annual, "try-error") &
          inherits(df_agg_file_missing, "try-error") &
          inherits(df_agg_file_exists, "try-error") &
          inherits(df_agg_non_daily, "try-error")
  
  # check if no error occured
  expect_true(check)
})

# test read_daymet header formatting
test_that("read_daymet checks of meta-data",{
  skip("ncss issues")
  
  # download verbose and external
  download_daymet(start = 1980,
                  end = 1980,
                  internal = FALSE,
                  path = tempdir(),
                  silent = TRUE)
  
  # read in the Daymet file
  df = try(read_daymet(paste0(tempdir(),"/Daymet_1980_1980.csv"),
                       simplify = FALSE))
  df_skip_header = try(read_daymet(paste0(tempdir(),"/Daymet_1980_1980.csv"),
                                   skip_header = TRUE))
  
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
  expect_error(read_daymet(paste0(tempdir(),"/Daymet_1980_1981.csv")))
  
  # not provided
  expect_error(read_daymet())
})

# calc_nd checks
test_that("calc_nd checks",{
  skip("ncss issues")
  
  # download daily gridded data
  # using default settings (data written to tempdir())
  download_daymet_ncss()
  
  # read in the Daymet file and report back the number
  # of days in a year with a minimum temperature lower
  # than 15 degrees C
  r = calc_nd(file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
              criteria = "<",
              value = 15,
              internal = TRUE)
  
  # internal processing
  int = try(calc_nd(file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
              criteria = "<",
              value = 15,
              start_doy = 40,
              end_doy = 80,
              internal = FALSE))
  
  # criteria fail
  crit = try(calc_nd(file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
                    criteria = "a",
                    value = 15,
                    start_doy = 40,
                    end_doy = 80,
                    internal = TRUE))
  
  doy = try(calc_nd(file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
                    criteria = "<",
                    value = 15,
                    start_doy = 100,
                    end_doy = 80,
                    internal = TRUE))
  
  # see if any of the runs failed
  check = !inherits(int, "try-error") &
          inherits(crit, "try-error") &
          inherits(doy, "try-error") &
          attr(class(r),"package") == "raster"
  
  # check if no error occured
  expect_true(check)
})
