#' Interface to the 'Daymet' Web Services
#' 
#' Programmatic interface to the 'Daymet' web services 
#' (\url{https://daymet.ornl.gov}). Allows for easy downloads of 
#' Daymet climate data directly to your R workspace or your computer.
#' Routines for both single pixel data downloads and gridded 
#' (netCDF) data are provided.
#' 
#' @author Koen Hufkens
#' @section daymetr functions:
#' \tabular{llllll}{
#' \code{\link{download_daymet}}\cr
#' \code{\link{download_daymet_batch}}\cr
#' \code{\link{download_daymet_tiles}}\cr
#' \code{\link{download_daymet_ncss}}\cr
#' \code{\link{daymet_grid_tmean}}\cr
#' \code{\link{daymet_grid_offset}}\cr
#' \code{\link{daymet_grid_agg}}\cr
#' \code{\link{nc2tif}}\cr
#' \code{\link{read_daymet}}\cr
#' \code{\link{calc_nd}}
#' }
#' 
#' @docType package
#' @name daymetr
#' @keywords package
NULL
