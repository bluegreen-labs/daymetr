#' Function to download single location DAYMET data
#'
#' This function downloads DAYMET data for a single
#' location.
#' @param site : the site name.
#' @param lat : latitude (decimal degrees)
#' @param lon : longitude (decimal degrees)
#' @param start_yr : start of the range of years over which to download data
#' @param end_yr : end of the range of years over which to download data
#' @param internal : TRUE or FALSE, load data into workspace or save to disc
#' @param quiet: TRUE or FALSE, to provide verbose output
#' @keywords DAYMET, climate data
#' @export
#' @examples
#' 
#' # NOT RUN
#' # download.daymet("testsite",
#' #                 lat=36.0133,
#' #                 lon=-84.2625,
#' #                 start_yr=1980)

# TODO: rewrite to use RCurl instead of downloader

download.daymet = function(site="Daymet",
                            lat=36.0133,
                            lon=-84.2625,
                            start_yr=1980,
                            end_yr=as.numeric(format(Sys.time(), "%Y"))-1,
                            internal=FALSE,
                            quiet=FALSE){
  
  # calculate the end of the range of years to download
  max_year = as.numeric(format(Sys.time(), "%Y"))-1
  
  # check validaty of the range of years to download
  # I'm not sure when new data is released so this might be a
  # very conservative setting, remove it if you see more recent data
  # on the website
  
  if (start_yr < 1980){
    stop("Start year preceeds valid data range!")
  }
  
  if (end_yr > max_year){
    stop("End year exceeds valid data range!")
  }

  # if the year range is valid, create a string of valid years
  year_range = paste(seq(start_yr,end_yr,by=1),collapse=",")
  
  # create download string / url
  download_string = sprintf("https://daymet.ornl.gov/data/send/saveData?lat=%s&lon=%s&measuredParams=tmax,tmin,dayl,prcp,srad,swe,vp&year=%s",lat,lon,year_range)

  # create filename for the output file
  daymet_file = sprintf("%s_%s_%s.csv",site,start_yr,end_yr)
  
  if (quiet=="FALSE"){
    cat(paste('Downloading DAYMET data for: ',site,' at ',lat,'/',lon,' latitude/longitude !\n',sep=''))
  }
  
  # download the data into file daymet_file
  error = try(downloader::download(download_string,
                                   daymet_file,
                                   extra=getOption("-f"),
                                   quiet=TRUE),silent=TRUE)
  
  # double error check on the validity of the file
  # Daymet stopped giving errors on out of geographic range requests
  # these are not trapped anymore with the usual routine
  # below, until further notice this patch is in place
  if(file.exists(daymet_file)){
    error = try(utils::read.table(daymet_file,header=T,sep=','),silent=TRUE)
    if (inherits(error,"try-error")){
      file.remove(daymet_file)
      stop("You requested data is outside DAYMET coverage,
           the file is empty --> check coordinates!")
    }
    
    # use grepl instead of grep, returns logical any() ensures one argument is returned
    if (any(grepl("HTTP Status 500", error))){ 
      file.remove(daymet_file)
      stop("You requested data is outside DAYMET coverage,
           the file is empty --> check coordinates!")
    }
  }
  
  # new download.file behaviour deletes files if they are empty 0 bytes
  # so testing for the presence of the file works now
  if (inherits(error,"try-error")){
    stop("You requested data is outside DAYMET coverage,
         the file is empty --> check coordinates!")
  }
  
  # if internal is FALSE assign the downloaded datafile to
  # an internal variable (we'll keep the original file)
  if (internal == T || internal == TRUE) {
    
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
    # and delete the original
    assign(site, tmp_struct, envir = .GlobalEnv)
    rm(tmp_struct)
  }
  
  # feedback
  if (quiet == "FALSE") {
    cat('Done !\n')
  }
}