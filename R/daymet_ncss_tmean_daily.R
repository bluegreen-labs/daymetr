#' Averages tmax and tmin 'Daymet' tiles from ncss
#' subsets into a single mean temperature (tmean)
#' tiles for easy post processing and modelling.
#' 
#' This version of daymet_ncss_tmean works with
#' daily data.
#' 
#' Outputs a geotiff using the same naming scheme
#' as the original files. Optionally a raster object
#' is returned to the current workspace.
#'
#' This code is based on the daymet_tile_tmean
#' function in the daymetr package
#' (From: https://github.com/khufkens/daymetr )
#' 
#' @param path a character string containing the 
#' directory path in which to locate the tmin and 
#' tmax files
#' @param year a numeric indicating the year for 
#' which tmean is to be calculated
#' @param internal a logical indicating whether 
#' the file should be written as a GTiff (FALSE) 
#' or brought into the workspace (TRUE)

daymet_ncss_tmean_daily = function(path='.',
                                   year = NULL,
                                   internal = FALSE){
  
  # reproject to lat-lon
  latlon = sp::CRS("+init=epsg:4326")
  
  if (is.null(year)){
    stop('No year provided ...')
  }
  
  # list all files
  tmin = sprintf('tmin_%s_ncss.nc', year)
  tmax = sprintf('tmax_%s_ncss.nc', year)
  
  # load everything into a raster stack (dependent on ncdf4 package)
  #library(ncdf4)
  minmax_stack = raster::stack(tmin, tmax)
  
  # list layers
  layers = rep(1:365,2)
  
  # calculate layer mean, but back in tmean stack
  tmean_stack = raster::stackApply(minmax_stack,
                                   indices = layers,
                                   fun = mean)
  
  # return all data to raster, either as a geotiff
  # or as a local object
  if (internal == FALSE){
    raster::writeRaster(tmean_stack,
                        sprintf('tmean_%s_ncss.tif', year),
                        overwrite = TRUE)
  } else {
    return(tmean_stack)
  }
}