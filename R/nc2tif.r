#' Converts .nc files in a given directory to .tif.
#' 
#' Conversion to .tif may simplify workflows if the data
#' that has been downloaded is to be handled in other
#' software (e.g. QGIS).
#' 
#' @param path a character string showing the path to the 
#' directory containing Daymet .nc files
#' @param file a character vector containing the name
#' of one or more files to be converted (optional)
#' @param overwrite a logical controlling whether all 
#' files will be written, or whether files will not be 
#' written in the event that there is already a .tif of 
#' that file. (default = NULL)
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
#'  nc2tif(path = "path_with_daymet_netcdf_files",
#'  overwrite = TRUE)
#'  
#'}

nc2tif <- function(path = ".",
                    file = NULL,
                    overwrite = FALSE){

  #providing initial feedback
  cat("nc2tif is working. Be patient, this may take a while...\n")
  
  if(is.null(file)){
    #make a vector of all .nc files in the directory
    files <- list.files(path=path,
                        pattern="\\.nc$",
                        full.names=TRUE)
  }else{
    #make a vector of specified files
    files <- file
  }
  
  #removing written files from write list if overwrite=FALSE
  if(!overwrite){
    tifs <- list.files(path=path, pattern="\\.tif$")
    files <- files[!tools::file_path_sans_ext(files) 
                   %in% tools::file_path_sans_ext(tifs)]
    cat("\nSkipping",length(tifs),"existing files.")
  }else{
    files <- files
  }
  
  #load ncdf for raster functions
  loadNamespace('ncdf4')
  
  #create progress tracker to provide feedback during writing
  k <- 0
  
  #begin looping through files
  for(i in files){
    
    #modify progress count
    k <- k+1
    
    #provide feedback
    cat("\nWriting",tools::file_path_sans_ext(i),
        "\nfile",k,"of",length(files),"\n")
    
    if(!any(grep(pattern="annttl|annavg",i))){
      #if i is daily or monthly data use raster::brick
      data <- suppressWarnings(raster::brick(i))
        
    }else{
      #if i is annual summary data use raster::raster
      data <- suppressWarnings(raster::raster(i))
    }

    #write the file
    raster::writeRaster(data,
                        filename=tools::file_path_sans_ext(i),
                        format="GTiff",
                        overwrite=TRUE,
                        progress="text")
  }
}
