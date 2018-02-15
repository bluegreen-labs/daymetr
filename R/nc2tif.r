#' Converts all .nc files in a given directory to .tif
#' and preserves the naming conventions of the files that
#' are converted.
#' 
#' Conversion to .tif may simplify workflows if the data
#' that has been downloaded is to be handled in other
#' software (e.g. QGIS).
#' 
#' @param path a character string showing the path to the 
#' directory containing Daymet .nc files
#' @param overwrite a logical controlling whether all 
#' files will be written, or whether files will not be 
#' written in the event that there is already a .tif of 
#' that file.


nc2tif <- function(path = ".",
                   overwrite = FALSE){
  
  #list all .nc files in a directory
  files <- list.files(path=path,
                      pattern="\\.nc$")
  
  # loop through files
  lapply(files, function(i){
    data <- raster::brick(i)
    
    cat("Writing",
        tools::file_path_sans_ext(i),
        "file. Be patient, this may take a while.")
    
    raster::writeRaster(data,
                        filename=tools::file_path_sans_ext(i),
                        format="GTiff",
                        overwrite=overwrite,
                        progress="text")
  })
}