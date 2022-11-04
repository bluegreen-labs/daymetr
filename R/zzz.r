# server end points
server <- function(){
  "https://daymet.ornl.gov/single-pixel/api/data"
}

tile_server <- function(){
  "https://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/2129/tiles"
}

ncss_server <- function(frequency, catalog = FALSE){
  url <- "https://thredds.daac.ornl.gov/thredds/ncss/ornldaac"
  
  if(catalog){
    return(file.path(url, "2129/catalog.html"))
  }
  
  # set final url path depending on the frequency of the
  # data requested
  if(frequency == "monthly"){
    url <- file.path(url, 2131)
  } else if (frequency == "annual"){
    url <- file.path(url, 2130)
  } else {
    url <- file.path(url, 2129)
  }
}