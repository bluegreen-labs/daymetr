#' This function downloads 'Daymet' data for several single pixel
#' location, as specified by a batch file.
#' 
#' @param file_location file with several site locations and coordinates
#' in a comma delimited format: site, latitude, longitude
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param internal assign or FALSE, load data into workspace or save to disc
#' @param force \code{TRUE} or \code{FALSE} (default),
#' override the conservative end year setting
#' @param silent suppress the verbose output (default = FALSE)
#' @param path set path where to save the data
#' if internal = FALSE (default = tempdir())
#' @param simplify output tidy data (tibble), logical \code{FALSE}
#' or \code{TRUE} (default = \code{TRUE})
#' @return Daymet data for point locations as a nested list or
#' data written to csv files
#' @export
#' @examples
#'
#' \dontrun{
#' # The download_daymet_batch() routine is a wrapper around
#' # the download_daymet() function. It queries a file with
#' # coordinates to easily download a large batch of daymet
#' # pixel locations. When internal = TRUE, the data is stored
#' # in a structured list in an R variable. If FALSE, the data
#' # is written to disk.
#' 
#' # create demo locations (two sites)
#' locations <- data.frame(site = c("site1", "site2"),
#'                       lat = rep(36.0133, 2),
#'                       lon = rep(-84.2625, 2))
#'
#' # write data to csv file
#' write.table(locations, paste0(tempdir(),"/locations.csv"),
#'            sep = ",",
#'            col.names = TRUE,
#'            row.names = FALSE,
#'            quote = FALSE)
#'
#' # download data, will return nested list of daymet data
#' df_batch <- download_daymet_batch(file_location = paste0(tempdir(),
#'                                                         "/locations.csv"),
#'                                     start = 1980,
#'                                     end = 1980,
#'                                     internal = TRUE,
#'                                     silent = TRUE)
#' 
#' # For other practical examples consult the included
#' # vignette. 
#' }

download_daymet_batch <- function(
  file_location = NULL,
  start = 1980,
  end = as.numeric(format(Sys.time(), "%Y")) - 1,
  internal = TRUE,
  force = FALSE,
  silent = FALSE,
  path = tempdir(),
  simplify = FALSE
  ){
  
  # check if the file exists
  if(!file.exists(file_location) || is.null(file_location)){
    stop("file not provided or does not exist, please check the file path!")
  }
  
  # read table with sites and coordinates
  locations <- utils::read.table(file_location,
                                sep = ',',
                                header = TRUE)

  # loop over all lines in the file return
  # nested list
  output <- apply(locations, 1, function(location) {
    site <- as.character(location[1])
    lat <- as.numeric(location[2])
    lon <- as.numeric(location[3])
    
    try(download_daymet(
      site = site,
      lat = lat,
      lon = lon,
      start = start,
      end = end,
      internal = internal,
      force = force,
      silent = silent,
      path = path,
      simplify = simplify
    ),
    silent = FALSE)
  })
  
  # if the output is tidy, row bind to one big
  # tibble otherwise return a nested list
  if (simplify){
    output <- do.call("rbind", output)
  }
  
  if(internal){
    return(output)
  }
}
