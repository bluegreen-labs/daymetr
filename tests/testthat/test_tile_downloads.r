# Daymetr unit tests

# bounding box tile downloads
test_that("download tiles by bounding box",{
  
  # download by tile number for all data
  df_tile = try(download_daymet_tiles(tiles = 9753,
                                         start = 1980,
                                         end = 1980,
                                         param = "ALL",
                                         path = tempdir(),
                                         silent = FALSE,
                                         force = TRUE))
  
  df_min_year = try(download_daymet_tiles(tiles = 9753,
                                      start = 1970,
                                      end = 1980,
                                      param = "tmin",
                                      path = tempdir(),
                                      silent = FALSE))
  
  df_max_year = try(download_daymet_tiles(tiles = 9753,
                                      start = 1980,
                                      end = 2100,
                                      param = "tmin",
                                      path = tempdir(),
                                      silent = FALSE))
  
  # download out of range data
  df_bbox = try(download_daymet_tiles(
    location = c(18.9103, -114.6109, 18.6703, -114.2181),
    start = 1980,
    end = 1980,
    param = "tmin",
    path = tempdir(),
    silent = TRUE))
  
  # download out of range data
  df_bbox_corrupt = try(download_daymet_tiles(location = c(18.9103,
                                                           -114.6109,
                                                           18.6703),
                                              start = 1980,
                                              end = 1980,
                                              param = "tmin",
                                              path = tempdir(),
                                              silent = TRUE))
  
  # download out of range data
  df_bbox_corrupt_range = try(download_daymet_tiles(location = c(0,0,0.1,0.1),
                                              start = 1980,
                                              end = 1980,
                                              param = "tmin",
                                              path = tempdir(),
                                              silent = TRUE))
  
  # download out of range data
  df_bbox_corrupt_range_2 = try(download_daymet_tiles(location = c(0, 0),
                                                start = 1980,
                                                end = 1980,
                                                param = "tmin",
                                                path = tempdir(),
                                                silent = TRUE))
  
  # download out of range data
  df_loc = try(download_daymet_tiles(location = c(18.355011, -114.732133),
                                                      start = 1980,
                                                      end = 1980,
                                                      param = "tmin",
                                                      path = tempdir(),
                                                      silent = TRUE))
  
  # see if any of the runs failed
  check = !inherits(df_tile, "try-error") & 
          inherits(df_min_year, "try-error") & 
          inherits(df_max_year, "try-error") & 
          inherits(df_bbox_corrupt, "try-error") &
          inherits(df_bbox_corrupt_range, "try-error") &
          inherits(df_bbox_corrupt_range_2, "try-error") &
          !inherits(df_loc, "try-error") &
          !inherits(df_bbox, "try-error")
  
  # check if no error occured
  expect_true(check)
})

