# server end points
server <- function(){
  "https://daymet.ornl.gov/single-pixel/api/data"
}

tile_server <- function(){
  "https://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/1328/tiles"
}

ncss_server <- function(frequency, catalog = FALSE){
  url <- "https://thredds.daac.ornl.gov/thredds/ncss/ornldaac/"
  
  if(catalog){
    return(file.path(url, "/1328/catalog.html"))
  }
  
  # set final url path depending on the frequency of the
  # data requested
  if(frequency == "monthly"){
    url <- sprintf("%s/%s", url, 1345)
  } else if (frequency == "annual"){
    url <- sprintf("%s/%s", url, 1343)
  } else {
    url <- sprintf("%s/%s", url, 1328)
  }
}

# check if server is reachable
# returns bolean TRUE if so
daymet_running <- function(url){
  ct <- httr::GET(url)
  if(ct$status_code > 400){
    FALSE  
  } else {
    TRUE
  }
}
