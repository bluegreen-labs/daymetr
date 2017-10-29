
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/khufkens/daymetr.svg?branch=master)](https://travis-ci.org/khufkens/daymetr) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.437886.svg)](https://doi.org/10.5281/zenodo.437886)

daymetr
=======

A programmatic interface to the [Daymet web services](http://daymet.ornl.gov). Allows for easy downloads of Daymet climate data directly to your R workspace or your computer. Routines for both single pixel data downloads and gridded (netCDF) data are provided.

Installation
------------

To install the toolbox in R run the following commands in a R terminal

``` r
if(!require(devtools)){install.package(devtools)}
devtools::install_github("khufkens/daymetr")
library(daymetr)
```

Use
---

### Single pixel location download

For a single site use the following format

``` r
download_daymet(site = "Oak Ridge National Laboratories",
                lat = 36.0133,
                lon = -84.2625,
                start = 1980,
                end = 2010,
                internal = TRUE)
```

<table style="width:62%;">
<colgroup>
<col width="19%" />
<col width="43%" />
</colgroup>
<thead>
<tr class="header">
<th>Parameter</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>site</td>
<td>site name</td>
</tr>
<tr class="even">
<td>lat</td>
<td>latitude of the site</td>
</tr>
<tr class="odd">
<td>lon</td>
<td>longitude of the site</td>
</tr>
<tr class="even">
<td>start</td>
<td>start year of the time series (data start in 1980)</td>
</tr>
<tr class="odd">
<td>end</td>
<td>end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)</td>
</tr>
<tr class="even">
<td>internal</td>
<td>logical, TRUE or FALSE, if true data is imported into R workspace otherwise it is downloaded into the current working directory</td>
</tr>
</tbody>
</table>

Batch mode uses similar parameters but you provide a comma separated file with site names and latitude longitude which are sequentially downloaded. Format of the comma separated file is as such: site name, latitude, longitude.

``` r
download_daymet_batch(file_location = 'my_sites.csv',
                      start = 1980,
                      end = 2010,
                      internal = TRUE)
```

### Gridded data downloads

For gridded data use either download\_daymet\_tiles() for individual tiles or download\_daymet\_ncss() for a netCDF subset which is not bound by tile limits (but restricted to a 6GB query size).

#### *Tiled data*

``` r
download_daymet_tiles(location = c(36.0133,-84.2625),
                      tiles = NULL,
                      start = 1980,
                      end = 2012,
                      param = "ALL")
```

<table style="width:62%;">
<colgroup>
<col width="19%" />
<col width="43%" />
</colgroup>
<thead>
<tr class="header">
<th>Parameter</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>location</td>
<td>vector with a point location c(lat,lon) or top left / bottom right pair c(lat,lon,lat,lon)</td>
</tr>
<tr class="even">
<td>tiles</td>
<td>vector with tile numbers if location point or top left / bottom right pair is not provided</td>
</tr>
<tr class="odd">
<td>start</td>
<td>start year of the time series (data start in 1980)</td>
</tr>
<tr class="even">
<td>end</td>
<td>end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)</td>
</tr>
<tr class="odd">
<td>param</td>
<td>climate variable you want to download vapour pressure (vp), minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), solar radiation (srad), precipitation (prcp) , day length (dayl). The default setting is ALL, this will download all the previously mentioned climate variables.</td>
</tr>
</tbody>
</table>

If only the first set of coordinates is provided the tile in which these reside is downloaded. If your region of interest falls outside the scope of the DAYMET data coverage a warning is issued. If both top left and bottom right coordinates are provided all tiles covering the region of interst are downloaded. I would caution against downloading too much data, as file sizes do add up. So be careful how you specify your region of interest.

#### *netCDF subset (ncss) data*

``` r
download_daymet_ncss(location = c(36.61,-85.37,-81.29,33.57),
                     start = 1980,
                     end = 1980,
                     param = "tmin")
```

<table style="width:62%;">
<colgroup>
<col width="19%" />
<col width="43%" />
</colgroup>
<thead>
<tr class="header">
<th>Parameter</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>location</td>
<td>bounding box extent defined as top left / bottom right pair c(lat,lon,lat,lon)</td>
</tr>
<tr class="even">
<td>start</td>
<td>start year of the time series (data start in 1980)</td>
</tr>
<tr class="odd">
<td>end</td>
<td>end year of the time series (current year - 2 years / for safety, tweak this check to reflect the currently available data)</td>
</tr>
<tr class="even">
<td>param</td>
<td>climate variable you want to download vapour pressure (vp), minimum and maximum temperature (tmin,tmax), snow water equivalent (swe), solar radiation (srad), precipitation (prcp) , day length (dayl). The default setting is ALL, this will download all the previously mentioned climate variables.</td>
</tr>
</tbody>
</table>

Keep in mind that the bounding box is defined by the minimum (square) bounding box in a Lambert Conformal Conic (LCC) projection as defined by the provided geographic coordinates. In general the query area will be larger than the requested location. For more information I refer to [Daymet documentation](https://daymet.ornl.gov/web_services.html) on the web service.

Reference
---------

Hufkens K., Basler J. D., Milliman T. Melaas E., Richardson A.D. 2017 An integrated phenology modelling framework in R: Phenology modelling with phenor. Methods in Ecology & Evolution (in review).

Acknowledgements
----------------

This project was is supported by the National Science Foundation’s Macro-system Biology Program (award EF-1065029).
