#' Function to geographically subset regions exceeding tile limits
#'
#' This function downloads DAYMET data 
#' @param location location of a bounding box c(lat, lon, lat, lon) defined
#' by a top left and bottom-right coordinates
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param param climate variable you want to download vapour pressure (vp), 
#' minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), 
#' solar radiation (srad), precipitation (prcp) , day length (dayl).
#' The default setting is ALL, this will download all the previously mentioned
#' climate variables.
#' @keywords daymet, climate data
#' @export
#' @examples
#' 
#' \dontrun{
#' download_daymet_ncss(location = c(36.61,-85.37,-81.29,33.57),
#'                       start = 1980,
#'                       end = 1980,
#'                       param = "tmin")
#' }

download_daymet_ncss = function(location = c(36.61, -85.37, -81.29, 33.57),
                                 start = 1988,
                                 end = 1988,
                                 param = "tmin"){
  
  # set server path
  server = "https://thredds.daac.ornl.gov/thredds/ncss/grid/ornldaac/1328"
  
  # check if there are enough coordinates specified
  if (length(location)!=4){
    stop("check coordinates format: top-left / bottom-right c(lat,lon,lat,lon)")
  }
  
  # calculate the end of the range of years to download
  # conservative setting based upon the current date - 1 year
  max_year = as.numeric(format(Sys.time(), "%Y")) - 1
  
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
  
  # check the parameters we want to download
  if (param == "ALL"){
    param = c('vp','tmin','tmax','swe','srad','prcp','dayl')
  }
  
  # provide some feedback
  cat('Creating a subset of the Daymet data
      be patient, this might take a while!\n')
  
  for ( i in year_range ){
    for ( j in param ){
      
      # create server string (varies per product / year)
      server_string = sprintf("%s/%s/daymet_v3_%s_%s_na.nc4", server, i, j, i)
                   
      # formulate query to pass to httr           
      query = list(
        "var" = "lat",
        "var" = "lon",
        "var" = j,
        "north" = location[1],
        "west" = location[2],
        "east" = location[3],
        "south" = location[4],
        "time_start" = paste0(start, "-01-01T12:00:00Z"),
        "time_end" = paste0(end, "-12-30T12:00:00Z")
      )
      
      # create filename for the output file
      daymet_file = paste0(j,"_",i,"_ncss.nc")
      
      # provide some feedback
      cat(paste0('Downloading DAYMET subset: ',
                '; year: ',i,
                '; product: ',j,
                '\n'))
      
      # download data, force binary data mode
      status = try(httr::GET(url = server_string,
                             query = query,
                            httr::write_disk(path = daymet_file,
                                             overwrite = FALSE),
                            httr::progress()),
                  silent = TRUE)
      
      # error / stop on 400 error
      if(inherits(status,"try-error")){
        stop("Requested coverage exceeds 6GB file size limit!")
      }
    }
  }
}