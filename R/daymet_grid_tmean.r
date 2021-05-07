#' Averages tmax and tmin 'Daymet' gridded products
#' 
#' Combines data into a single mean daily temperature (tmean) 
#' gridded output (geotiff) for easy post processing and modelling. 
#' Optionally a raster object is returned to the current workspace.
#'
#' @param path full path location of the daymet tiles (default = tempdir())
#' @param product either a tile number or a ncss product name
#' @param year which year to process
#' @param internal \code{TRUE} / \code{FALSE} (if \code{FALSE},
#' write the output to file)
#' using the Daymet file format protocol.
#' @export
#' @examples
#'
#' \dontrun{
#' # This code calculates the mean temperature
#' # for all daymet tiles in a user provided
#' # directory. In this example we first
#' # download tile 11935 for tmin and tmax
#' 
#' # download a tile
#' download_daymet_tiles(tiles = 11935,
#'                       start = 1980,
#'                       end = 1980,
#'                       param = c("tmin","tmax"),
#'                       path = tempdir())
#' 
#' # calculate the mean temperature and export
#' # the result to the R workspace (internal = TRUE)
#' # If internal = FALSE, a file tmean_11935_1980.tif
#' # is written into the source path (path_with_daymet_tiles)
#' tmean <- daymet_grid_tmean(path = tempdir(),
#'                           tile = 11935,
#'                           year = 1980,
#'                           internal = TRUE)
#' }

daymet_grid_tmean <- function(
  path = tempdir(),
  product,
  year,
  internal = FALSE
  ){
  
  # CRAN file policy
  if (identical(path, tempdir())){
    message("Using default path tempdir() ...")
  }
  
  # exit on missing tile
  if ( missing(product) | missing(year) ) {
    stop('No tile or year provided ...')
  }
  
  # depending on the input query find the necessary data files
  if(!is.character(product)){
    # list all files
    tmin <- sprintf('%s/tmin_%s_%s.nc',path, year, product)
    tmax <- sprintf('%s/tmax_%s_%s.nc',path, year, product)
    output_file <- sprintf('%s/tmean_%s_%s.tif', path, year, product)
  } else {
    tmin <- sprintf('%s/tmin_%s_%s_ncss.nc',path, product, year)
    tmax <- sprintf('%s/tmax_%s_%s_ncss.nc',path, product, year)
    output_file <- sprintf('%s/tmean_%s_%s_ncss.tif', path, product, year)
  }
  
  # check if both files exist, if not stop
  if(any(!file.exists(tmin) | !file.exists(tmax))){
    stop('missing files, or non existing directory ...')
  }
  
  # load everything into a raster stack
  minmax_stack <- suppressWarnings(raster::stack(tmin, tmax))
  
  # list layers
  l <- rep(1:(raster::nlayers(minmax_stack)/2),2)
  
  # calculate layer mean, but back in tmean stack
  tmean_stack <- suppressWarnings(
    raster::stackApply(minmax_stack,
                       indices = l,
                       fun = mean,
                       na.rm = TRUE)
    )

  # return all data to raster, either as a geotiff
  # or as a local object
  if (internal == FALSE){
    suppressWarnings(
      raster::writeRaster(tmean_stack,
                          output_file,
                          overwrite = TRUE)
    )
  } else {
    return(tmean_stack)
  }
}
