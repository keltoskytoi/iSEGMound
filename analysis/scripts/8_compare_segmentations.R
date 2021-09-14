####-------------#1.READ MOUNDS DOBIAT 1994 IN THE TRAIN AREA#---------------####
burial_mounds_5 <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
burial_mounds_7 <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994.shp"))
burial_mounds_9 <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "9_Dobiat_1994.shp"))
burial_mounds_14 <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994.shp"))
burial_mounds_35 <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
burial_mounds_35_2 <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
####-------------------#2.READ SEGMENTATION RESULTS TO COMPARE#-------------####
iSEG_mtpi_WS_ta<-st_read(paste0(path_analysis_results_6b_iSEG05_mtpi_WS_ta, "iSEG_mtpi_WS_ta.shp"))
iSEG_mtpi_RG_ta <-st_read(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "iSEG_mtpi_RG_ta.shp"))
st_crs(iSEG_mtpi_RG_ta) <-  st_crs(iSEG_mtpi_WS_ta)
################################################################################
####----------#CALCULATE IoU FOR iSEG_mtpi_WS_ta MOUND SEGMENTS#------------####
mapview::mapview(iSEG_mtpi_WS_ta, col.regions = "goldenrod") +
mapview::mapview(all_train_mounds, col.regions = "blue")

#check in QGIS the new ID in the shapefile
mtpi_WS_ta_5_1 <- iSEG_mtpi_WS_ta[28,]
mtpi_WS_ta_5_2 <- iSEG_mtpi_WS_ta[27,]
mtpi_WS_ta_5_3 <- iSEG_mtpi_WS_ta[23,]
mtpi_WS_ta_5_4 <- iSEG_mtpi_WS_ta[24,]
mtpi_WS_ta_5_5 <- iSEG_mtpi_WS_ta[22,]
mtpi_WS_ta_5_6 <- iSEG_mtpi_WS_ta[25,]
mtpi_WS_ta_5_7 <- iSEG_mtpi_WS_ta[29,]
mtpi_WS_ta_5_8 <- iSEG_mtpi_WS_ta[31,]
mtpi_WS_ta_5_9 <- iSEG_mtpi_WS_ta[17,]
all_mtpi_WS_ta_5 <- rbind(mtpi_WS_ta_5_1, mtpi_WS_ta_5_2, mtpi_WS_ta_5_3, mtpi_WS_ta_5_4,
                         mtpi_WS_ta_5_5, mtpi_WS_ta_5_6, mtpi_WS_ta_5_7, mtpi_WS_ta_5_8,
                         mtpi_WS_ta_5_9)
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
mtpi_WS_ta_7_2 <- iSEG_mtpi_WS_ta[43,]
mtpi_WS_ta_7_3 <- iSEG_mtpi_WS_ta[44,]
mtpi_WS_ta_7_4 <- iSEG_mtpi_WS_ta[48,]
mtpi_WS_ta_7_5 <- iSEG_mtpi_WS_ta[54,]
mtpi_WS_ta_7_6 <- iSEG_mtpi_WS_ta[52,]
mtpi_WS_ta_7_7 <- iSEG_mtpi_WS_ta[57,]
mtpi_WS_ta_7_8 <- iSEG_mtpi_WS_ta[59,]
mtpi_WS_ta_7_9 <- iSEG_mtpi_WS_ta[60,]
all_mtpi_WS_ta_7 <- rbind(mtpi_WS_ta_7_2, mtpi_WS_ta_7_3, mtpi_WS_ta_7_4,
                          mtpi_WS_ta_7_5, mtpi_WS_ta_7_6, mtpi_WS_ta_7_7,
                          mtpi_WS_ta_7_8, mtpi_WS_ta_7_9)
#------------------------#Dobiat 1994, Grave group 14#-------------------------#
mtpi_WS_ta_14_2 <- iSEG_mtpi_WS_ta[128,]
mtpi_WS_ta_14_3 <- iSEG_mtpi_WS_ta[123,]
mtpi_WS_ta_14_4 <- iSEG_mtpi_WS_ta[136,]
mtpi_WS_ta_14_5 <- iSEG_mtpi_WS_ta[138,]
mtpi_WS_ta_14_7 <- iSEG_mtpi_WS_ta[143,]
mtpi_WS_ta_14_9 <- iSEG_mtpi_WS_ta[150,]
mtpi_WS_ta_14_10 <- iSEG_mtpi_WS_ta[154,]
mtpi_WS_ta_14_12 <- iSEG_mtpi_WS_ta[156,]
mtpi_WS_ta_14_13 <- iSEG_mtpi_WS_ta[158,]
mtpi_WS_ta_14_14 <- iSEG_mtpi_WS_ta[160,]
mtpi_WS_ta_14_15 <- iSEG_mtpi_WS_ta[163,]
mtpi_WS_ta_14_16 <- iSEG_mtpi_WS_ta[172,]
mtpi_WS_ta_14_17 <- iSEG_mtpi_WS_ta[174,]
mtpi_WS_ta_14_19 <- iSEG_mtpi_WS_ta[149,]
all_mtpi_WS_ta_14 <- rbind(mtpi_WS_ta_14_2, mtpi_WS_ta_14_3, mtpi_WS_ta_14_4,
                           mtpi_WS_ta_14_5,  mtpi_WS_ta_14_7, mtpi_WS_ta_14_9,
                           mtpi_WS_ta_14_10, mtpi_WS_ta_14_12, mtpi_WS_ta_14_13,
                           mtpi_WS_ta_14_14, mtpi_WS_ta_14_15, mtpi_WS_ta_14_16,
                           mtpi_WS_ta_14_17, mtpi_WS_ta_14_19)
#------------------------#Dobiat 1994, Grave group 35#-------------------------#
mtpi_WS_ta_35 <- iSEG_mtpi_WS_ta[35,]
mtpi_WS_ta_35_2 <-iSEG_mtpi_WS_ta[34,]
all_mtpi_WS_ta_35 <- rbind(mtpi_WS_ta_35, mtpi_WS_ta_35_2)
burial_mounds_35_12 <- rbind(burial_mounds_35, burial_mounds_35_2)
################################################################################
####----------#CALCULATE IoU FOR iSEG_mtpi_RG_ta MOUND SEGMENTS#------------####
mapview::mapview(iSEG_mtpi_RG_ta, col.regions = "goldenrod") +
mapview::mapview(all_train_mounds, col.regions = "blue")

#check in QGIS the new ID in the shapefile
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
mtpi_RG_ta_5_1 <- iSEG_mtpi_RG_ta[59,]
mtpi_RG_ta_5_2 <- iSEG_mtpi_RG_ta[58,]
mtpi_RG_ta_5_3 <- iSEG_mtpi_RG_ta[54,]
mtpi_RG_ta_5_4 <- iSEG_mtpi_RG_ta[55,]
mtpi_RG_ta_5_5 <- iSEG_mtpi_RG_ta[53,]
mtpi_RG_ta_5_6 <- iSEG_mtpi_RG_ta[56,]
mtpi_RG_ta_5_7 <- iSEG_mtpi_RG_ta[60,]
mtpi_RG_ta_5_8 <- iSEG_mtpi_RG_ta[61,]
mtpi_RG_ta_5_9 <- iSEG_mtpi_RG_ta[49,]
all_mtpi_RG_ta_5 <- rbind(mtpi_RG_ta_5_1, mtpi_RG_ta_5_2, mtpi_RG_ta_5_3, mtpi_RG_ta_5_4,
                          mtpi_RG_ta_5_5, mtpi_RG_ta_5_6, mtpi_RG_ta_5_7, mtpi_RG_ta_5_8,
                          mtpi_RG_ta_5_9)
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
mtpi_RG_ta_7_1 <- iSEG_mtpi_RG_ta[67,]
mtpi_RG_ta_7_2 <- iSEG_mtpi_RG_ta[66,]
mtpi_RG_ta_7_3 <- iSEG_mtpi_RG_ta[68,]
mtpi_RG_ta_7_5 <- iSEG_mtpi_RG_ta[70,]
mtpi_RG_ta_7_6 <- iSEG_mtpi_RG_ta[69,]
mtpi_RG_ta_7_8 <- iSEG_mtpi_RG_ta[71,]
all_mtpi_RG_ta_7 <- rbind(mtpi_RG_ta_7_1, mtpi_RG_ta_7_2, mtpi_RG_ta_7_3,
                          mtpi_RG_ta_7_5, mtpi_RG_ta_7_6, mtpi_RG_ta_7_8)
#------------------------#Dobiat 1994, Grave group 14#--------------------------#
mtpi_RG_ta_14_1 <- iSEG_mtpi_RG_ta[87,]
mtpi_RG_ta_14_2 <- iSEG_mtpi_RG_ta[92,]
mtpi_RG_ta_14_4 <- iSEG_mtpi_RG_ta[7,]
mtpi_RG_ta_14_5 <- iSEG_mtpi_RG_ta[8,]
mtpi_RG_ta_14_6 <- iSEG_mtpi_RG_ta[9,]
mtpi_RG_ta_14_7 <- iSEG_mtpi_RG_ta[12,]
mtpi_RG_ta_14_9 <- iSEG_mtpi_RG_ta[17,]
mtpi_RG_ta_14_10 <- iSEG_mtpi_RG_ta[18,]
mtpi_RG_ta_14_11 <- iSEG_mtpi_RG_ta[14,]
mtpi_RG_ta_14_12 <- iSEG_mtpi_RG_ta[19,]
mtpi_RG_ta_14_13 <- iSEG_mtpi_RG_ta[20,]
mtpi_RG_ta_14_15 <- iSEG_mtpi_RG_ta[21,]
mtpi_RG_ta_14_16 <- iSEG_mtpi_RG_ta[26,]
mtpi_RG_ta_14_17 <- iSEG_mtpi_RG_ta[27,]
mtpi_RG_ta_14_18 <- iSEG_mtpi_RG_ta[28,]
mtpi_RG_ta_14_19 <- iSEG_mtpi_RG_ta[16,]
all_mtpi_RG_ta_14 <- rbind(mtpi_RG_ta_14_1, mtpi_RG_ta_14_2, mtpi_RG_ta_14_4,
                           mtpi_RG_ta_14_5, mtpi_RG_ta_14_6, mtpi_RG_ta_14_7,
                           mtpi_RG_ta_14_9, mtpi_RG_ta_14_10, mtpi_RG_ta_14_11,
                           mtpi_RG_ta_14_12, mtpi_RG_ta_14_13, mtpi_RG_ta_14_15,
                           mtpi_RG_ta_14_16, mtpi_RG_ta_14_17, mtpi_RG_ta_14_18,
                           mtpi_RG_ta_14_19)
#------------------------#Dobiat 1994, Grave group 35#-------------------------#
mtpi_RG_ta_35 <- iSEG_mtpi_RG_ta[63,]
################################################################################
####----------------------#CALCULATING IoU#---------------------------------####

####-----------------------#iSEG_mtpi_WS_ta#--------------------------------####
#function from the NeonTreeEvaluation_package
IoU_mtpiWSta_ID_5 <- IoU(burial_mounds_5, all_mtpi_WS_ta_5)
#     1         2          3       4          5          6         7        8          9
# 0.7133065 0.6003428 0.7130259 0.5765421 0.5115062 0.5890535 0.6735597 0.5290715 0.4605544
vctrs::vec_group_id(burial_mounds_5) #1 2 3 4 5 6 7 8 9
vctrs::vec_group_id(all_mtpi_WS_ta_5) #1 2 3 4 5 6 7 8 9

#------------------------------------------------------------------------------#
IoU_mtpiWSta_ID_7 <- IoU(burial_mounds_7, all_mtpi_WS_ta_7)
#0.8227654 0.8046810 0.7477109 0.4350706 0.4245115 0.3908407 0.5410769 0.3754888 0.6950105
vctrs::vec_group_id(burial_mounds_7) #1 2 3 4 5 6 7 8 9
vctrs::vec_group_id(all_mtpi_WS_ta_7) #1 2 3 4 5 6 7 8
mapview::mapview(burial_mounds_7, col.regions = "blue") +
mapview::mapview(all_mtpi_WS_ta_7, col.regions = "goldenrod")

#------------------------------------------------------------------------------#
IoU_mtpiWSta_ID_14 <- IoU(burial_mounds_14, all_mtpi_WS_ta_14)
#0.5875941 0.3495416 1.0779428 0.1871868 0.4915055 1.0208148 1.1999337 0.2314343
#0.3267251 0.2510112 0.3527562 0.3858435 0.1958496 0.7866884 1.4687171 0.9631467
#2.4111877 0.6656348 0.6611290
mapview::mapview(burial_mounds_14, col.regions = "blue") +
mapview::mapview(all_mtpi_WS_ta_14, col.regions = "goldenrod")

#------------------------------------------------------------------------------#
IoU_mtpiWSta_ID_35 <- IoU(burial_mounds_35_12, all_mtpi_WS_ta_35)
#0.5945741 0.5416107
mapview::mapview(burial_mounds_35_12, col.regions = "blue") +
mapview::mapview(all_mtpi_WS_ta_35, col.regions = "goldenrod")
####-----------------------#iSEG_mtpi_RG_ta#--------------------------------####
IoU_mtpiRGta_ID_5 <- IoU(burial_mounds_5, all_mtpi_RG_ta_5)
#0.6916574 0.3089561 0.4737256 0.3383026 0.3307759 0.4425936 0.4919391 0.2553324 0.4591942
IoU_mtpiRGta_ID_7 <- IoU(burial_mounds_7, all_mtpi_RG_ta_7)
#0.4427740 0.6060192 0.3652953 0.2427830 0.1977442 0.2548853 0.2313031 0.3630199 0.3728586
IoU_mtpiRGta_ID_14 <- IoU(burial_mounds_14, all_mtpi_RG_ta_14)
#0.33913053 0.52315816 0.37518759 0.09094182 0.12989705 0.36437407 0.62030808
#0.41942703 0.07904219 0.11138126 0.64446102 0.28962327 0.15121453 0.20499657
#0.23934780 0.73292913 1.30081479 1.16202590 0.46385380
