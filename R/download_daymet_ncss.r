#' Function to geographically subset 'Daymet' regions exceeding tile limits
#'
#' @param location location of a bounding box c(lat, lon, lat, lon) defined
#' by a top left and bottom-right coordinates
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param param climate variable you want to download vapour pressure (vp), 
#' minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), 
#' solar radiation (srad), precipitation (prcp) , day length (dayl).
#' The default setting is ALL, this will download all the previously mentioned
#' climate variables.
#' @param frequency frequency of the data requested (default = "daily", other
#' options are "monthly" or "annual").
#' @param mosaic which tile mosiac to source from (na = Northern America,
#' hi = Hawaii, pr = Puerto Rico), defaults to "na".
#' @param path directory where to store the downloaded data 
#'  (default = tempdir())
#' @param silent suppress the verbose output
#' @param force \code{TRUE} or \code{FALSE} (default),
#' override the conservative end year setting
#' @param ssl \code{TRUE} (default) or \code{FALSE},
#' override default SSL settings in case of CA issues
#' 
#' @return netCDF data file of an area circumscribed by the location bounding
#' box
#' @export
#' @examples
#' 
#' \dontrun{
#' # The following call allows you to subset gridded
#' # Daymet data using a bounding box location. This
#' # is an alternative way to query gridded data. The
#' # routine is particularly helpful if you need certain
#' # data which stradles boundaries of multiple tiles
#' # or a smaller subset of a larger tile. Keep in mind
#' # that there is a 6GB upper limit to the output file
#' # so querying larger regions will result in an error.
#' # To download larger areas use the download_daymet_tiles()
#' # function.
#' 
#' # Download a subset of a / multiple tiles
#' # into your current working directory.
#' download_daymet_ncss(location = c(34, -82, 33.75, -81.75),
#'                       start = 1980,
#'                       end = 1980,
#'                       param = "tmin",
#'                       path = tempdir())
#'                       
#' # For other practical examples consult the included
#' # vignette. 
#' }

download_daymet_ncss <- function(
  location = c(34, -82, 33.75, -81.75),
  start = 1980,
  end = 1980,
  param = "tmin",
  frequency = "daily",
  mosaic = "na",
  path = tempdir(),
  silent = FALSE,
  force = FALSE,
  ssl = TRUE
){
  # CRAN file policy
  if (identical(path, tempdir())){
    message("NOTE: data is stored in tempdir() ...")
  }
  
  # temp. fix set SSL verify config to ignore
  # service is non critical (no encryption needed)
  # assuming CA authority issues are ORNL issues
  # not a man in the middle attack
  if (!ssl){
    httr::set_config(httr::config(ssl_verifypeer = 0L))
  }
  
  # remove capitals from frequency
  frequency <- tolower(frequency)
  
  # check if there are enough coordinates specified
  if (length(location) != 4){
    stop("check coordinates format: top-left / bottom-right c(lat,lon,lat,lon)")
  }
  
  # force the max year to be the current year or
  # current year - 1 (conservative)
  if (!force){
    max_year <- as.numeric(format(Sys.time(), "%Y")) - 1
  } else {
    max_year <- as.numeric(format(Sys.time(), "%Y"))
  }
  
  # check validaty of the range of years to download
  # I'm not sure when new data is released so this might be a
  # very conservative setting, remove it if you see more recent data
  # on the website
  
  if (start < 1980){
    stop("Start year preceeds valid data range!")
  }
  if (end > max_year){
    stop("End year exceeds valid data range!")
  }
  
  # if the year range is valid, create a string of valid years
  year_range <- seq(start, end, by = 1)
  
  # check the parameters we want to download in case of
  # ALL list all available parameters for each frequency
  if (any(grepl("ALL", toupper(param)))) {
    if (tolower(frequency) == "daily"){
      param <- c('vp','tmin','tmax','swe','srad','prcp','dayl')
    } else {
      param <- c('vp','tmin','tmax','prcp')
    }
  }
  
  # provide some feedback
  if(!silent){
    message('Creating a subset of the Daymet data
        be patient, this might take a while!\n')
  }
  
  for ( i in year_range ){
    for ( j in param ){
      
      if (frequency != "daily"){
        
        prefix <- ifelse(
          j != "prcp",
          paste0(substr(frequency,1,3),"avg"),
          paste0(substr(frequency,1,3),"ttl")
          )
        
        # create url string (varies per product / year)
        url <- sprintf("%s/daymet_v4_%s_%s_%s_%s.nc",
                       ncss_server(frequency = frequency),
                       j, prefix, mosaic, i)
        
        # create filename for the output file
        daymet_file <- file.path(path, paste0(j,"_",prefix,"_",i,"_ncss.nc"))
        
      } else {
        
        # correction in naming conventions
        if(mosaic == "hi"){
          mosaic <- "hawaii"
        } else if(mosaic == "pr"){
          mosaic <- "puertorico"
        }
        
        # create url string (varies per product / year)
        url <- sprintf("%s/daymet_v4_daily_%s_%s_%s.nc",
                       ncss_server(frequency = frequency),
                       mosaic, j, i)
        
        message(url)
        
        # create filename for the output file
        daymet_file <- file.path(path,paste0(j,"_daily_",i,"_ncss.nc"))
      }
      
      # formulate query to pass to httr
      query <- list(
        "var" = "lat",
        "var" = "lon",
        "var" = j,
        "north" = location[1],
        "west" = location[2],
        "east" = location[4],
        "south" = location[3],
        "time_start" = paste0(start, "-01-01T12:00:00Z"),
        "time_end" = paste0(end, "-12-31T12:00:00Z"),
        "timeStride" = 1,
        "accept" = "netcdf"
      )
      
      # provide some feedback
      if(!silent){
        message(paste0('\nDownloading DAYMET subset: ',
                       'year: ',i,
                       '; product: ',j,
                       '\n'))
      }
      
      # download data, force binary data mode
      if(silent){
        status <- httr::GET(url = url,
                            query = query,
                            httr::write_disk(path = daymet_file,
                                             overwrite = TRUE))
      } else {
        status <- httr::GET(url = url,
                            query = query,
                            httr::write_disk(path = daymet_file,
                                             overwrite = TRUE),
                            httr::progress())
      }
      
      # error / stop on 400 error
      if(httr::http_error(status)){
        
        # remove bad file
        file.remove(daymet_file)
        
        # report error
        stop("Requested data download failed!\ 
             Common issues involve a mismatch between\ 
             the location and the mosaic used or downloads\ 
             exceeding 6GB in size.", call. = FALSE)
      }
    }
  }
}