#' Read Single Pixel Daymet data
#' 
#' Reads Single Pixel Daymet data into a nested list or tibble,
#' preserving header data and critical file name information.
#' 
#' @param file a Daymet Single Pixel data file
#' @param site a sitename (default = \code{NULL})
#' @param skip_header do not ingest header meta-data, logical \code{FALSE}
#' or \code{TRUE} (default = \code{FALSE})
#' @param simplify output tidy data (tibble), logical \code{FALSE}
#' or \code{TRUE} (default = \code{TRUE})
#' @return A nested data structure including site meta-data, the full
#' header and the data as a `data.frame()`.
#' 
#' @export
#' @examples
#'
#' \dontrun{
#' # download the data
#' download_daymet(
#' site = "Daymet",
#' start = 1980,
#' end = 1980,
#' internal = FALSE,
#' silent = TRUE
#' )
#'
#' # read in the Daymet file
#' df <- read_daymet(paste0(tempdir(),"/Daymet_1980_1980.csv"))
#'
#' # print data structure
#' print(str(df))
#' }

read_daymet <- function(
  file,
  site,
  skip_header = FALSE,
  simplify = TRUE
  ){
  
  # stop on missing files
  if (missing(file) ){
    stop('File not provided...')
  }
  
  if (missing(site)){
    site <- "tmp"
    message("Sitename set to default - tmp")
  }
  
  # check if the file exists and is a daily file
  if (!file.exists(file) ){
    stop('File does not exist...')
  }
  
  # read and format header, read past the header (should the length)
  # change in the future with a few lines this then does not break
  # the script
  header <- try(readLines(file, n = 30), silent = TRUE)
  
  # get the location of the true table header
  # based upon the two fields which will always be there
  # year and yday
  table_cols <- grep("year,yday", header)
  
  # warning / stop if key data table header elements are not found
  if (length(table_cols) == 0 || skip_header){
    message("Key table header elements are missing, Daymet format change?")
    message("Using NA fill values.")
  }  
    
  if (table_cols > 1){
    
    # header is defined as everything before the
    header <- tolower(header[1:(table_cols-1)])
    
    # read ancillary data from downloaded file header
    # this includes, tile nr and altitude etc. use gregexpr()
    # and regmatches to extract relevant data
    tile <- as.numeric(regmatches(header[grep("tile:", header)],
                                 gregexpr("[-+]*[0-9,.]+",
                                 header[grep("tile:", header)])))
    
    alt <- as.numeric(regmatches(header[grep("elevation:", header)],
                                gregexpr("[-+]*[0-9,.]+",
                                header[grep("elevation:", header)])))
    
    lat <- as.numeric(unlist(regmatches(header[grep("latitude:", header)],
                                  gregexpr("(?<=latitude: )[-+]*[0-9,.]+",
                                  header[grep("latitude:", header)],
                                  perl = TRUE))))
    
    lon <- as.numeric(unlist(regmatches(header[grep("longitude:", header)],
                                 gregexpr("(?<=longitude: )[-+]*[0-9,.]+",
                                 header[grep("longitude:", header)],
                                 perl = TRUE))))
    
    # check if all fields are correctly populated,
    # if not stop and return nothing
    if (length(c(lat,lon,tile,alt)) < 4 ){
      stop("Key table header elements are missing, Daymet format change?")
    }
  }

  if(skip_header){
    tile <- NA
    alt <- NA
    lat <- NA
    lon <- NA
  }
  
  # read in the real climate data
  data <- utils::read.table(
    file,
    sep = ',',
    skip = (table_cols - 1),
    header = TRUE
  )
  
  # output data in a tidy or nested list format
  if(simplify){
    
    # convert data from long to wide format and
    # combine header info and data into a tibble
    data <- tidyr::gather(
      data,
      "measurement",
      "value",
      3:ncol(data)
    )
    
    output <- tibble::tibble(
      site = site,
      tile = tile,
      latitude = lat,
      longitude = lon,
      altitude = alt,
      year = data$year,
      yday = data$yday,
      measurement = data$measurement,
      value = data$value)
    
  } else {
    
    # put all data in a list for a non-tidy output
    output <- list(
      'site' = site,
      'tile' = tile,
      'latitude' = lat,
      'longitude' = lon,
      'altitude' = alt,
      'tile' = tile,
      'data' = data
      )
    
    # set daymetr class
    class(output) <- "daymetr"
  }
  
  # return the data
  return(output)
}
