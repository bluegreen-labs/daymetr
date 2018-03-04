# Daymetr unit tests

# standard pixel extraction test both single
# location and batch processing
test_that("pixel location download check",{
  
  # download the data
  df = try(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           silent = TRUE))
  
  # download the data, force out of range max_year
  # but do not call it
  df_force = try(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           silent = TRUE,
                           force = TRUE))
  
  # download verbose and external
  df_ext = try(download_daymet(start = 1980,
                               end = 1980,
                               internal = FALSE,
                               path = tempdir(),
                               silent = FALSE))
  
  # download verbose and external (not to tempdir())
  df_ext_home = try(download_daymet(start = 1980,
                               end = 1980,
                               internal = FALSE,
                               path = "~",
                               silent = FALSE))
  
  # download out of range data (space and time)
  df_range = try(download_daymet(start = 1970,
                                 end = 1980,
                                 internal = TRUE,
                                 silent = TRUE))
  
  df_range_max = try(download_daymet(start = 1980,
                                     end = 2100,
                                     internal = TRUE,
                                     silent = TRUE))
  
  df_range_loc = try(download_daymet(start = 1980,
                                     end = 1980,
                                     internal = TRUE,
                                     silent = TRUE,
                                     lat = 0,
                                     lon = 0))
  
  # create demo locations
  locations = data.frame(site = c("site1", "site2"),
                         lat = rep(36.0133, 2),
                         lon = rep(-84.2625, 2))
  
  # write csv to file
  write.table(locations, paste0(tempdir(),"/locations.csv"),
              sep = ",",
              col.names = TRUE,
              row.names = FALSE,
              quote = FALSE)
  
  # download data
  df_batch = try(download_daymet_batch(file_location = paste0(tempdir(),
                                                              "/locations.csv"),
                                       start = 1980,
                                       end = 1980,
                                       internal = TRUE,
                                       silent = TRUE))
  
  # download data
  df_batch_error = try(download_daymet_batch(file_location = "error.csv",
                                       start = 1980,
                                       end = 1980,
                                       internal = TRUE,
                                       silent = TRUE))
  
  # see if any of the runs failed
  check = !inherits(df, "try-error") &
          !inherits(df_force, "try-error") &
          inherits(df_range,"try-error") &
          inherits(df_range_max,"try-error") &
          inherits(df_range_loc,"try-error") &
          !inherits(df_ext, "try-error") &
          !inherits(df_ext_home, "try-error") &
          !inherits(df_batch, "try-error") &
          inherits(df_batch_error, "try-error")
  
  # check if no error occured
  expect_true(check)
})