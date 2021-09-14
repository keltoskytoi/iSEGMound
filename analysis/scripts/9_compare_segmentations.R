################################################################################
####--------#CALCULATE IoU FOR iSEG_mtpi_WS_ta/RG_ta MOUND SEGMENTS#--------####
################################################################################
####-------------#1.READ MOUNDS DOBIAT 1994 IN THE TRAIN AREA#--------------####
burial_mounds_5_SHI <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994_SHI.shp"))
burial_mounds_7_SHI <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994_SHI.shp"))
burial_mounds_9_SHI <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "9_Dobiat_1994_SHI.shp"))
burial_mounds_14_SHI <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994_SHI.shp"))
burial_mounds_35_SHI <- st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994_SHI.shp"))
####-------------------#2.READ SEGMENTATION RESULTS TO COMPARE#-------------####
iSEG_mtpi_WS_ta<-st_read(paste0(path_analysis_results_6b_iSEG05_mtpi_WS_ta, "iSEG_mtpi_WS_ta.shp"))
iSEG_mtpi_RG_ta <-st_read(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "iSEG_mtpi_RG_ta.shp"))
st_crs(iSEG_mtpi_RG_ta) <-  st_crs(iSEG_mtpi_WS_ta)
################################################################################
####-------#EXTRACT SHAPE VALUES FROM iSEG_mtpi_WS_ta FOR THE MOUNDS#-------####
mapview::mapview(iSEG_mtpi_WS_ta, col.regions = "goldenrod") +
mapview::mapview(burial_mounds_7_SHI, col.regions = "blue")
#check in QGIS the new ID in the shapefile
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
mtpi_WS_ta_5_1 <- iSEG_mtpi_WS_ta[28,]
mtpi_WS_ta_5_2 <- iSEG_mtpi_WS_ta[27,]
mtpi_WS_ta_5_3 <- iSEG_mtpi_WS_ta[23,]
mtpi_WS_ta_5_4 <- iSEG_mtpi_WS_ta[24,]
mtpi_WS_ta_5_5 <- iSEG_mtpi_WS_ta[22,]
mtpi_WS_ta_5_6 <- iSEG_mtpi_WS_ta[25,]
mtpi_WS_ta_5_7 <- iSEG_mtpi_WS_ta[29,]
mtpi_WS_ta_5_8 <- iSEG_mtpi_WS_ta[31,]
mtpi_WS_ta_5_9 <- iSEG_mtpi_WS_ta[17,]
#check on map
mapview::mapview(burial_mounds_5_SHI, col.regions = "blue") +
mapview::mapview(mtpi_WS_ta_5_9, col.regions = "goldenrod")
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
mtpi_WS_ta_7_2 <- iSEG_mtpi_WS_ta[44,]
mtpi_WS_ta_7_3 <- iSEG_mtpi_WS_ta[43,]
mtpi_WS_ta_7_4 <- iSEG_mtpi_WS_ta[48,]
mtpi_WS_ta_7_5 <- iSEG_mtpi_WS_ta[54,]
mtpi_WS_ta_7_6 <- iSEG_mtpi_WS_ta[52,]
mtpi_WS_ta_7_7 <- iSEG_mtpi_WS_ta[57,]
mtpi_WS_ta_7_8 <- iSEG_mtpi_WS_ta[59,]
mtpi_WS_ta_7_9 <- iSEG_mtpi_WS_ta[60,]
#------------------------#Dobiat 1994, Grave group 9#--------------------------#
mtpi_WS_ta_9 <- iSEG_mtpi_WS_ta[38,]
#------------------------#Dobiat 1994, Grave group 14#-------------------------#
mapview::mapview(iSEG_mtpi_WS_ta, col.regions = "goldenrod") +
mapview::mapview(burial_mounds_7_SHI, col.regions = "blue")

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
#------------------------#Dobiat 1994, Grave group 35#-------------------------#
mtpi_WS_ta_35 <- iSEG_mtpi_WS_ta[35,]
mtpi_WS_ta_35_2 <-iSEG_mtpi_WS_ta[34,]
################################################################################
####----------------------#CALCULATING IoU#---------------------------------####
#-------------#function from the NeonTreeEvaluation_package#-------------------#
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
IoU_mtpiWSta_ID_5_1 <- IoU(burial_mounds_5_SHI[1,], mtpi_WS_ta_5_1)
#0.7133065
IoU_mtpiWSta_ID_5_2 <- IoU(burial_mounds_5_SHI[2,], mtpi_WS_ta_5_2)
#0.6003428
IoU_mtpiWSta_ID_5_3 <- IoU(burial_mounds_5_SHI[3,], mtpi_WS_ta_5_3)
#0.7130259
IoU_mtpiWSta_ID_5_4 <- IoU(burial_mounds_5_SHI[4,], mtpi_WS_ta_5_4)
#0.5765421
IoU_mtpiWSta_ID_5_5 <- IoU(burial_mounds_5_SHI[5,], mtpi_WS_ta_5_5)
#0.5115062
IoU_mtpiWSta_ID_5_6 <- IoU(burial_mounds_5_SHI[6,], mtpi_WS_ta_5_6)
#0.5890535
IoU_mtpiWSta_ID_5_7 <- IoU(burial_mounds_5_SHI[7,], mtpi_WS_ta_5_7)
#0.6735597
IoU_mtpiWSta_ID_5_8 <- IoU(burial_mounds_5_SHI[8,], mtpi_WS_ta_5_8)
#0.5290715
IoU_mtpiWSta_ID_5_9 <- IoU(burial_mounds_5_SHI[9,], mtpi_WS_ta_5_9)
#0.4605544
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
IoU_mtpiWSta_ID_7_2 <- IoU(burial_mounds_7_SHI[2,], mtpi_WS_ta_7_2)
#0.804681
IoU_mtpiWSta_ID_7_3 <- IoU(burial_mounds_7_SHI[3,], mtpi_WS_ta_7_3)
#0.6831214

IoU_mtpiWSta_ID_7_4 <- IoU(burial_mounds_7_SHI[4,], mtpi_WS_ta_7_4)
#0.5397044
IoU_mtpiWSta_ID_7_5 <- IoU(burial_mounds_7_SHI[5,], mtpi_WS_ta_7_5)
#0.5403348
IoU_mtpiWSta_ID_7_6 <- IoU(burial_mounds_7_SHI[6,], mtpi_WS_ta_7_6)
#0.2942167
IoU_mtpiWSta_ID_7_7 <- IoU(burial_mounds_7_SHI[7,], mtpi_WS_ta_7_7)
#0.432601
IoU_mtpiWSta_ID_7_8 <- IoU(burial_mounds_7_SHI[8,], mtpi_WS_ta_7_8)
#0.6669532
IoU_mtpiWSta_ID_7_9 <- IoU(burial_mounds_7_SHI[9,], mtpi_WS_ta_7_9)
#0.4702287
#------------------------#Dobiat 1994, Grave group 9#--------------------------#
IoU_mtpiWSta_ID_9 <- IoU(burial_mounds_9_SHI, mtpi_WS_ta_9)
#0.4634704
#------------------------#Dobiat 1994, Grave group 14#--------------------------#
IoU_mtpiWSta_ID_14_2 <- IoU(burial_mounds_14_SHI[2,], mtpi_WS_ta_14_2)
#0.6061152
IoU_mtpiWSta_ID_14_3 <- IoU(burial_mounds_14_SHI[3,], mtpi_WS_ta_14_3)
#0.5767704
IoU_mtpiWSta_ID_14_4 <- IoU(burial_mounds_14_SHI[4,], mtpi_WS_ta_14_4)
#0.3778608
IoU_mtpiWSta_ID_14_5 <- IoU(burial_mounds_14_SHI[5,], mtpi_WS_ta_14_5)
#0.4620573
IoU_mtpiWSta_ID_14_7 <- IoU(burial_mounds_14_SHI[7,], mtpi_WS_ta_14_7)
#0.6880029
IoU_mtpiWSta_ID_14_9 <- IoU(burial_mounds_14_SHI[9,], mtpi_WS_ta_14_9)
#0.5652943
IoU_mtpiWSta_ID_14_10 <- IoU(burial_mounds_14_SHI[10,], mtpi_WS_ta_14_10)
#0.5316726
IoU_mtpiWSta_ID_14_12 <- IoU(burial_mounds_14_SHI[12,], mtpi_WS_ta_14_12)
#0.5927712
IoU_mtpiWSta_ID_14_13 <- IoU(burial_mounds_14_SHI[13,], mtpi_WS_ta_14_13)
#0.5579679
IoU_mtpiWSta_ID_14_14 <- IoU(burial_mounds_14_SHI[14,], mtpi_WS_ta_14_14)
#0.387372
IoU_mtpiWSta_ID_14_15 <- IoU(burial_mounds_14_SHI[15,], mtpi_WS_ta_14_15)
#0.3837281
IoU_mtpiWSta_ID_14_16 <- IoU(burial_mounds_14_SHI[16,], mtpi_WS_ta_14_16)
#0.4654447
IoU_mtpiWSta_ID_14_17 <- IoU(burial_mounds_14_SHI[17,], mtpi_WS_ta_14_17)
#0.4304659
IoU_mtpiWSta_ID_14_19 <- IoU(burial_mounds_14_SHI[19,], mtpi_WS_ta_14_19)
#0.7427452
#------------------------------------------------------------------------------#
IoU_mtpiWSta_ID_35_1 <- IoU(burial_mounds_35_SHI[1,], mtpi_WS_ta_35)
#0.5945741
IoU_mtpiWSta_ID_35_2 <- IoU(burial_mounds_35_SHI[2,], mtpi_WS_ta_35_2)
#0.6019239
################################################################################
####-------#EXTRACT SHAPE VALUES FROM iSEG_mtpi_RG_ta FOR THE MOUNDS#-------####
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
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
mapview::mapview(iSEG_mtpi_RG_ta, col.regions = "goldenrod") +
mapview::mapview(burial_mounds_7_SHI, col.regions = "blue")
mtpi_RG_ta_7_1 <- iSEG_mtpi_RG_ta[67,]
mtpi_RG_ta_7_2 <- iSEG_mtpi_RG_ta[68,]
mtpi_RG_ta_7_3 <- iSEG_mtpi_RG_ta[66,]
mtpi_RG_ta_7_5 <- iSEG_mtpi_RG_ta[70,]
mtpi_RG_ta_7_6 <- iSEG_mtpi_RG_ta[69,]
mtpi_RG_ta_7_8 <- iSEG_mtpi_RG_ta[71,]
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
#------------------------#Dobiat 1994, Grave group 35#-------------------------#
mtpi_RG_ta_35 <- iSEG_mtpi_RG_ta[63,]
################################################################################
####----------------------#CALCULATING IoU#---------------------------------####
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
IoU_mtpiRGta_ID_5_1 <- IoU(burial_mounds_5_SHI[1,], mtpi_RG_ta_5_1)
#0.6916574
IoU_mtpiRGta_ID_5_2 <- IoU(burial_mounds_5_SHI[2,], mtpi_RG_ta_5_2)
#0.3089561
IoU_mtpiRGta_ID_5_3 <- IoU(burial_mounds_5_SHI[3,], mtpi_RG_ta_5_3)
#0.4737256
IoU_mtpiRGta_ID_5_4 <- IoU(burial_mounds_5_SHI[4,], mtpi_RG_ta_5_4)
#0.3383026
IoU_mtpiRGta_ID_5_5 <- IoU(burial_mounds_5_SHI[5,], mtpi_RG_ta_5_5)
#0.3307759
IoU_mtpiRGta_ID_5_6 <- IoU(burial_mounds_5_SHI[6,], mtpi_RG_ta_5_6)
#0.4425936
IoU_mtpiRGta_ID_5_7 <- IoU(burial_mounds_5_SHI[7,], mtpi_RG_ta_5_7)
#0.4919391
IoU_mtpiRGta_ID_5_8 <- IoU(burial_mounds_5_SHI[8,], mtpi_RG_ta_5_8)
#0.2553324
IoU_mtpiRGta_ID_5_9 <- IoU(burial_mounds_5_SHI[9,], mtpi_RG_ta_5_9)
#0.4591942
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
IoU_mtpiRGta_ID_7_1 <- IoU(burial_mounds_7_SHI[1,], mtpi_RG_ta_7_1)
#0.44277
IoU_mtpiRGta_ID_7_2 <- IoU(burial_mounds_7_SHI[2,], mtpi_WS_ta_7_2)
#0.804681
IoU_mtpiRGta_ID_7_3 <- IoU(burial_mounds_7_SHI[3,], mtpi_RG_ta_7_3)
#0.4453112
IoU_mtpiRGta_ID_7_5 <- IoU(burial_mounds_7_SHI[5,], mtpi_RG_ta_7_5)
#0.3031546
IoU_mtpiRGta_ID_7_6 <- IoU(burial_mounds_7_SHI[6,], mtpi_RG_ta_7_6)
#0.1334789
IoU_mtpiRGta_ID_7_8 <- IoU(burial_mounds_7_SHI[8,], mtpi_RG_ta_7_8)
#0.3527253
#------------------------#Dobiat 1994, Grave group 14#--------------------------#
IoU_mtpiRGta_ID_14_1 <- IoU(burial_mounds_14_SHI[1,], mtpi_RG_ta_14_1)
#0.3391305
IoU_mtpiRGta_ID_14_2 <- IoU(burial_mounds_14_SHI[2,], mtpi_RG_ta_14_2)
#0.5231582
IoU_mtpiRGta_ID_14_4 <- IoU(burial_mounds_14_SHI[4,], mtpi_RG_ta_14_4)
#0.1315178
IoU_mtpiRGta_ID_14_5 <- IoU(burial_mounds_14_SHI[5,], mtpi_RG_ta_14_5)
#0.2316558
IoU_mtpiRGta_ID_14_6 <- IoU(burial_mounds_14_SHI[6,], mtpi_RG_ta_14_6)
#0.1310698
IoU_mtpiRGta_ID_14_7 <- IoU(burial_mounds_14_SHI[7,], mtpi_RG_ta_14_7)
#0.5178548
IoU_mtpiRGta_ID_14_9 <- IoU(burial_mounds_14_SHI[9,], mtpi_RG_ta_14_9)
#0.2414775
IoU_mtpiRGta_ID_14_10 <- IoU(burial_mounds_14_SHI[10,], mtpi_RG_ta_14_10)
#0.4640401
IoU_mtpiRGta_ID_14_11 <- IoU(burial_mounds_14_SHI[11,], mtpi_RG_ta_14_11)
#0.2050009
IoU_mtpiRGta_ID_14_12 <- IoU(burial_mounds_14_SHI[12,], mtpi_RG_ta_14_12)
#0.2642519
IoU_mtpiRGta_ID_14_13 <- IoU(burial_mounds_14_SHI[13,], mtpi_RG_ta_14_13)
#0.4759892
IoU_mtpiRGta_ID_14_15 <- IoU(burial_mounds_14_SHI[15,], mtpi_RG_ta_14_15)
#0.3126799
IoU_mtpiRGta_ID_14_16 <- IoU(burial_mounds_14_SHI[16,], mtpi_RG_ta_14_16)
#0.2659693
IoU_mtpiRGta_ID_14_17 <- IoU(burial_mounds_14_SHI[17,], mtpi_RG_ta_14_17)
#0.3467625
IoU_mtpiRGta_ID_14_18 <- IoU(burial_mounds_14_SHI[18,], mtpi_RG_ta_14_18)
#0.2179641
IoU_mtpiRGta_ID_14_19 <- IoU(burial_mounds_14_SHI[19,], mtpi_RG_ta_14_19)
#0.5368112
#------------------------------------------------------------------------------#
IoU_mtpiRGta_ID_35_1 <- IoU(burial_mounds_35_SHI[1,], mtpi_RG_ta_35)
#0.559646
