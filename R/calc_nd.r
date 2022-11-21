#' Count days meeting set criteria
#'
#' Function to count the number of days in a given time period
#' that meet a given set of criteria. This can be used to extract indices 
#' such as Growing Degree Days (tmin > 0), or days with precipitation 
#' (prcp != 0).
#' 
#' @param file path of a file containing the daily gridded Daymet data
#' @param start_doy numeric day-of-year at which counting should begin. 
#' (default = 1)
#' @param end_doy numeric day of year at which counting should end. 
#' (default = 365)
#' @param criteria logical expression (">=",">","<=","<","==", "!=") to evaluate
#' @param value the value that the criteria is evaluated against
#' @param internal return to workspace (\code{TRUE}) or write to disk
#' (\code{FALSE}) (default = \code{FALSE})
#' @param path path to which to write data to disk (default = tempdir())
#' @return A raster object in the R workspace or a file on disk with summary
#' statistics for every pixel which meet the predefined criteria. Output files
#' if written to file will be named nd_YYYY.tif (with YYYY the year of the
#' processed tile or ncss netCDF file).
#' 
#' @import ncdf4
#' @export
#' @examples
#'
#' \dontrun{
#' # download daily gridded data
#' # using default settings (data written to tempdir())
#' download_daymet_ncss()
#' 
#' # read in the Daymet file and report back the number
#' # of days in a year with a minimum temperature lower
#' # than 15 degrees C
#' r <- calc_nd(file.path(tempdir(),"tmin_daily_1980_ncss.nc"),
#'             criteria = "<",
#'             value = 15,
#'             internal = TRUE)
#'             
#' # plot the output
#' terra::plot(r)
#' }

calc_nd <- function(
  file,
  start_doy = 1,
  end_doy = 365,
  criteria,
  value,
  internal = FALSE,
  path = tempdir()
  ){
  
  # perform input checks
  if(missing(file) | missing(criteria) | missing(value)){
    stop('Please specify file, criteria and value.')
  }
  
  # sanity checks
  if (end_doy < start_doy){
    stop('Start day-of-year (doy) is later than the end doy,
         check doy values!')
  }
  
  if ( !(criteria %in% c(">=",">","<=","<","==", "!=")) ){
    stop('Not a logical criteria. Please select a logical statement
         such as ">=",">","<=","<","==", "!=".')
  }
  
  # load desired bands from file
  data <- terra::rast(file, lyrs = c(start_doy:end_doy))
  
  # use a binary operator to identify pixels that meet the criteria
  sel <- do.call(criteria, list(data, value))
  
  # use SUM to gather the number of days that meet the criteria
  result <- terra::app(
    x = sel,
    fun = sum,
    na.rm = TRUE
  )
  
  # return all data to raster, either as a geotiff or as a local object
  if (internal == FALSE){
    
    # create output file name
    year <- strsplit(basename(file), "_")[[1]][3]
    output_file <- file.path(path,
                             sprintf('nd_%s.tif',year))
    
    # write result to file
    suppressWarnings(
      terra::writeRaster(
        result,
        output_file,
        overwrite = TRUE
        )
      )
  } else {
    # return result
    return(result)
  }
}
