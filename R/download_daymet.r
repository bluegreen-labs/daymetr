#' Function to download single location 'Daymet' data
#'
#' @param site the site name.
#' @param lat latitude (decimal degrees)
#' @param lon longitude (decimal degrees)
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param path set path where to save the data
#' if internal = FALSE (default = NULL)
#' @param internal \code{TRUE} or \code{FALSE}, if \code{TRUE} returns a list to the R workspace if
#' \code{FALSE} puts the downloaded data into the current working directory
#' (default = \code{FALSE})
#' @param silent \code{TRUE} or \code{FALSE} (default), to provide verbose output
#' @param force \code{TRUE} or \code{FALSE} (default),
#' override the conservative end year setting
#' @return Daymet data for a point location, returned to the R workspace or
#' written to disk as a csv file.
#' @keywords Daymet, climate data, single pixel
#' @export
#' @examples
#'
#' \dontrun{
#' # The following commands download and process Daymet data
#' # for 10 years of the >30 year of data available since 1980.
#' daymet_data <- download_daymet("testsite_name",
#'                 lat = 36.0133,
#'                 lon = -84.2625,
#'                 start = 2000,
#'                 end = 2010,
#'                 internal = TRUE)
#'
#' # We can now quickly calculate and plot
#' # daily mean temperature. Also, take note of
#' # the weird format of the header. This format 
#' # is not altered as to keep compatibility
#' # with other ways of acquiring Daymet data
#' # through the ORNL DAAC website.
#' 
#' # The below command lists headers of 
#' # the downloaded nested list.
#' # This data includes information on the site
#' # location etc. The true climate data is stored
#' # in the "data" part of the nested list.
#' # In this case it can be accessed through
#' # daymet_data$data. Other attributes include
#' # for example the tile location (daymet_data$tile),
#' # the altitude (daymet_data$altitude), etc.
#' str(daymet_data)
#' 
#' # load the tidyverse (install if necessary)
#' if(!require(tidyverse)){install.package(tidyverse)}
#' library(tidyverse)
#' 
#' # Calculate the mean temperature from min
#' # max temperatures and convert the year and doy
#' # to a proper date format.
#' daymet_data$data <- daymet_data$data %>%
#'  mutate(tmean = (tmax..deg.c. + tmin..deg.c.)/2,
#'         date = as.Date(paste(year, yday, sep = "-"), "%Y-%j"))
#' 
#' # show a simple graph of the mean temperature
#' plot(daymet_data$data$date,
#'      daymet_data$data$tmean,
#'      xlab = "Date",
#'      ylab = "mean temperature")
#'  
#' # For other practical examples consult the included
#' # vignette. 
#'}

download_daymet = function(site = "Daymet",
                            lat = 36.0133,
                            lon = -84.2625,
                            start = 2000,
                            end = as.numeric(format(Sys.time(), "%Y")) - 2,
                            path = tempdir(),
                            internal = TRUE,
                            silent = FALSE,
                            force = FALSE){

  # CRAN file policy
  if (!silent & !internal & identical(path, tempdir())){
    message("NOTE: by default data is stored in tempdir() ...")
  }
  
  # define API url, might change so put it on top
  url = "https://daymet.ornl.gov/single-pixel/api/data"
  
  # force the max year to be the current year or
  # current year - 1 (conservative)
  if (!force){
    max_year = as.numeric(format(Sys.time(), "%Y")) - 1
  } else {
    max_year = as.numeric(format(Sys.time(), "%Y"))
  }
  
  # check validaty of the range of years to download
  # I'm not sure when new data is released so this might be a
  # very conservative setting, remove it if you see more recent data
  # on the website
  if (start < 1980){
    stop("Start year preceeds valid data range!")
  }

  if (end > max_year){
    stop("End year exceeds valid data range!")
  }

  # if the year range is valid, create a string of valid years
  year_range = paste(seq(start, end, by = 1), collapse=",")
 
  # construct the query to be served to the server
  query = list("lat" = lat,
               "lon" = lon,
               "vars" = "tmax,tmin,dayl,prcp,srad,swe,vp",
               "year" = year_range)
  
  # create filenames for the output files
  daymet_file = file.path(normalizePath(path),
                              sprintf("%s_%s_%s.csv",
                                      site,
                                      start,
                                      end))
  
  daymet_tmp_file = file.path(normalizePath(tempdir()),
                              sprintf("%s_%s_%s.csv",
                                        site,
                                        start,
                                        end))
  
  # provide verbose feedback
  if (!silent){
    cat(paste('Downloading DAYMET data for: ',site,
              ' at ',lat,
              '/',lon,
              ' latitude/longitude !\n',sep=''))
  }

  # try to download the data
  error = try(httr::GET(url = url,
                    query = query,
                    httr::write_disk(path = daymet_tmp_file, overwrite = TRUE)))

  # trap errors on download, return a general error statement
  # with the most common causes
  if (httr::http_error(error) | inherits(error, "try-error")){
    file.remove(daymet_tmp_file)
      stop("Your requested data is outside DAYMET (temporal) coverage,
            or the server can't be reached. Check your the connection to the
            server or the coordinates and start/end years!")
  }
  
  # feedback
  if (!silent) {
    cat('Done !\n')
  }
  
  # if internal is FALSE just copy the temporary
  # file over to the destination path, if TRUE
  # return data to the R workspace
  if (internal) {
    
    # read in a daymet single pixel data file
    tmp_struct = read_daymet(daymet_tmp_file,
                             site = site)
    
    # return the temporary data structure (nested list)
    return(tmp_struct)
    
  } else {
    
    # Copy data from temporary file to final location
    # and delete original, with an exception for tempdir() location.
    # The latter to facilitate package integration.
    if (!identical(daymet_tmp_file, daymet_file)) {
      file.copy(daymet_tmp_file,
                daymet_file,
                overwrite = TRUE,
                copy.mode = FALSE)
      invisible(file.remove(daymet_tmp_file))
    } else {
      message("Output path == tempdir(), file not copied or removed!")
    }
  }
}