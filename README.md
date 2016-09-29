[![Build Status](https://travis-ci.org/khufkens/daymetr.svg?branch=master)](https://travis-ci.org/khufkens/daymetr)

# DaymetR

The DaymetR R package provides functions to (batch) download single pixel or gridded [Daymet data](http://daymet.ornl.gov/) (tiled) data directly into your R workspace, or save them as csv/tif files on your computer. Gridded (tiled) data downloads for a region of interest are specified by a top left / bottom right coordinate pair or a single pixel location.

## Installation

clone the project to your home computer using the following command (with git installed)

```R
require(devtools)
install_github("khufkens/daymetr") # install the package
library(DaymetR) # load the package
```

## Use

### Single pixel location download

For a single site use the following format

```R
 download.daymet(site="Oak Ridge National Laboratories",lat=36.0133,lon=-84.2625,start_yr=1980,end_yr=2010,internal=TRUE)
```

Parameter     | Description                      
------------- | ------------------------------ 	
site	      | site name
lat           | latitude of the site
lon           | longitude of the site
start_yr      | start year of the time series (data start in 1980)
end_yr        | end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)
internal      | logical, TRUE or FALSE, if true data is imported into R workspace otherwise it is downloaded into the current working directory

Batch mode uses similar parameters but you provide a comma separated file with site names and latitude longitude which are sequentially downloaded. Format of the comma separated file is as such: site name, latitude, longitude.

```R
batch.download.daymet(file_location='my_sites.csv',start_yr=1980,end_yr=2010,internal=TRUE)
```

### Gridded data download

For gridded data use the following format

```R
download.daymet.tiles(lat1=36.0133,lon1=-84.2625,lat2=NA,lon2=NA,start_yr=1980,end_yr=2012,param="ALL")
```

Parameter     | Description                      
------------- | ------------------------------ 	
lat1	      | top left latitude
lon1          | top left longitude
lat2          | bottom right latitude (can be empty)
lon2	      | bottom right latitude (can be empty)
start_yr      | start year of the time series (data start in 1980)
end_yr        | end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)
param         | climate variable you want to download vapour pressure (vp), minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), solar radiation (srad), precipitation (prcp) , day length (dayl). The default setting is ALL, this will download all the previously mentioned climate variables.

If only the first set of coordinates is provided the tile in which these reside is downloaded. If your region of interest falls outside the scope of the DAYMET data coverage a warning is issued. If both top left and bottom right coordinates are provided all tiles covering the region of interst are downloaded. I would caution against downloading too much data, as file sizes do add up. So be careful how you specify your region of interest.

### Dependencies

The code depends on the following R packages: sp, rgdal, downloader and should be installed alongside the DaymetR package.
