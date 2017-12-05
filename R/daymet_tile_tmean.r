#' Averages tmax and tmin 'Daymet' tiles into
#' a single mean daily temperature (tmean) tile
#' for easy post processing and modelling.
#'
#' Outputs a geotiff using the same naming scheme
#' as the original files. Optionally a raster object
#' is returned to the current workspace.
#'
#' @param path full path location of the daymet tiles
#' @param tile which tile to process
#' @param year which year to process
#' @param internal TRUE / FALSE (if FALSE, write the output to file)
#' using the Daymet file format protocol.
#' @keywords modelling, mean daily temperature
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
#'                       path = "path_with_daymet_tiles")
#' 
#' # calculate the mean temperature and export
#' # the result to the R workspace (internal = TRUE)
#' # If internal = FALSE, a file tmean_11935_1980.tif
#' # is written into the source path (path_with_daymet_tiles)
#' tmean = daymet_tile_tmean(path = "path_with_daymet_tiles",
#'                           tile = 11935,
#'                           year = 1980,
#'                           internal = TRUE)
#' }

daymet_tile_tmean = function(path='.',
                        tile = NULL,
                        year = NULL,
                        internal = FALSE){

  # reproject to lat-lon
  latlon = sp::CRS("+init=epsg:4326")

  # exit on missing tile
  if ( is.null(tile) | is.null(year) ) {
    stop('No tile or year provided ...')
  }

  # list all files
  tmin = sprintf('%s/tmin_%s_%s.nc',path, year, tile)
  tmax = sprintf('%s/tmax_%s_%s.nc',path, year, tile)

  # load everything into a raster stack
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
              sprintf('%s/tmean_%s_%s.tif', path, year, tile),
              overwrite = TRUE)
  } else {
    return(tmean_stack)
  }
}
