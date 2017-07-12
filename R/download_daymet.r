#' Function to download single location DAYMET data
#'
#' This function downloads DAYMET data for a single
#' location.
#' @param site : the site name.
#' @param lat : latitude (decimal degrees)
#' @param lon : longitude (decimal degrees)
#' @param start : start of the range of years over which to download data
#' @param end : end of the range of years over which to download data
#' @param internal : takes FALSE, "assign" or "data.frame",
#' Download to file (FALSE) or "assign" a variable dynamically or return a
#' data frame to the command line
#' @param quiet: TRUE or FALSE, to provide verbose output
#' @keywords DAYMET, climate data
#' @export
#' @examples
#'
#' \dontrun{
#' download_daymet("testsite_name",
#'                 lat=36.0133,
#'                 lon=-84.2625,
#'                 start=2000)
#' }

download_daymet = function(site = "Daymet",
                            lat = 36.0133,
                            lon = -84.2625,
                            start = 2000,
                            end = as.numeric(format(Sys.time(), "%Y"))-1,
                            internal = FALSE,
                            quiet = FALSE){

  # set path, the current working directory if not internal
  # otherwise the tmp location
  if (internal == "assign" || internal == "data.frame"){
    path = tempdir()
  } else {
    path = getwd()
  }

  # calculate the end of the range of years to download
  max_year = as.numeric(format(Sys.time(), "%Y"))-1

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
  year_range = paste(seq(start,end,by=1),collapse=",")

  # create download string / url
  download_string = sprintf("https://daymet.ornl.gov/data/send/saveData?lat=%s&lon=%s&measuredParams=tmax,tmin,dayl,prcp,srad,swe,vp&year=%s",lat,lon,year_range)

  # create filename for the output file
  daymet_file = sprintf("%s/%s_%s_%s.csv",path,site,start,end)

  if (quiet == "FALSE"){
    cat(paste('Downloading DAYMET data for: ',site,' at ',lat,'/',lon,' latitude/longitude !\n',sep=''))
  }

  # try to download the data
  error = try(curl::curl_download(download_string,
                                   daymet_file,
                                   mode="w",
                                   quiet=TRUE),silent=TRUE)

  # use grepl to trap timeout errors (VPN / firewall issues or server down)
  if (any(grepl("Timeout", error))){
    file.remove(daymet_file)
    stop("Your request timed out, the servers are too busy
          or more likely you are behind a firewall or VPN
          which impedes daymetr traffic!
          [Try again on a later date, or on a direct connection]")
  }

  # double error check on the validity of the fileSs
  # Daymet stopped giving errors on out of geographic range requests
  # these are not trapped anymore with the usual routine
  # below, until further notice this patch is in place
  if(file.exists(daymet_file)){
    error = try(utils::read.table(daymet_file,header=T,sep=','),silent=TRUE)
    if (inherits(error,"try-error")){
      file.remove(daymet_file)
      stop("Your requested data is outside DAYMET coverage,
           the file is empty --> check coordinates!")
    }

    # use grepl instead of grep, returns logical any() ensures one argument is returned
    if (any(grepl("HTTP Status 500", error))){
      file.remove(daymet_file)
      stop("Your requested data is outside DAYMET coverage,
           the file is empty --> check coordinates!")
    }
  }

  # new download.file behaviour deletes files if they are empty 0 bytes
  # so testing for the presence of the file works now
  if (inherits(error,"try-error")){
    stop("Your requested data is outside DAYMET coverage,
         the file is empty --> check coordinates!")
  }

  # feedback
  if (quiet == "FALSE") {
    cat('Done !\n')
  }

  # if internal is FALSE assign the downloaded datafile to
  # an internal variable (we'll keep the original file)
  if (internal == "assign" || internal == "data.frame") {

    # read ancillary data from downloaded file header
    # this includes, tile nr and altitude
    tile = as.numeric(scan(daymet_file,
                           skip = 2,
                           nlines = 1,
                           what = character(),
                           quiet = TRUE)[2])

    alt = as.numeric(scan(daymet_file,
                          skip = 3,nlines = 1,
                          what = character(),
                          quiet = TRUE)[2])

    # read in the real climate data
    data = utils::read.table(daymet_file,
                      sep = ',',
                      skip = 7,
                      header = TRUE)

    # put all data in a list
    tmp_struct = list(site, lat, lon, alt, tile, data)

    # name all list variables appropriately
    names(tmp_struct) = c('site', 'lattitude', 'longitude', 'altitude', 'tile', 'data')

    # reassign the data a new name in your global workspace (outside the function)
    # or return a data frame to the command line
    if (internal == "assign") {
      assign(site, tmp_struct, envir = .GlobalEnv)
    } else {
      # return data frame
      return(tmp_struct)
    }
  }
}
