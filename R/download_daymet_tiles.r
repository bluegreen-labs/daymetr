#' Function to batch download gridded 'Daymet' data tiles
#'
#' @param location location of a point c(lat, lon) or a bounding box defined
#' by a top left and bottom-right coordinates c(lat, lon, lat, lon)
#' @param tiles which tiles to download, overrides geographic constraints
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param path where should the downloaded tiles be stored (default = tempdir())
#' @param param climate variable you want to download vapour pressure (vp), 
#' minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), 
#' solar radiation (srad), precipitation (prcp) , day length (dayl).
#' The default setting is ALL, this will download all the previously mentioned
#' climate variables.
#' @param silent suppress the verbose output
#' @param force \code{TRUE} or \code{FALSE} (default),
#' override the conservative end year setting
#' @return downloads netCDF tiles as defined by the Daymet tile grid
#' @export
#' @examples
#' 
#' \dontrun{
#' Download a single tile of minimum temperature
#' download_daymet_tiles(location = c(18.9103, -114.6109),
#'                       start = 1980,
#'                       end = 1980,
#'                       param = "tmin")
#'                       
#' # For other practical examples consult the included
#' # vignette. 
#' }

download_daymet_tiles <- function(
  location = c(18.9103, -114.6109),
  tiles,
  start = 1980,
  end = 1980,
  path = tempdir(),
  param = "ALL",
  silent = FALSE,
  force = FALSE
  ){
  
  # CRAN file policy
  if (identical(path, tempdir())){
    message("NOTE: data is stored in tempdir() ...")
  }
  
  # set url path
  server_path <- tile_server()
  
  # grab the projection string. This is a LCC projection.
  # (lazy load the tile_outlines)
  projection <- sf::st_crs(daymetr::tile_outlines)
  
  # override tile selection if tiles are specified on the command line
  if (!missing(tiles)){
    tile_selection <- as.vector(unlist(tiles))
  } else if ( length(location) == 2 ){
    
    # create coordinate pairs, with original coordinate  system
    location <- sf::st_sf(
      a = 1,
      geometry = sf::st_sfc(sf::st_point(c(location[2],location[1]))))
    sf::st_crs(location) <- 4326
    
    # extract tile for this location
    tile_selection <- suppressWarnings(
      sf::st_intersection(location,daymetr::tile_outlines)$TileID
    )
    
    # do not continue if outside range
    if (is.na(tile_selection)){
      stop("Your defined range is outside DAYMET coverage,
               check your coordinate values!")
    }
    
  } else if (length(location) == 4 ){
    
    # define a polygon which will be intersected with the 
    # tiles object to deterrmine tiles to download
    rect_corners <- list(
      rbind(
        c(location[2], location[1]),
        c(location[4], location[1]),
        c(location[4], location[3]),
        c(location[2], location[3]),
        c(location[2], location[1])
      ))
    
    p <- sf::st_sf(
      a = 1,
      geometry = sf::st_sfc(sf::st_polygon(rect_corners))
    )
    sf::st_crs(p) <- 4326
    
    tile_selection <- suppressWarnings(
      sf::st_intersection(p,
                      daymetr::tile_outlines)$TileID
      )
    
    # check tile selection
    if (!length(tile_selection)){
      stop("Your defined range is outside DAYMET coverage,
               check your coordinate values!")
    }
    
  } else {
    stop("check the coordinates: specifiy a single location,\n
             top-left bottom-right or provide a tile selection \n")
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
  year_range <- seq(start, end, by=1)

  # check the parameters we want to download
  if (any(grepl("ALL", toupper(param)))) {
    param <- c('vp','tmin','tmax','swe','srad','prcp','dayl')
  }

  # loop over years, tiles and parameters
  for ( i in year_range ){
    for ( j in tile_selection ){
      for ( k in param ){
        
        # create download string / url  
        url <- sprintf("%s/%s/%s_%s/%s.nc",server_path,i,j,i,k)
        
        # create filename for the output file
        daymet_file <- file.path(path, paste0(k,"_",i,"_",j,".nc"))
        
        # provide some feedback if required
        if(!silent){
          message(paste0('\nDownloading DAYMET data for tile: ',j,
                    '; year: ',i,
                    '; product: ',k))
        }
        
        # download data, force binary data mode
        if(silent){
          status <- try(utils::capture.output(
            httr::GET(url = url,
                      httr::write_disk(path = daymet_file,
                                       overwrite = TRUE))),
            silent = TRUE)
          
        } else {
          status <- try(httr::GET(url = url,
                                 httr::write_disk(
                                   path = daymet_file,
                                   overwrite = TRUE),
                                 httr::progress()),
                       silent = TRUE)
        }
        
        # error message on 400 error
        if(inherits(status,"try-error")){
          message("download failed ... (check warning messages)")
        }
      }
    }
  }
}
