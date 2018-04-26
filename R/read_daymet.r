#' Read Single Pixel Daymet data
#' 
#' Reads Single Pixel Daymet data into a nested list, preserving
#' header data and critical file name information.
#' 
#' @param file a Daymet Single Pixel data file
#' @param site a sitename (default = \code{NULL})
#' @return A nested data structure including site meta-data, the full
#' header and the data as a `data.frame()`.
#' @keywords time series, Daymet
#' @export
#' @examples
#'
#' \dontrun{
#' # with defaults, outputting a data frame
#' # with smoothed values, overwriting the original
#'
#' # download the data
#' download_daymet(site = "Daymet",
#'                  start = 1980,
#'                  end = 1980,
#'                  internal = FALSE,
#'                  silent = TRUE)
#'
#' # read in the Daymet file
#' df = read_daymet(paste0(tempdir(),"/Daymet_1980_1980.csv"))
#'
#' # print data structure
#' print(str(df))
#' }

read_daymet <- function(file = NULL,
                        site = NULL){
  
  # stop on missing files
  if (is.null(file) ){
    stop('File not provided...')
  }
  
  # check if the file exists and is a daily file
  if (!file.exists(file) ){
    stop('File does not exist...')
  }
  
  # read and format header, read past the header (should the length)
  # change in the future with a few lines this then does not break
  # the script
  header = try(readLines(file, n = 30), silent = TRUE)
  header_break = grep("^$", header)
  header = tolower(header[1:header_break])
  
  # read ancillary data from downloaded file header
  # this includes, tile nr and altitude
  tile = as.numeric(strsplit(header[grep("tile", header)], ":")[[1]][2])
  alt = as.numeric(gsub("meters",
                        "",
                        strsplit(header[grep("elevation", header)],
                                 ":")[[1]][2]))
  
  # geographic location
  lat = strsplit(header[grep("latitude", header)]," ")[[1]][2]
  lon = strsplit(header[grep("latitude", header)]," ")[[1]][4]
  
  # read in the real climate data
  data = utils::read.table(file,
                           sep = ',',
                           skip = header_break,
                           header = TRUE)
  
  # put all data in a list
  output = list('site' = site,
                'latitude' = lat,
                'longitude' = lon,
                'altitude' = alt,
                'tile' = tile,
                'data' = data)
  
  # set proper daymetr class
  class(output) = "daymetr"
  
  # return the nested list
  return(output)
}