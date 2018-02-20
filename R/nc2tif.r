#' Converts .nc files in a given directory to .tif,
#' and preserves the naming conventions of the files that
#' are converted.
#' 
#' Conversion to .tif may simplify workflows if the data
#' that has been downloaded is to be handled in other
#' software (e.g. QGIS).
#' 
#' @param path a character string showing the path to the 
#' directory containing Daymet .nc files. 
#' @param file a character string containing the name if one
#' or more .nc files to be written to .tif.
#' @param overwrite a logical controlling whether all 
#' files will be written, or whether files for which a 
#' .tif version exists will be skipped. Note that this works
#' based on file name and not contents.


nc2tif <- function(path = ".",file = FALSE, overwrite = FALSE){

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