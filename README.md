# NOTE: ORNL moved to a a https only protocol, please update your package by un-installing the old package and re-installing the new version.

# DaymetR

Functions are provided to (batch) download single pixel or gridded [Daymet data](http://daymet.ornl.gov/) directly into your R workspace, or save them as csv/tif files on your computer. Both a batch version as a single download version are provided. Gridded data downloads for a region of interest are specified by a top left / bottom right coordinate pair or a single pixel location.

## Installation

clone the project to your home computer using the following command (with git installed)

	git clone https://khufkens@bitbucket.org/khufkens/daymetr.git

alternatively, download the project using [this link](https://bitbucket.org/khufkens/daymetr/get/master.zip).

Next, unzip the file (if necessary) and install the DaymetR.tar.gz as a package in R.
	
## Use

### Single pixel location download

For a single site use the following format

 	download.daymet(site="Oak Ridge National Laboratories",lat=36.0133,lon=-84.2625,start_yr=1980,end_yr=2010,internal=TRUE)
  
Parameter     | Description                      
------------- | ------------------------------ 	
site	      | site name
lat           | latitude of the site
lon           | longitude of the site
start_yr      | start year of the time series (data start in 1980)
end_yr        | end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)
internal      | logical, TRUE or FALSE, if true data is imported into R workspace otherwise it is downloaded into the current working directory

Batch mode uses similar parameters but you provide a comma separated file with site names and latitude longitude which are sequentially downloaded. Format of the comma separated file is as such: site name, latitude, longitude.

	batch.download.daymet(file_location='my_sites.csv',start_yr=1980,end_yr=2010,internal=TRUE)


### Gridded data download

For gridded data use the following format

	download.daymet.tiles(lat1=36.0133,lon1=-84.2625,lat2=NA,lon2=NA,start_yr=1980,end_yr=2012,param="ALL")

Parameter     | Description                      
------------- | ------------------------------ 	
lat1	      | top left latitude
lon1          | top left longitude
lat2          | bottom right latitude
lon2	      | bottom right latitude
start_yr      | start year of the time series (data start in 1980)
end_yr        | end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)
param         | climate variable you want to download vapour pressure (vp), minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), solar radiation (srad), precipitation (prcp) , day length (dayl). The default setting is ALL, this will download all the previously mentioned climate variables.

If only the first set of coordinates is provided the tile in which these reside is downloaded. If your region of interest falls outside the scope of the DAYMET data coverage a warning is issued. If both top left and bottom right coordinates are provided all tiles covering the region of interst are downloaded.

## Notes

Furthermore, georeference_daymet_ancillary_data.sh can also be found in the source directory. This code allows you to convert the ancillary DAYMET data to a latitude / longitude format for further and easy processing. Although this is not an integral part of the DaymetR package is might prove useful in subsequent analysis. The R equivalent of this code will be up shortly.

### Dependencies

The code depends on the following R packages: sp, rgeos, rgdal, downloader