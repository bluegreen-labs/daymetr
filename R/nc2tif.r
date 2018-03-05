#' Converts .nc files in a given directory to .tif.
#' 
#' Conversion to .tif may simplify workflows if the data
#' that has been downloaded is to be handled in other
#' software (e.g. QGIS).
#' 
#' @param path a character string showing the path to the 
#' directory containing Daymet .nc files (default = tempdir())
#' @param files a character vector containing the name
#' of one or more files to be converted (optional)
#' @param overwrite a logical controlling whether all 
#' files will be written, or whether files will not be 
#' written in the event that there is already a .tif of 
#' that file. (default = NULL)
#' @param silent limit verbose output (default = FALSE)
#' @return Converted geotiff files of all netCDF data in the provided
#' directory (path).
#' @keywords Daymet, climate data, gridded data, netCDF, conversion
#' @export
#' @examples
#'
#' \dontrun{
#' 
#'  # The below command converts all netCDF data in
#'  # the provided path to geotiff files. Existing
#'  # files will be overwritten. If set to FALSE,
#'  # files will not be overwritten.
#'  
#'  # download the data
#'  download_daymet_ncss(param = "tmin",
#'                       frequency = "annual",
#'                       path = tempdir(),
#'                       silent = TRUE))
#'  
#'  # convert files from nc to tif
#'  nc2tif(path = tempdir(),
#'  overwrite = TRUE)
#'  
#'  # print converted files
#'  print(list.files(tempdir(), "*.tif"))
#'  
#'}

nc2tif <- function(path = tempdir(),
                   files = NULL,
                   overwrite = FALSE,
                   silent = FALSE){

  # CRAN file policy
  if (identical(path, tempdir())){
    message("Using default path tempdir() ...")
  }
  
  # providing initial feedback
  cat("nc2tif is working. Be patient, this may take a while...\n")
  
  # if no file is provide read data
  # from provided path
  if(is.null(files)){
    # make a vector of all .nc files in the directory
    files <- list.files(path=path,
                        pattern="\\.nc$",
                        full.names=TRUE)
  }
  
  # removing written files from write list if overwrite=FALSE
  if(!overwrite){
    
    # list all tif files
    tifs <- list.files(path=path,
                       pattern="\\.tif$",
                       full.names=TRUE)
    
    # remove all previously processed tif files
    files <- files[!tools::file_path_sans_ext(files) 
                   %in% tools::file_path_sans_ext(tifs)]
    
    if (!silent){
      # list how many files were skipped
      cat("\nSkipping",length(tifs),"existing files.")
    }
  }
  
  # create progress tracker to 
  # provide feedback during writing
  k <- 0
  
  # begin looping through files
  for(i in files){
    
    # modify progress count
    k <- k + 1
    
    if (!silent){
      # provide feedback
      cat("\nWriting",tools::file_path_sans_ext(i),
          "\nfile",k,"of",length(files),"\n")
    }
  
    if(!any(grep(pattern="annttl|annavg",i))){
      # if i is daily or monthly data use raster::brick
      data <- suppressWarnings(raster::brick(i))
        
    }else{
      # if i is annual summary data use raster::raster
      data <- suppressWarnings(raster::raster(i))
    }

    # write the file
    raster::writeRaster(data,
                        filename=tools::file_path_sans_ext(i),
                        format="GTiff",
                        overwrite=TRUE,
                        progress="text")
  }
}
