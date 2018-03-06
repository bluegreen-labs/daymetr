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
#' options are "monthly" or "annual".
#' @param path directory where to store the downloaded data (default = tempdir())
#' @param silent suppress the verbose output
#' @param force \code{TRUE} or \code{FALSE} (default),
#' override the conservative end year setting
#' @return netCDF data file of an area circumscribed by the location bounding
#' box
#' @keywords daymet, climate data
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

download_daymet_ncss = function(location = c(34, -82, 33.75, -81.75),
                                 start = 1980,
                                 end = 1980,
                                 param = "tmin",
                                 frequency = "daily",
                                 path = tempdir(),
                                 silent = FALSE,
                                 force = FALSE){
  # CRAN file policy
  if (identical(path, tempdir())){
    message("NOTE: data is stored in tempdir() ...")
  }
  
  # base url path
  base_url = "https://thredds.daac.ornl.gov/thredds/ncss/ornldaac"
  
  # remove capitals from frequency
  frequency = tolower(frequency)
  
  # set final url path depending on the frequency of the
  # data requested
  if(frequency == "monthly"){
    base_url = sprintf("%s/%s", base_url, 1345)
  } else if (frequency == "annual"){
    base_url = sprintf("%s/%s", base_url, 1343)
  } else {
    base_url = sprintf("%s/%s", base_url, 1328)
  }
  
  # check if there are enough coordinates specified
  if (length(location)!=4){
    stop("check coordinates format: top-left / bottom-right c(lat,lon,lat,lon)")
  }
  
  # force the max year to be the current year or
  # current year - 1 (conservative)
  if (!force){
    max_year = as.numeric(format(Sys.time(), "%Y")) - 1
  } else {
    max_year = as.numeric(format(Sys.time(), "%Y"))
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
  year_range = seq(start, end, by = 1)
  
  # check the parameters we want to download in case of
  # ALL list all available parameters for each frequency
  if (any(grepl("ALL", toupper(param)))) {
    if (tolower(frequency) == "daily"){
      param = c('vp','tmin','tmax','swe','srad','prcp','dayl')
    } else {
      param = c('vp','tmin','tmax','prcp')
    }
  }

  # provide some feedback
  if(!silent){
    cat('Creating a subset of the Daymet data
        be patient, this might take a while!\n')
  }
  
  for ( i in year_range ){
    for ( j in param ){
      
      if (frequency != "daily"){
        if (j != "prcp"){
          prefix = paste0(substr(frequency,1,3),"avg")
        } else {
          prefix = paste0(substr(frequency,1,3),"ttl")
        }
        
        # create url string (varies per product / year)
        url = sprintf("%s/daymet_v3_%s_%s_%s_na.nc4", base_url, j, prefix, i)
        
        # create filename for the output file
        daymet_file = paste0(path,"/",j,"_",prefix,"_",i,"_ncss.nc")
        
      } else {
        # create url string (varies per product / year)
        url = sprintf("%s/%s/daymet_v3_%s_%s_na.nc4", base_url, i, j, i)
        
        # create filename for the output file
        daymet_file = paste0(path,"/",j,"_daily_",i,"_ncss.nc")
      }
      
      # formulate query to pass to httr           
      query = list(
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
        cat(paste0('\nDownloading DAYMET subset: ',
                  'year: ',i,
                  '; product: ',j,
                  '\n'))
      }
      
      # download data, force binary data mode
      if(silent){
        status = try(utils::capture.output(
          httr::GET(url = url,
                    query = query,
                    httr::write_disk(path = daymet_file, overwrite = TRUE))),
                  silent = TRUE)
      
      } else {
        status = try(httr::GET(url = url,
                               query = query,
                               httr::write_disk(path = daymet_file,
                                                overwrite = TRUE),
                               httr::progress()),
                     silent = TRUE)
      }
      
      # error / stop on 400 error
      if(inherits(status,"try-error")){
        stop("Requested coverage exceeds 6GB file size limit!")
      }
    }
  }
}