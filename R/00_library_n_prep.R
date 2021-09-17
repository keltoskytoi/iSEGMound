#Packages in the library
library<-c("gdalUtils", "link2GI", "glcm","raster","rgdal", "mapview", "sp",
           "spData", "sf", "tools", "RStoolbox", "rgeos", "lattice", "ggplot2",
           "DiagrammeR", "RColorBrewer", "signal", "rootSolve", "doParallel",
           "data.table", "ggridges", "plyr", "tidyverse", "hrbrthemes", "viridis",
           "dplyr", "ggridges", "plotly", "GGally", "rlas",  "lidR",
           "future", "ForestTools", "rrtools", "citr", "xaringan",
           "lidRviewer", "spdplyr", "osmextract", "spatialEco", "RSAGA", "listviewer",
           "rgrass7", "whitebox", "stars", "maptools", "latticeExtra", "spdep",
           "bookdown", "kableExtra", "formatR")

#Install CRAN packages if needed
inst <- library %in% installed.packages()
if(length(library[!inst]) > 0) install.packages(library[!inst])

#Load library packages into session if required
lapply(library, require, character.only=TRUE)

#+++checking GDAL installation on your computer#
gdalUtils::gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && require(rgdal) && valid_install)
getGDALVersionInfo()

#set up GRASS in your project
#link2GI::linkGRASS7(ver_select =TRUE)

#set up SAGA in your project
saga<-linkSAGA(ver_select = TRUE)
#set up the SAGA environment
env<-RSAGA::rsaga.env(path = saga$sagaPath)




