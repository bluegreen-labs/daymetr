# Daymetr unit tests

# standard pixel extraction test both single
# location and batch processing
test_that("pixel location download check",{
  
  # download the data
  df = try(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           silent = TRUE))
  
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
  
  # download out of range data
  df_range = try(download_daymet(start = 1970,
                                 end = 1980,
                                 internal = TRUE,
                                 silent = TRUE))
  
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
  
  # download out of range data
  df_batch = try(download_daymet_batch(file_location = paste0(tempdir(),
                                                              "/locations.csv"),
                                       start = 1980,
                                       end = 1980,
                                       internal = TRUE,
                                       silent = TRUE))
  
  # see if any of the runs failed
  check = !inherits(df, "try-error") &
          inherits(df_range,"try-error") &
          !inherits(df_ext, "try-error") &
          !inherits(df_ext_home, "try-error") &
          !inherits(df_batch, "try-error")
  
  # check if no error occured
  expect_true(check)
})