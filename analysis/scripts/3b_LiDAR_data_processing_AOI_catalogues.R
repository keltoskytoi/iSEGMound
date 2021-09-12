################################################################################
####-----------------------------#SHORTCUTS#--------------------------------####
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project.
lsLIDAR_AOI_1 <- list.files(("/home/keltoskytoi/reRCHrs_REPO/AOIs_LAZ/AOI_1"), pattern = glob2rx("*.laz"), full.names = TRUE)
lsLIDAR_AOI_2 <- list.files(("/home/keltoskytoi/reRCHrs_REPO/AOIs_LAZ/AOI_2"), pattern = glob2rx("*.laz"), full.names = TRUE)
lsLIDAR_AOI_3 <- list.files(("/home/keltoskytoi/reRCHrs_REPO/AOIs_LAZ/AOI_3"), pattern = glob2rx("*.laz"), full.names = TRUE)
lsLIDAR_AOI_4 <- list.files(("/home/keltoskytoi/reRCHrs_REPO/AOIs_LAZ/AOI_4"), pattern = glob2rx("*.laz"), full.names = TRUE)
lsLIDAR_AOI_5 <- list.files(("/home/keltoskytoi/reRCHrs_REPO/AOIs_LAZ/AOI_5"), pattern = glob2rx("*.laz"), full.names = TRUE)
lsLIDAR_train_area <- list.files(("/home/keltoskytoi/reRCHrs_REPO/AOIs_LAZ/train_area"), pattern = glob2rx("*.laz"), full.names = TRUE)
################################################################################
#The very first the idea was to process all data and create a DTM from all 180 (2009/10)
#tiles to be able to investigate it for burial mounds in QGIS. Soon
#that idea proved to be crazy because of the size of the files and also because
#even the Desktop computer used in the thesis (i7, 36 GB physical RAM & 40.5 GB
#virtual RAM) would have not been able to process it.
#Thus first all tiles were processed with 0.1 resolution and the AOIs were
#mosaiced together. The OoIs are beautifully visible. Sadly it occured, that even
#with processing one 0.1 m resolution DTM the processing time increased exponentially
#and the AOIs had to rescaled to 0.5 ms.
#Thus in a second round the tiles of the AOIs are processed here in separate catalogs,
#with 0.5 resolution.
#In this instance we chose not to work with functions, because we want to work on
#multiple AOIs.
#NOTE: if opt_output_files is not set, the raster is going to be stored in the memory
#and the file has to be written out. First run was without setting the path for the output,
#and the second run was by setting the output path.

#----------------------------#paralellize work#--------------------------------#
future::plan(multisession, workers = 2L)
#set the number of threads lidR should use
lidR::set_lidr_threads(4)

####---------------------------#LAZ CATALOG AOI 1#--------------------------####
AOI_1_catalog <- lidR::readLAScatalog(lsLIDAR_AOI_1, select = "xyzirnc", filter ="keep_class 2")
sp::proj4string(AOI_1_catalog) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
####------------------------#INSPECT LAZ CATALOG#---------------------------####
summary(AOI_1_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 480000, 482000, 5630000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area        : 7 km²
#points      : 102.35million points
#density     : 14.6 points/m²
#num. files  : 7
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#  - Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(AOI_1_catalog)
#⚠ Inconsistent offsets
#Checking normalization... no
#Checking point indexation... no

plot(AOI_1_catalog)
plot(AOI_1_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(AOI_1_catalog, "Min.Z")

####------------------#SET VARIABLES FOR THE LAZ CATALOG#-------------------####
#-----------------------------#set chunk size#---------------------------------#
#chunk size in which lidR should process: is in meters and the 1000x1000 m
#chunks are perfect, so we don't have to set this!
#-----------------------------#set chunk buffer#-------------------------------#
lidR::opt_chunk_buffer(AOI_1_catalog) <- 50# default: 30
plot(AOI_1_catalog, chunk= TRUE)
#---------------------------#set the output Path#------------------------------#
opt_output_files(AOI_1_catalog) <- paste0(path_analysis_results_AOI_1, "/{*}_xyzirnc_ground_05")
#---------------#enable to overwrite result when processed again#--------------#
AOI_1_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
#----------------------------#apply terrain gridding#--------------------------#
AOI_1 <- lidR::grid_terrain(AOI_1_catalog, res=0.5, algorithm = knnidw(k = 10L, p = 2, rmax = 50))

#write/export raster
raster::writeRaster(AOI_1, paste0(path_analysis_results_AOI_1, "AOI_1_xyzirnc_ground_05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####---------------------------#LAZ CATALOG AOI 2#--------------------------####
AOI_2_catalog <- lidR::readLAScatalog(lsLIDAR_AOI_2, select = "xyzirnc", filter ="keep_class 2")
sp::proj4string(AOI_2_catalog) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
####------------------------#INSPECT LAZ CATALOG#---------------------------####
summary(AOI_2_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 484000, 487000, 5630000, 5633000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area        : 7 km²
#points      : 89.9million points
#density     : 12.8 points/m²
#num. files  : 7
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#- Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(AOI_2_catalog)
#⚠ Inconsistent offsets
#Checking normalization... no
#Checking point indexation... no

plot(AOI_2_catalog)
plot(AOI_2_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(AOI_2_catalog, "Min.Z")

####------------------#SET VARIABLES FOR THE LAZ CATALOG#-------------------####
#-----------------------------#set chunk size#---------------------------------#
#chunk size in which lidR should process: is in meters and the 1000x1000 m
#chunks are perfect, so we don't have to set this!
#-----------------------------#set chunk buffer#-------------------------------#
lidR::opt_chunk_buffer(AOI_2_catalog) <- 50# default: 30
plot(AOI_2_catalog, chunk= TRUE)
#---------------------------#set the output Path#------------------------------#
opt_output_files(AOI_2_catalog) <- paste0(path_analysis_results_AOI_2, "/{*}_xyzirnc_ground_05")
#---------------#enable to overwrite result when processed again#--------------#
AOI_2_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
#----------------------------#apply terrain gridding#--------------------------#
AOI_2 <- lidR::grid_terrain(AOI_2_catalog, res=0.5, algorithm = knnidw(k = 10L, p = 2, rmax = 50))

#write/export raster
raster::writeRaster(AOI_2, paste0(path_analysis_results_AOI_2, "AOI_2_xyzirnc_ground_05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####---------------------------#LAZ CATALOG AOI 3#--------------------------####
AOI_3_catalog <- lidR::readLAScatalog(lsLIDAR_AOI_3, select = "xyzirnc", filter ="keep_class 2")
sp::proj4string(AOI_3_catalog) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
####------------------------#INSPECT LAZ CATALOG#---------------------------####
summary(AOI_3_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 484000, 488000, 5623000, 5629000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area        : 13 km²
#points      : 149.6million points
#density     : 11.5 points/m²
#num. files  : 13
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
# - Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(AOI_3_catalog)
#⚠ Inconsistent offsets
#Checking normalization... no
#Checking point indexation... no

plot(AOI_3_catalog)
plot(AOI_3_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(AOI_3_catalog, "Min.Z")

####------------------#SET VARIABLES FOR THE LAZ CATALOG#-------------------####
#-----------------------------#set chunk size#---------------------------------#
#chunk size in which lidR should process: is in meters and the 1000x1000 m
#chunks are perfect, so we don't have to set this!
#-----------------------------#set chunk buffer#-------------------------------#
lidR::opt_chunk_buffer(AOI_3_catalog) <- 50# default: 30
plot(AOI_3_catalog, chunk= TRUE)
#---------------------------#set the output Path#------------------------------#
opt_output_files(AOI_3_catalog) <- paste0(path_analysis_results_AOI_3, "/{*}_xyzirnc_ground_05")
#---------------#enable to overwrite result when processed again#--------------#
AOI_3_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
#----------------------------#apply terrain gridding#--------------------------#
AOI_3 <- lidR::grid_terrain(AOI_3_catalog, res=0.5, algorithm = knnidw(k = 10L, p = 2, rmax = 50))

#write/export raster
raster::writeRaster(AOI_3, paste0(path_analysis_results_AOI_3, "AOI_3_xyzirnc_ground_05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####---------------------------#LAZ CATALOG AOI 4#--------------------------####
AOI_4_catalog <- lidR::readLAScatalog(lsLIDAR_AOI_4, select = "xyzirnc", filter ="keep_class 2")
sp::proj4string(AOI_4_catalog) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
####------------------------#INSPECT LAZ CATALOG#---------------------------####
summary(AOI_4_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 480000, 486000, 5616000, 5622000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area        : 18 km²
#points      : 229.37million points
#density     : 12.7 points/m²
#num. files  : 18
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#- Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(AOI_4_catalog)
#⚠ Inconsistent scale factors
#⚠ Inconsistent offsets
#Checking normalization... no
#Checking point indexation... no

plot(AOI_4_catalog)
plot(AOI_4_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(AOI_4_catalog, "Min.Z")

####------------------#SET VARIABLES FOR THE LAZ CATALOG#-------------------####
#-----------------------------#set chunk size#---------------------------------#
#chunk size in which lidR should process: is in meters and the 1000x1000 m
#chunks are perfect, so we don't have to set this!
#-----------------------------#set chunk buffer#-------------------------------#
lidR::opt_chunk_buffer(AOI_4_catalog) <- 50# default: 30
plot(AOI_4_catalog, chunk= TRUE)
#---------------------------#set the output Path#------------------------------#
opt_output_files(AOI_4_catalog) <- paste0(path_analysis_results_AOI_4, "/{*}_xyzirnc_ground_05")
#---------------#enable to overwrite result when processed again#--------------#
AOI_4_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
#----------------------------#apply terrain gridding#--------------------------#
AOI_4 <- lidR::grid_terrain(AOI_4_catalog, res=0.5, algorithm = knnidw(k = 10L, p = 2, rmax = 50))

#write/export raster
raster::writeRaster(AOI_4, paste0(path_analysis_results_AOI_4, "AOI_4_xyzirnc_ground_05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####---------------------------#LAZ CATALOG AOI 5#--------------------------####
AOI_5_catalog <- lidR::readLAScatalog(lsLIDAR_AOI_5, select = "xyzirnc", filter ="keep_class 2")
sp::proj4string(AOI_5_catalog) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
####------------------------#INSPECT LAZ CATALOG#---------------------------####
summary(AOI_5_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 478000, 482000, 5624000, 5625000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area        : 4 km²
#points      : 57.99million points
#density     : 14.5 points/m²
#num. files  : 4
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#- Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(AOI_5_catalog)
#⚠ Inconsistent offsets
#Checking normalization... no
#Checking point indexation... no

plot(AOI_5_catalog)
plot(AOI_5_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(AOI_5_catalog, "Min.Z")

####------------------#SET VARIABLES FOR THE LAZ CATALOG#-------------------####
#-----------------------------#set chunk size#---------------------------------#
#chunk size in which lidR should process: is in meters and the 1000x1000 m
#chunks are perfect, so we don't have to set this!
#-----------------------------#set chunk buffer#-------------------------------#
lidR::opt_chunk_buffer(AOI_5_catalog) <- 50# default: 30
plot(AOI_5_catalog, chunk= TRUE)
#---------------------------#set the output Path#------------------------------#
opt_output_files(AOI_5_catalog) <- paste0(path_analysis_results_AOI_5, "/{*}_xyzirnc_ground_05")
#---------------#enable to overwrite result when processed again#--------------#
AOI_5_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
#----------------------------#apply terrain gridding#--------------------------#
AOI_5 <- lidR::grid_terrain(AOI_5_catalog, res=0.5, algorithm = knnidw(k = 10L, p = 2, rmax = 50))

#write/export raster
raster::writeRaster(AOI_5, paste0(path_analysis_results_AOI_5, "AOI_5_xyzirnc_ground_05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####---------------------------#LAZ CATALOG train area#--------------------------####
train_area_catalog <- lidR::readLAScatalog(lsLIDAR_train_area, select = "xyzirnc", filter ="keep_class 2")
sp::proj4string(train_area_catalog) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
####------------------------#INSPECT LAZ CATALOG#---------------------------####
summary(train_area_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 482000, 484000, 5616000, 5620000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area        : 5 km²
#points      : 62.09million points
#density     : 12.4 points/m²
#num. files  : 5
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#- Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(train_area_catalog)
#Checking normalization... no
#Checking point indexation... no

plot(train_area_catalog)
plot(train_area_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(train_area_catalog, "Min.Z")

####------------------#SET VARIABLES FOR THE LAZ CATALOG#-------------------####
#-----------------------------#set chunk size#---------------------------------#
#chunk size in which lidR should process: is in meters and the 1000x1000 m
#chunks are perfect, so we don't have to set this!
#-----------------------------#set chunk buffer#-------------------------------#
lidR::opt_chunk_buffer(train_area_catalog) <- 50# default: 30
plot(train_area_catalog, chunk= TRUE)
#---------------------------#set the output Path#------------------------------#
opt_output_files(train_area_catalog) <- paste0(path_analysis_results_train_area, "/{*}_xyzirnc_ground_05")
#---------------#enable to overwrite result when processed again#--------------#
train_area_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
#----------------------------#apply terrain gridding#--------------------------#
train_area <- lidR::grid_terrain(train_area_catalog, res=0.5, algorithm = knnidw(k = 10L, p = 2, rmax = 50))

#write/export raster
raster::writeRaster(train_area, paste0(path_analysis_results_train_area, "train_area_xyzirnc_ground_05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
