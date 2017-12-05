#' This function downloads 'Daymet' data for several single pixel
#' location, as specified by a batch file.
#' 
#' @param file_location file with several site locations and coordinates
#' in a comma delimited format: site, latitude, longitude
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param internal assign or FALSE, load data into workspace or save to disc
#' @param force TRUE or FALSE, override the conservative end year setting
#' @return Daymet data for point locations as a nested list or
#' data written to csv files
#' @keywords DAYMET, climate data
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
#' download_daymet_batch(file_location = "yourlocations.csv")
#' }

download_daymet_batch <- function(file_location = NULL,
                                  start = 1980,
                                  end = as.numeric(format(Sys.time(), "%Y"))-1,
                                  internal = TRUE,
                                  force = FALSE){

  # check if the file exists
  if(!file.exists(file_location) || is.null(file_location)){
    stop("file not provided or does not exist, please check the file path!")
  }
  
  # read table with sites and coordinates
  locations = utils::read.table(file_location, sep=',')

  # loop over all lines in the file return
  # nested list
  apply(locations, 1, function(location){
    site = as.character(location[1])
    lat = as.numeric(location[2])
    lon = as.numeric(location[3])
    try(download_daymet(
      site = site,
      lat = lat,
      lon = lon,
      start = start,
      end = end,
      internal = internal,
      force = force
    ),
    silent = FALSE)
  })
}
