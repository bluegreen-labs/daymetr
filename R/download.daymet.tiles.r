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
#' @keywords DAYMET, climate data
#' @export
#' @examples
#' download.daymet.tiles(lat1=36.0133,
#'                       lon1=-84.2625,
#'                       start_yr=1980,
#'                       end_yr=2000,
#'                       param="ALL")

download.daymet.tiles = function(lat1=36.0133,
                                 lon1=-84.2625,
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
  data("DAYMET_grid")
  
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
      
        # create coordinate pairs, with original coordinate system
        topleft = sp::SpatialPoints(cbind(lon1,lat1), projection)
        bottomright = sp::SpatialPoints(cbind(lon2,lat2), projection)

        # this is some juggling to define a polygon (vector format)
        # which I will convert to LCC and use as a mask to extract
        # tile numbers. As such I avoid artefacts due to resampling.
        poly_corners = matrix(NA,5,2)
        poly_corners[1,] = c(lon1,lat2)
        poly_corners[2,] = c(lon2,lat2)
        poly_corners[3,] = c(lon2,lat1)
        poly_corners[4,] = c(lon1,lat1)
        poly_corners[5,] = c(lon1,lat2)
        
        # make into a polygon object
        ROI = sp::SpatialPolygons(list(sp::Polygons(list(sp::Polygon(poly_corners)),1)))
        
        # set original projection
        sp::proj4string(ROI) = projection
        
        # extract pixels within the ROI
        r = rgeos::gIntersection(ROI,tile_outlines,byid=TRUE)
        
        if (is.null(r)){
          stop("Your defined range is outside DAYMET coverage,
               check your coordinate values!")
        }
        
        # extract tile IDs and match to DAYMET grid IDs
        polygon_nr = as.numeric(sapply(r@polygons,function(x)unlist(strsplit(x@ID,split=' '))[2])) + 1
        tiles = tile_nrs[polygon_nr]
  }
  
  # calculate the end of the range of years to download
  # conservative setting based upon the current date
  # -1 year
  max_year = as.numeric(format(Sys.time(), "%Y"))-1
  
  # check validaty of the range of years to download
  # I'm not sure when new data is released so this might be a
  # very conservative setting, remove it if you see more recent data
  # on the website
  
  if (start_yr < 1980){
    stop("Start year preceeds valid data range!")
  }
  
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
        download_string = sprintf("http://thredds.daac.ornl.gov/thredds/catalog/ornldaac/1328/tiles/%s/%s_%s/%s.nc",i,j,i,k)
                
        # create filename for the output file
        daymet_file = paste(k,"_",i,"_",j,".nc",sep='')
        
        # provide some feedback
        cat(paste('Downloading DAYMET data for tile: ',j,
                  '; year: ',i,
                  '; product: ',k,
                  '\n',sep=''))
        
        # download data, force binary data mode
        try(downloader::download(download_string,
                                 daymet_file,
                                 quiet=TRUE,
                                 mode="wb"),silent=FALSE)  
      }
    }
  }
}
