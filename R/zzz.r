# server end points
server <- function(){
  "https://daymet.ornl.gov/single-pixel/api/data"
}

tile_server <- function(){
  #"https://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/1840/tiles"
  "https://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/2129/tiles"
}

ncss_server <- function(frequency, catalog = FALSE){
  url <- "https://thredds.daac.ornl.gov/thredds/ncss/ornldaac"
  
  if(catalog){
    return(file.path(url, "/2129/catalog.html")) #))"/1840/catalog.html"))
  }
  
  # set final url path depending on the frequency of the
  # data requested
  if(frequency == "monthly"){
    url <- sprintf("%s/%s", url, 2131) #1855)
  } else if (frequency == "annual"){
    url <- sprintf("%s/%s", url, 2130) #1852)
  } else {
    url <- sprintf("%s/%s", url, 2129) #1840)
  }
}