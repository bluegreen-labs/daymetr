# Daymetr unit tests

# bounding box tile downloads
test_that("download tiles by bounding box",{
  
  # download out of range data
  df_bbox = try(download_daymet_tiles(location = c(18.9103,
                                                   -114.6109,
                                                   18.6703,
                                                   -114.2181),
                                      start = 1980,
                                      end = 1980,
                                      param = "tmin",
                                      path = tempdir(),
                                      silent = FALSE))
  
  # download by tile number for all data
  df_tile_nr = try(download_daymet_tiles(tiles = 9753,
                                         start = 1980,
                                         end = 1980,
                                         param = "ALL",
                                         path = tempdir(),
                                         silent = FALSE))
  
  # download out of range data
  df_bbox_corrupt = try(download_daymet_tiles(location = c(18.9103,
                                                           -114.6109,
                                                           18.6703),
                                              start = 1980,
                                              end = 1980,
                                              param = "tmin",
                                              path = tempdir(),
                                              silent = FALSE))
  
  # see if any of the runs failed
  check = !inherits(df_bbox, "try-error") &
    !inherits(df_tile_nr, "try-error") &
    inherits(df_bbox_corrupt, "try-error")
  
  # check if no error occured
  expect_true(check)
})

