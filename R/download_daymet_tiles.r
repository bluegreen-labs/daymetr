#' Function to batch download gridded DAYMET data
#'
#' This function downloads DAYMET data 
#' @param location location of a point c(lat, lon) or a bounding box defined
#' by a top left and bottom-right coordinates c(lat, lon, lat, lon)
#' @param tiles which tiles to download, overrides geographic constraints
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param path where should the downloaded tiles be stored, defaults to the
#' current working directory (default = ".")
#' @param param climate variable you want to download vapour pressure (vp), 
#' minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), 
#' solar radiation (srad), precipitation (prcp) , day length (dayl).
#' The default setting is ALL, this will download all the previously mentioned
#' climate variables.
#' @return downloads netCDF tiles as defined by the Daymet tile grid
#' @keywords daymet, climate data
#' @export
#' @examples
#' 
#' \dontrun{
#' download_daymet_tiles(location = c(35.6737,-86.3968),
#'                       start = 1980,
#'                       end = 1980,
#'                       param = "ALL")
#' }

download_daymet_tiles = function(location = c(35.6737, -86.3968),
                                 tiles = NULL,
                                 start = 1980,
                                 end = 1980,
                                 path = ".",
                                 param = "ALL"){
  
  # set server path
  server = "https://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/1328/tiles"
  
  # grab the projection string. This is a LCC projection.
  # (lazy load the tile_outlines)
  projection = sp::CRS(sp::proj4string(tile_outlines))
  
  # override tile selection if tiles are specified on the command line
  if (!is.null(tiles)){
    tile_selection = as.vector(unlist(tiles))
  } else if ( length(location) == 2 ){
    
    # create coordinate pairs, with original coordinate  system
    location = sp::SpatialPoints(cbind(location[1],location[2]), projection)
    
    # extract tile for this location
    tile_selection = sp::over(location,tile_outlines)$TileID
    
    # do not continue if outside range
    if (is.na(tiles)){
      stop("Your defined range is outside DAYMET coverage,
               check your coordinate values!")
    }
    
  } else if (length(location) == 4 ){
    
    # define a polygon to which will be intersected with the 
    # tiles object to deterrmine tiles to download
    rect_corners = cbind(c(location[2],rep(location[4],2),location[2]),
                         c(rep(location[3],2),rep(location[1],2)))
    ROI = sp::SpatialPolygons(list(sp::Polygons(list(sp::Polygon(list(rect_corners))),"bb")),
                              proj4string = projection)
    
    # extract unique tiles overlapping the rectangular ROI
    tile_selection = unique(sp::over(ROI,tile_outlines, returnList = TRUE)[[1]]$TileID)
    
    # check tile selection
    if (is.null(tile_selection)){
      stop("Your defined range is outside DAYMET coverage,
               check your coordinate values!")
    }
  } else {
    stop("check the coordinates: specifiy a single location,\n
             top-left bottom-right or provide a tile selection \n")
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
  year_range = seq(start,end,by=1)

  # check the parameters we want to download
  if (param[1] == "ALL"){
    param = c('vp','tmin','tmax','swe','srad','prcp','dayl')
  }

  # loop over years, tiles and parameters
  for ( i in year_range ){
    for ( j in tile_selection ){
      for ( k in param ){
        
        # create download string / url  
        download_string = sprintf("%s/%s/%s_%s/%s.nc",server,i,j,i,k)
                
        # create filename for the output file
        daymet_file = paste0(path,"/",k,"_",i,"_",j,".nc")
        
        # provide some feedback
        cat(paste0('Downloading DAYMET data for tile: ',j,
                  '; year: ',i,
                  '; product: ',k,
                  '\n'))
        
        # download daymet tiles using httr
        status = try(httr::GET(url = download_string,
                               httr::write_disk(path = daymet_file,
                                                overwrite = FALSE),
                               httr::progress()),
                     silent = TRUE)
        
        # error / stop on 400 error
        if(inherits(status,"try-error")){
          cat("download failed ... (check warning messages)")
        }
      }
    }
  }
}
