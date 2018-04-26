#' Aggregate daily Daymet data
#'
#' Aggregates daily Daymet data by time interval to create 
#' convenient seasonal datasets for data exploration or modelling.
#'
#' @param file The name of the file to be processed. Use daily gridded
#' Daymet data.
#' @param int Interval to aggregate by. Options are "monthly", 
#' "seasonal" or "annual". Seasons are defined as the astronomical seasons
#' between solstices and equinoxes (default = "seasonal")
#' @param fun Function to be used to aggregate data. Genertic R 
#' functions can be used. "mean" and "sum" are suggested. na.rm 
#' = TRUE by default. (default = "mean")
#' @param internal logical If FALSE, write the output to a tif 
#' file using the Daymet file format protocol.
#' @param path path to a directory where output files should be written.
#' Used only if internal = FALSE (default = tempdir())
#' @return aggregated daily Daymet data as a tiff file written
#' to disk or a raster stack when data is returned to the workspace.
#' @keywords daymet, climate data
#' @export
#' @examples
#' 
#'  \dontrun{
#'  # This code calculates the average minimum temperature by 
#'  # season for a subset region.
#'  
#'  # download default ncss tiled subset for 1980
#'  # (daily tmin values only), works on tiles as well
#'  download_daymet_ncss()
#'      
#'  # Finally, run the function
#'  daymet_grid_agg(file = paste0(tempdir(),"/tmin_daily_1980_ncss.nc"),
#'                  int = "seasonal",
#'                  fun = "mean")
#'  }

daymet_grid_agg = function(file = NULL,
                           int = "seasonal",
                           fun = "mean",
                           internal = FALSE,
                           path = tempdir()){
  
  # stop on missing files
  if (is.null(file) ){
    stop('File not provided...')
  }
  
  # check if the file exists and is a daily file
  if (!file.exists(file) ){
    stop('File does not exist...')
  }
  
  # get file extension
  ext <- tools::file_ext(file)
  
  # load data into a raster brick
  data <- suppressWarnings(raster::brick(file))
  
  # check if the data is daily or not
  if (raster::nlayers(data) < 365){
    stop("Provided data isn't at a daily time step...")
  }
  
  # extract time variable from data and covert to date format
  if (ext == 'tif' | ext == 'nc'){
    if (ext == 'nc'){ # extract dates from .nc file
      dates <- as.Date(
        sub(pattern = "X",
            replacement = "",
            x = names(data)),
        format = "%Y.%m.%d")
      yr <- strsplit(as.character(dates), "-")[[1]][1]
    } else { # construct dates using order of bands and year from .tif file
      dy <- as.numeric(as.vector(t(as.data.frame(strsplit(names(data),
                                                          "[.]"))[2,])))
      yr <- strsplit(names(data), "_")[[1]][3]
      dates <- as.Date(x = dy, origin = sprintf('%s-01-01',yr))
    }
  } else {
    stop('Unable to read dates.\n
         Files must be outputs from daymetr functions in tif or nc format.')
  }
  
  # use int to create list of values to be used by aggregate function
  if (int == 'monthly'){
    ind <- months(dates)
  }
  if (int == 'annual'){
    ind <- as.numeric(substring(dates,1,4))
  }
  if (int == 'seasonal'){
    
    # set standard season change-over dates for the relevant year
    spring_equinox <- as.Date(sprintf("%s.03.20", yr), format = "%Y.%m.%d")
    summer_solstice <- as.Date(sprintf("%s.06.21", yr), format = "%Y.%m.%d")
    fall_equinox <- as.Date(sprintf("%s.09.22", yr), format = "%Y.%m.%d")
    winter_solstice <- as.Date(sprintf("%s.12.21", yr), format = "%Y.%m.%d")
    year_start <- utils::head(dates, n = 1)
    year_end <- utils::tail(dates, n = 1)
    
    # create a date sequence for each season
    winter_start <- seq(from = year_start,
                        to = (spring_equinox - 1),
                        by = "days")
    spring <- seq(from = spring_equinox,
                  to = (summer_solstice - 1),
                  by = "days")
    summer <- seq(from = summer_solstice,
                  to = (fall_equinox - 1),
                  by = "days")
    fall <- seq(from = fall_equinox,
                to = (winter_solstice - 1),
                by = "days")
    winter_end <- seq(from = winter_solstice,
                      to = year_end,
                      by = "days")
    
    # set season name as values of each date sequence
    winter_start_lab <- rep("winter", times = length(winter_start))
    spring_lab <- rep("spring", times = length(spring))
    summer_lab <- rep("summer", times = length(summer))
    fall_lab <- rep("fall", times = length(fall))
    winter_end_lab <- rep("winter", times = length(winter_end))
    
    # create ind vector of season labels in chronological order
    ind <- c(winter_start_lab, spring_lab, summer_lab, fall_lab, winter_end_lab)
  }
  
  # aggregate bands by int using base R function aggregate
  result <- raster::stackApply(x = data,
                               indices = ind,
                               fun = fun,
                               na.rm = TRUE)
  
  # return all data to raster, either as a geotiff or as a local object
  if (internal == FALSE){
    
    # create output file name
    input_file <- tools::file_path_sans_ext(basename(file))
    param <- strsplit(input_file, "_")[[1]][1]
    year <- strsplit(input_file, "_")[[1]][3]
    output_file <- file.path(normalizePath(path),
                             sprintf('%s_agg_%s_%s%s.tif', param, year, int, fun))
    
    # write raster object to file
    raster::writeRaster(x = result,
                        filename = output_file,
                        overwrite = TRUE)
  } else {
    # return to workspace
    return(result)
  }
  }