################################################################################
####-----------------------------#PREPARATIONS#-----------------------------####
#------------#clean R history, to get a clear working environment#-------------#
rm(list=ls())
####---------------#prepare system independent environment#-----------------####
#please change the path to the projects library according to where you want to
#place the R project library on you computer!

if(Sys.info()["sysname"] == "Windows"){
  projRootDir <- "C:/Users/kelto/Documents/iSEGMound/"
} else {
  projRootDir <- "/home/keltoskytoi/iSEGMound"
}

#+++ supplementing the folder structure of 'rrtools'
paths<-link2GI::initProj(projRootDir = projRootDir,
                         projFolders = c("analysis/data/literature_analysis/",
                                         "analysis/data/burial_mounds_Dobiat_1994/",
                                         "analysis/data/LiDAR_info/",
                                         "analysis/results/train_area/",
                                         "analysis/results/derivatives/",
                                         "analysis/results/AOI_1/",
                                         "analysis/results/AOI_2/",
                                         "analysis/results/AOI_3/",
                                         "analysis/results/AOI_4/",
                                         "analysis/results/AOI_5/",
                                         "analysis/results/5a_iSEG05_WS/",
                                         "analysis/results/5b_iSEG05_mtpi_WS/",
                                         "analysis/results/5c_iSEG05_RG/",
                                         "analysis/results/5d_iSEG05_mtpi_RG/",
                                         "analysis/results/6a_iSEG05_WS_ta/",
                                         "analysis/results/6b_iSEG05_mtpi_WS_ta/",
                                         "analysis/results/6c_iSEG05_RG_ta/",
                                         "analysis/results/6d_iSEG05_mtpi_RG_ta/",
                                         "analysis/results/7a_iSEG05_AOI_1/",
                                         "analysis/results/7b_iSEG05_AOI_2/",
                                         "analysis/results/7c_iSEG05_AOI_3/",
                                         "analysis/results/7d_iSEG05_AOI_4/",
                                         "analysis/results/7e_iSEG05_AOI_5/",
                                         "analysis/qgis/",
                                         "tests/compare_algorithms/TIN/",
                                         "tests/compare_algorithms/TIN/res_test/",
                                         "tests/compare_algorithms/IDW/",
                                         "tests/compare_algorithms/IDW/idw05/",
                                         "tests/compare_algorithms/IDW/idw05_2/",
                                         "tests/compare_algorithms/IDW/idw05_3/",
                                         "tests/compare_algorithms/IDW/idw05_4/",
                                         "tests/compare_algorithms/IDW/idw05_5/",
                                         "tests/", "R/", "man/", "analysis/scripts/",
                                         "analysis/thesis/",
                                         "analysis/thesis/references/",
                                         "analysis/thesis/figures/",
                                         "analysis/thesis/csl/",
                                         "analysis/thesis/depreciated/",
                                         ),
                         global = TRUE,
                         path_prefix = "path_")

#------------------------------#load library#----------------------------------#
#The source file enables you to install and activate packages in one run
source("C:/Users/kelto/Documents/iSEGMound/R/00_library_n_prep.R")
#----------------------------#source functions#--------------------------------#
#for plotting the cross section of LiDAR pointclouds:
source("C:/Users/kelto/Documents/iSEGMound/R/plot_crossection.R")
#for detecting mounds:
source("C:/Users/kelto/Documents/iSEGMound/R/generate_mtpi_SAGA.R")
source("C:/Users/kelto/Documents/iSEGMound/R/filtR.R")
source("C:/Users/kelto/Documents/iSEGMound/R/fill_sink_SAGA_WL.R")
source("C:/Users/kelto/Documents/iSEGMound/R/watershed_segmentation_SAGA.R")
source("C:/Users/kelto/Documents/iSEGMound/R/generate_seeds_SAGA.R")
source("C:/Users/kelto/Documents/iSEGMound/R/seeded_region_growing_SAGA.R")
source("C:/Users/kelto/Documents/iSEGMound/R/polygonize_segments_SAGA.R")
source("C:/Users/kelto/Documents/iSEGMound/R/compute_shape_index_SAGA.R")
source("C:/Users/kelto/Documents/iSEGMound/R/create_regions.R")
source("C:/Users/kelto/Documents/iSEGMound/R/IoU.R")
#------------------------#installing packages not on CRAN#---------------------#
#if it is not possible to install certain packages via 'install.packages()'
#please install them via github:

remotes::install_github("benmarwick/rrtools")
remotes::install_github("crsh/citr")
BiocManager::install("EBImage") # not available for R 4.0.5
remotes::install_github("weecology/NeonTreeEvaluation_package")

#to install lidRviewer, first install the following R file:
#it may be possible that you have to reopen R as administrator to be able to
#install it, if R is under C: on Windows
source("https://raw.githubusercontent.com/Jean-Romain/lidRviewer/master/sdl.R")
remotes::install_github("Jean-Romain/lidRviewer")

#to be able to install uavRst you will need to install the packages 'velox'
#and 'spatial.tools' from the CRAN archive from source
remotes::install_url('http://cran.r-project.org/src/contrib/Archive/spatial.tools/spatial.tools_1.6.2.tar.gz')
remotes::install_url('http://cran.r-project.org/src/contrib/Archive/velox/velox_0.2.0.tar.gz')
remotes::install_github("gisma/uavRst", ref = "master", dependencies = TRUE,
                         force = TRUE)

#to be able to install SegOptim you will have to install NLMR from github first
#devtools::install_github("ropensci/NLMR")
#remotes::install_github("joaofgoncalves/SegOptim")

remotes::install_github("giswqs/whiteboxR")

#to use the william Morris colorpalette:
remotes::install_github("cshoggard/morris")

#to add packages to the namespace & description:
rrtools::add_dependencies_to_description()

#NOTE: function are used in combination with the package of origin; if no package
#is signaled, the function is from base R.
