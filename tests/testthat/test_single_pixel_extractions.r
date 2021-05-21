context("test single pixel downloads")

test_that("pixel location download check",{
  skip_on_cran()
  
  # download the data
  expect_output(str(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           silent = TRUE)))
  
  # download the data, force out of range max_year
  # but do not call it
  expect_output(str(download_daymet(start = 1980,
                           end = 1980,
                           internal = TRUE,
                           silent = TRUE,
                           force = TRUE)))
  
  # download verbose and external
  expect_message(download_daymet(start = 1980,
                               end = 1980,
                               internal = FALSE,
                               path = tempdir(),
                               silent = FALSE))
  
  # create new directory
  new_dir <- file.path(tempdir(),"test")
  dir.create(new_dir)
  
  # download verbose and check copy
  expect_message(download_daymet(start = 1980,
                               end = 1980,
                               internal = FALSE,
                               path = new_dir,
                               silent = FALSE))
  
  # download out of range data (space and time)
  expect_error(download_daymet(start = 1970,
                                 end = 1980,
                                 internal = TRUE,
                                 silent = TRUE))
  
  expect_error(download_daymet(start = 1980,
                                     end = 2100,
                                     internal = TRUE,
                                     silent = TRUE))
  
  expect_error(download_daymet(start = 1980,
                                     end = 1980,
                                     internal = TRUE,
                                     silent = TRUE,
                                     lat = 0,
                                     lon = 0))
  
  # create demo locations
  locations <- data.frame(site = c("site1", "site2"),
                         lat = rep(36.0133, 2),
                         lon = rep(-84.2625, 2))
  
  # write csv to file
  write.table(locations, paste0(tempdir(),"/locations.csv"),
              sep = ",",
              col.names = TRUE,
              row.names = FALSE,
              quote = FALSE)
  
  # download data
  expect_message(download_daymet_batch(
    file_location = paste0(tempdir(),"/locations.csv"),
    start = 1980,
    end = 1980,
    internal = TRUE,
    silent = FALSE))
  
  # download data
  expect_error(download_daymet_batch(file_location = "error.csv",
                                       start = 1980,
                                       end = 1980,
                                       internal = TRUE,
                                       silent = TRUE))
})
