#' Function to batch download gridded DAYMET data
#'
#' This function downloads DAYMET data 
#' @param lat1 : top left latitude (decimal degrees)
#' @param lon1 : top left longitude (decimal degrees)
#' @param lat2 : bottom right latitude (decimal degrees)
#' @param lon2 : bottom right longitude(decimal degrees)
#' @param start_yr : start of the range of years over which to download data
#' @param end_yr : end of the range of years over which to download data
#' @param param : climate variable you want to download vapour pressure (vp), 
#' minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), 
#' solar radiation (srad), precipitation (prcp) , day length (dayl).
#' The default setting is ALL, this will download all the previously mentioned
#' climate variables.
#' @keywords daymet, climate data
#' @export
#' @examples
#' 
#' # NOT RUN
#' # download.daymet.tiles(lat1=35.6737,
#' #                       lon1=-86.3968,
#' #                       start_yr=1980,
#' #                       end_yr=1980,
#' #                       param="ALL")

download.daymet.tiles = function(lat1=35.6737,
                                 lon1=-86.3968,
                                 lat2=NA,
                                 lon2=NA,
                                 start_yr=1980,
                                 end_yr=1980,
                                 param="ALL"){
  
  # determine system
  OS = Sys.info()[['sysname']]
  
  # load DAYMET grid associated with the package
  # (this is an imported shapefile)
  # I do not store any additional data in the .rdata
  # file to keep the code transparent.
  utils::data("DAYMET_grid")
  
  # grab the projection string. This is a LCC projection.
  projection = sp::CRS(sp::proj4string(tile_outlines))
  
  # extract tile IDs (vector shape) and the DAYMET IDs associated
  # with them
  tile_nrs = tile_outlines@data[,1]
  
  # if argument 3 or 4 are the default grab only the tile
  # of the first coordinate set, if 4 arguments are given
  # extract all tile numbers within this region of interest
  if ( is.na(lat2) | is.na(lon2)){
    
        # create coordinate pairs, with original coordinate  system
        location = sp::SpatialPoints(cbind(lon1,lat1), projection)
        
        # extract tile for this location
        tiles = sp::over(location,tile_outlines)$TileID
        
        # do not continue if outside range
        if (is.na(tiles)){
          stop("Your defined range is outside DAYMET coverage,
               check your coordinate values!")
        }

      }else{
        
        # this is some juggling to define a polygon (vector format)
        # which I will convert to LCC and use as a mask to extract
        # tile numbers. As such I avoid artefacts due to resampling.
        rect_corners = cbind(c(lon1,rep(lon2,2),lon1),
                             c(rep(lat2,2),rep(lat1,2)))
        ROI = sp::SpatialPoints(cbind(rect_corners[,1],
                                      rect_corners[,2]), projection)
        
        # set original projection
        sp::proj4string(ROI) = projection
        
        # extract unique tiles overlapping the rectangular ROI
        tiles = unique(sp::over(ROI,tile_outlines)$TileID)
        
        if (is.null(tiles)){
          stop("Your defined range is outside DAYMET coverage,
               check your coordinate values!")
        }
  }
  
  # calculate the end of the range of years to download
  # conservative setting based upon the current date -1 year
  max_year = as.numeric(format(Sys.time(), "%Y"))-1
  
  # check validaty of the range of years to download
  # I'm not sure when new data is released so this might be a
  # very conservative setting, remove it if you see more recent data
  # on the website
  
  if (start_yr < 1980){
    stop("Start year preceeds valid data range!")
  }
  rect_corners = cbind(c(lon1,rep(lon2,2),lon1),c(rep(lat2,2),rep(lat1,2)))
  
  if (end_yr > max_year){
    stop("End year exceeds valid data range!")
  }
  
  # if the year range is valid, create a string of valid years
  year_range = seq(start_yr,end_yr,by=1)

  # check the parameters we want to download
  if (param == "ALL"){
    param = c('vp','tmin','tmax','swe','srad','prcp','dayl')
  }

  for ( i in year_range ){
    for ( j in tiles ){
      for ( k in param ){
        
        # create download string / url  
        download_string = sprintf("http://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/1328/tiles/%s/%s_%s/%s.nc",i,j,i,k)
                
        # create filename for the output file
        daymet_file = paste(k,"_",i,"_",j,".nc",sep='')
        
        # provide some feedback
        cat(paste('Downloading DAYMET data for tile: ',j,
                  '; year: ',i,
                  '; product: ',k,
                  '\n',sep=''))
        
        # download data, force binary data mode
        try(curl::curl_download(download_string,
                                 daymet_file,
                                 quiet=TRUE,
                                 mode="wb"),silent=FALSE)  
      }
    }
  }
}
