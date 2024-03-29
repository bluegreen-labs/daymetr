% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nc2tif.r
\name{nc2tif}
\alias{nc2tif}
\title{Converts netCDF (nc) files to geotiff}
\usage{
nc2tif(path = tempdir(), files = NULL, overwrite = FALSE, silent = FALSE)
}
\arguments{
\item{path}{a character string showing the path to the 
directory containing Daymet .nc files (default = tempdir())}

\item{files}{a character vector containing the name
of one or more files to be converted (optional)}

\item{overwrite}{a logical controlling whether all 
files will be written, or whether files will not be 
written in the event that there is already a .tif of 
that file. (default = NULL)}

\item{silent}{limit verbose output (default = FALSE)}
}
\value{
Converted geotiff files of all netCDF data in the provided
directory (path).
}
\description{
Conversion to .tif to simplify workflows if the data
that has been downloaded is to be handled in other
software (e.g. QGIS).
}
\examples{

\dontrun{

 # The below command converts all netCDF data in
 # the provided path to geotiff files. Existing
 # files will be overwritten. If set to FALSE,
 # files will not be overwritten.
 
 # download the data
 download_daymet_ncss(param = "tmin",
                      frequency = "annual",
                      path = tempdir(),
                      silent = TRUE)
 
 # convert files from nc to tif
 nc2tif(path = tempdir(),
 overwrite = TRUE)
 
 # print converted files
 print(list.files(tempdir(), "*.tif"))
 
}
}
