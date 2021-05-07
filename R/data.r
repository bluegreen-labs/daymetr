#' tile_outlines
#'
#' Large simple feature collection containing the outlines of all the 
#' Daymet tiles available as well as projection information. This data
#' was converted from a shapefile as provided on the Daymet main website.
#' 
#' @format SpatialPolygonDataFrame
#' \describe{
#'   \item{TileID}{tile ID number}
#'   \item{XMin}{minimum longitude}
#'   \item{XMax}{maximum longitude}
#'   \item{YMin}{minimum latitude}
#'   \item{YMax}{maximum latitude}
#' }
"tile_outlines"
