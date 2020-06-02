#' Returns a time shifted (offset) dataset
#' 
#' Returns an offset dataset with data running from offset DOY in year - 1 to
#' offset DOY in the current year. Two years of data (730 data layers) are
#' required for this function to work. The output serves as input for further
#' data processing and / or ecosystem modelling efforts.
#'
#' @param data rasterStack or rasterBrick of 730 layers (2 consecutive years)
#' @param offset offset of the time series in DOY (default = 264, sept 21)
#' @export
#' @examples
#'
#' \dontrun{
#' my_subset <- daymet_gridded_offset(mystack, offset = 264)
#' }

# create subset of layers to calculate phenology model output on
daymet_grid_offset <- function(data, offset = 264){

  # sanity check
  if(raster::nlayers(data) != 730){
    stop("Does not contain two years worth of data, check stack size...")
  }

  # make a number of assumptions on the data structure
  # mainly there are 730 layers per above, which are ordered
  # sequantially 1:365 (days) x 2, this avoids dealing with
  # extracting info from layer names
  layer_year <- sort(rep(1:2,365))
  layer_doy <- rep(1:365,2)

  # final layer selection
  layer_selection <- which((layer_year == 1 & layer_doy >= offset) |
                            (layer_year == 2 & layer_doy < offset))

  # subset the data and assign correct
  # layer names, for clarity
  s <- raster::subset(data, layer_selection)
  names(s) <- layer_doy[layer_selection]

  # final subset for phenology modelling
  return(s)
}
