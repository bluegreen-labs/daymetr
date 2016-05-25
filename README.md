# DaymetR

Functions are provided to (batch) download single pixel or gridded [Daymet data](http://daymet.ornl.gov/) directly into your R workspace, or save them as csv/tif files on your computer. Both a batch version as a single download version are provided. Gridded data downloads for a region of interest are specified by a top left / bottom right coordinate pair or a single pixel location.

## Installation

clone the project to your home computer using the following command (with git installed)

```R
require(devtools)
install_github("khufkens/daymetr") # install the package
require(DaymetR) # load the package
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
lat2          | bottom right latitude
lon2	      | bottom right latitude
start_yr      | start year of the time series (data start in 1980)
end_yr        | end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)
param         | climate variable you want to download vapour pressure (vp), minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), solar radiation (srad), precipitation (prcp) , day length (dayl). The default setting is ALL, this will download all the previously mentioned climate variables.

If only the first set of coordinates is provided the tile in which these reside is downloaded. If your region of interest falls outside the scope of the DAYMET data coverage a warning is issued. If both top left and bottom right coordinates are provided all tiles covering the region of interst are downloaded.

## Notes

Furthermore, the below code (bash script) allows you to convert the ancillary DAYMET data to a latitude / longitude format for further and easy processing. Although this is not an integral part of the DaymetR package is might prove useful in subsequent analysis. The R equivalent of this code will be up shortly.

```bash
#!/bin/bash

# get filename with no extension
no_extension=`basename $1 | cut -d'.' -f1`

# convert the netCDF file to an ascii file
gdal_translate -of AAIGrid $1 original.asc

# extract the data with no header
tail -n +7 original.asc > ascii_data.asc

# paste everything together again with a correct header
echo "ncols        8011" 	>  final_ascii_data.asc
echo "nrows        8220"	>> final_ascii_data.asc
echo "xllcorner    -4659000.0" 	>> final_ascii_data.asc
echo "yllcorner    -3135000.0" 	>> final_ascii_data.asc
echo "cellsize     1000" 	>> final_ascii_data.asc
echo "NODATA_value 0"    	>> final_ascii_data.asc

# append flipped data
tac ascii_data.asc >> final_ascii_data.asc

# translate the data into Lambert Conformal Conic GTiff
gdal_translate -of GTiff -a_srs "+proj=lcc +datum=WGS84 +lat_1=25 n +lat_2=60n +lat_0=42.5n +lon_0=100w" final_ascii_data.asc tmp.tif

# convert to latitude / longitude
gdalwarp -of GTiff -overwrite -tr 0.009 0.009 -t_srs "EPSG:4326" tmp.tif tmp_lat_lon.tif

# crop to reduce file size / only cover the DAYMET tiles
gdal_translate -a_nodata -9999 -projwin -131.487784581 52.5568285568 -51.8801911189 13.9151864748 tmp_lat_lon.tif $no_extension.tif

# clean up
rm original.asc
rm ascii_data.asc
rm final_ascii_data.asc
rm tmp.tif
rm tmp_lat_lon.tif
```

### Dependencies

The code depends on the following R packages: sp, rgeos, rgdal, downloader
