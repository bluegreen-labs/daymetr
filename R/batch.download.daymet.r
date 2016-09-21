#' Function to batch download single location DAYMET data
#'
#' This function downloads DAYMET data for several single pixel
#' location.
#' @param file_location : file with several site locations and coordinates
#' in a format site, latitude, longitude
#' @param start_yr : start of the range of years over which to download data
#' @param end_yr : end of the range of years over which to download data
#' @param internal : TRUE or FALSE, load data into workspace or save to disc
#' @keywords DAYMET, climate data
#' @export
#' @examples
#' 
#' # NOT RUN
#' # batch.download("yourlocations.csv")

batch.download.daymet <- function(file_location,
                                  start_yr=1980,
                                  end_yr=as.numeric(format(Sys.time(), "%Y"))-1,
                                  internal=FALSE){
  
  # read table with sites and coordinates
  locations = read.table(file_location,sep=',')

  # loop over all lines in the file
  for (i in 1:dim(locations)[1]){
    site = as.character(locations[i,1])
    lat = as.numeric(locations[i,2])
    lon = as.numeric(locations[i,3])
    try(downloader::download.daymet(site=site,lat=lat,lon=lon,start_yr=start_yr,end_yr=end_yr,internal=internal),silent=FALSE)
  }
}