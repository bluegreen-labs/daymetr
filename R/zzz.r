# CRAN Note avoidance, basically
# assigns / binds variable names
# before they pop up in functions
# avoiding Notes which make packages
# not eligible for CRAN

.onLoad <- function(libname = find.package("daymetr"), pkgname = "daymetr"){
  if(getRversion() >= "2.15.1") 
    utils::globalVariables(
      # tile locations
      c("tile_outlines")
    )
  invisible()
}