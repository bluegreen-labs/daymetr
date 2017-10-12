#' Function to download single location DAYMET data
#'
#' This function downloads DAYMET data for a single
#' location.
#' @param site the site name.
#' @param lat latitude (decimal degrees)
#' @param lon longitude (decimal degrees)
#' @param start start of the range of years over which to download data
#' @param end end of the range of years over which to download data
#' @param path set path where to save the data if internal = FALSE, default is 
#' the current working directory (default = getwd())
#' @param internal TRUE or FALSE, if TRUE returns a list to the R workspace if
#' FALSE puts the downloaded data into the current working directory
#' (default = FALSE)
#' @param quiet TRUE or FALSE, to provide verbose output
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
                            path = getwd(),
                            internal = FALSE,
                            quiet = FALSE){

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
  year_range = paste(seq(start, end, by=1), collapse=",")

  # create download string / url
  download_string = sprintf("https://daymet.ornl.gov/data/send/saveData?lat=%s&lon=%s&measuredParams=tmax,tmin,dayl,prcp,srad,swe,vp&year=%s",lat,lon,year_range)

  # create filename for the output file
  daymet_file = sprintf("%s/%s_%s_%s.csv", path, site, start, end)
  daymet_tmp_file = sprintf("%s/%s_%s_%s.csv", tempdir(), site, start, end)
  
  # provide verbose feedback
  if (quiet == "FALSE"){
    cat(paste('Downloading DAYMET data for: ',site,' at ',lat,'/',lon,' latitude/longitude !\n',sep=''))
  }

  # try to download the data
  error = try(httr::GET(url = download_string,
                         httr::write_disk(path = daymet_tmp_file,
                                          overwrite = FALSE)),
               silent = TRUE)

  # use grepl to trap timeout errors (VPN / firewall issues or server down)
  if (any(grepl("Timeout", error))){
    file.remove(daymet_file)
    stop("Your request timed out, the servers are too busy
          or more likely you are behind a firewall or VPN
          which impedes daymetr traffic!
          [Try again on a later date, or on a direct connection]")
  }

  # double error check on the validity of the files
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

  # if internal is FALSE just copy the temporary
  # file over to the destination path, if TRUE
  # return data to the R workspace
  if (internal) {
    # read ancillary data from downloaded file header
    # this includes, tile nr and altitude
    tile = as.numeric(scan(daymet_tmp_file,
                           skip = 2,
                           nlines = 1,
                           what = character(),
                           quiet = TRUE)[2])

    alt = as.numeric(scan(daymet_tmp_file,
                          skip = 3,nlines = 1,
                          what = character(),
                          quiet = TRUE)[2])

    # read in the real climate data
    data = utils::read.table(daymet_tmp_file,
                      sep = ',',
                      skip = 7,
                      header = TRUE)

    # put all data in a list
    tmp_struct = list(site, lat, lon, alt, tile, data)

    # name all list variables appropriately
    names(tmp_struct) = c('site', 'lattitude', 'longitude', 'altitude', 'tile', 'data')

    # return the temporary data structure (nested list)
    return(tmp_struct)
    
    } else {
      file.copy(daymet_tmp_file, daymet_file)
    }
}
