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
#' that file. (default = FALSE)
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
                   file = FALSE,
                   overwrite = FALSE){
  
  if(file == FALSE){
    #make a vector of all .nc files in the directory
    files <- list.files(path=path,
                        pattern="\\.nc$")
  }else{
    #make a vector of specified files
    files <- file
  }
  
  #load ncdf for raster functions
  loadNamespace('ncdf4')
  
  #make a vector of existing .tif files
  tifs <- list.files(path=path,
                     pattern="\\.tif$")
  tifs <- tools::file_path_sans_ext(tifs)
  
  #begin looping through files vector
  for(i in files){
    
    if (overwrite == FALSE){
      
      if(tools::file_path_sans_ext(i) %in% tifs == TRUE){
        #skip writing .nc files where there is an existing .tif file
        cat("Skipping ",tools::file_path_sans_ext(i),"\n",
            "File already exists\n")
        
      }else{
        #else write the tif file
        
        if(any(grep(pattern="annttl|annavg",i)) == FALSE){
          #if i is daily or monthly data use raster::brick
          data <- raster::brick(i)
          
        }else{
          #if i is annual summary data use raster::raster
          data <- raster::raster(i)
        }
        
        #provide feedback
        cat("Writing",
            tools::file_path_sans_ext(i),
            ".tif\nBe patient, this may take a while\n")
        
        #write the file
        raster::writeRaster(data,
                            filename=tools::file_path_sans_ext(i),
                            format="GTiff",
                            overwrite=TRUE,
                            progress="text")
      }
    }else{
      
      if(any(grep(pattern="annttl|annavg",i)) == FALSE){
        #if i is daily or monthly data use raster::brick
        data <- raster::brick(i)
        
      }else{
        #if i is annual summary data use raster::raster
        data <- raster::raster(i)
      }
      
      #provide feedback
      cat("Writing",
          tools::file_path_sans_ext(i),
          ".tif\nBe patient, this may take a while\n")
      
      #write the file
      raster::writeRaster(data,
                          filename=tools::file_path_sans_ext(i),
                          format="GTiff",
                          overwrite=TRUE,
                          progress="text")
    }
  }
}
