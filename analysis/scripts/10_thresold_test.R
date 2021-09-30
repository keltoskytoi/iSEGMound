#######################################1########################################
####-----------CALCULATE DESCRIPTIVE VAIRABLES FOR SITE ID 5----------------####
#compare Site ID 5 in iSEG_mtpi_WS_ta and iSEG_mtpi_WS_AOI4 + segments_shape_descriptive_joined_mtpi_WS_AOI_4
iSEG_mtpi_WS_ta <- readOGR(paste0(path_analysis_results_6b_iSEG05_mtpi_WS_ta, "iSEG_mtpi_WS_ta.shp"))
mapview::mapview(iSEG_mtpi_WS_ta)
segments_shape_descriptive_joined_mtpi_WS_AOI_4 <- readOGR(paste0(path_analysis_results_7d_iSEG05_AOI_4, "segments_shape_descriptive_joined_mtpi_WS_AOI_4.shp"))
segments_iSEG_mtpi_WS_AOI_4 <- readOGR(paste0(path_analysis_results_7d_iSEG05_AOI_4, "iSEG_AOI_4.shp"))

#the IDs are identified using QGIS

#iSEG_mtpi_WS_ta
Site_ID5_1_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 10408)
Site_ID5_2_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 9659)
Site_ID5_3_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 8589)
Site_ID5_4_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 9040)
Site_ID5_5_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 8532)
Site_ID5_6_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 9305)
Site_ID5_7_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 10418)
Site_ID5_8_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 11777)
Site_ID5_9_WS_ta <- iSEG_mtpi_WS_ta %>%
                    dplyr::filter(ID == 6701)

mapview::mapview(Site_ID5_1_WS_ta) + Site_ID5_2_WS_ta + Site_ID5_3_WS_ta +
  Site_ID5_4_WS_ta + Site_ID5_5_WS_ta + Site_ID5_6_WS_ta +
  Site_ID5_7_WS_ta + Site_ID5_8_WS_ta + Site_ID5_9_WS_ta

Site_ID5_1_WS_ta$A       #576
Site_ID5_1_WS_ta$Sphrcty #0.4211772
Site_ID5_1_WS_ta$Shp_Ind #2.374298
Site_ID5_1_WS_ta$elongtn #1.140856
Site_ID5_1_WS_ta$cmpctns #0.1340649
Site_ID5_1_WS_ta$rondnss #22.2683

Site_ID5_2_WS_ta$A       #78.25
Site_ID5_2_WS_ta$Sphrcty #0.53149
Site_ID5_2_WS_ta$Shp_Ind #1.881503
Site_ID5_2_WS_ta$elongtn #1.168186
Site_ID5_2_WS_ta$cmpctns #0.1691785
Site_ID5_2_WS_ta$rondnss #7.798604

Site_ID5_3_WS_ta$A       #68.25
Site_ID5_3_WS_ta$Sphrcty #0.6366466
Site_ID5_3_WS_ta$Shp_Ind #1.57073
Site_ID5_3_WS_ta$elongtn #1.122967
Site_ID5_3_WS_ta$cmpctns #0.2026509
Site_ID5_3_WS_ta$rondnss #7.86768

Site_ID5_4_WS_ta$A       #83.75
Site_ID5_4_WS_ta$Sphrcty #0.4915338
Site_ID5_4_WS_ta$Shp_Ind #2.034448
Site_ID5_4_WS_ta$elongtn #1.201858
Site_ID5_4_WS_ta$cmpctns #0.1564601
Site_ID5_4_WS_ta$rondnss #7.123866

Site_ID5_5_WS_ta$A       #73.75
Site_ID5_5_WS_ta$Sphrcty #0.5535072
Site_ID5_5_WS_ta$Shp_Ind #1.806661
Site_ID5_5_WS_ta$elongtn #1.257404
Site_ID5_5_WS_ta$cmpctns #0.1761868
Site_ID5_5_WS_ta$rondnss #7.527906

Site_ID5_6_WS_ta$A       #159.75
Site_ID5_6_WS_ta$Sphrcty #0.4525746
Site_ID5_6_WS_ta$Shp_Ind #2.209581
Site_ID5_6_WS_ta$elongtn #1.388532
Site_ID5_6_WS_ta$cmpctns #0.144059
Site_ID5_6_WS_ta$rondnss #9.765713

Site_ID5_7_WS_ta$A       #103.75
Site_ID5_7_WS_ta$Sphrcty #0.555502
Site_ID5_7_WS_ta$Shp_Ind #1.800174
Site_ID5_7_WS_ta$elongtn #1.373006
Site_ID5_7_WS_ta$cmpctns #0.1768218
Site_ID5_7_WS_ta$rondnss #8.189425

Site_ID5_8_WS_ta$A       #86
Site_ID5_8_WS_ta$Sphrcty #0.53892
Site_ID5_8_WS_ta$Shp_Ind #1.855563
Site_ID5_8_WS_ta$elongtn #1.366117
Site_ID5_8_WS_ta$cmpctns #0.1715436
Site_ID5_8_WS_ta$rondnss #7.286651

Site_ID5_9_WS_ta$A       #74
Site_ID5_9_WS_ta$Sphrcty #0.4419485
Site_ID5_9_WS_ta$Shp_Ind #2.262707
Site_ID5_9_WS_ta$elongtn #1.698944
Site_ID5_9_WS_ta$cmpctns #0.1406766
Site_ID5_9_WS_ta$rondnss #6.191642

#------------------------------------------------------------------------------#
#iSEG_mtpi_WS_AOI4
Site_ID5_1_WS_AoI4 <- segments_shape_descriptive_joined_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 190732)
Site_ID5_2_WS_AoI4 <- segments_iSEG_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 187593)
Site_ID5_3_WS_AoI4 <- segments_iSEG_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 183032)
Site_ID5_4_WS_AoI4 <- segments_iSEG_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 184999)
Site_ID5_5_WS_AoI4 <- segments_iSEG_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 182700)
Site_ID5_6_WS_AoI4 <- segments_shape_descriptive_joined_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 186082)
Site_ID5_7_WS_AoI4 <- segments_iSEG_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 190860)
Site_ID5_8_WS_AoI4 <- segments_iSEG_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 197747)
Site_ID5_9_WS_AoI4 <- segments_iSEG_mtpi_WS_AOI_4 %>%
                      dplyr::filter(ID == 172526)

mapview::mapview(Site_ID5_1_WS_AoI4) + Site_ID5_2_WS_AoI4 + Site_ID5_3_WS_AoI4 +
                 Site_ID5_4_WS_AoI4 + Site_ID5_5_WS_AoI4 + Site_ID5_6_WS_AoI4 +
                 Site_ID5_7_WS_AoI4 + Site_ID5_8_WS_AoI4 + Site_ID5_9_WS_AoI4
################################################################################
Site_ID5_1_WS_AoI4$A       #590.75
Site_ID5_1_WS_AoI4$Sphrcty #0.4558742
Site_ID5_1_WS_AoI4$Shp_Ind #2.193588
Site_ID5_1_WS_AoI4$elongtn #1.140856
Site_ID5_1_WS_AoI4$cmpctns #0.1451093
Site_ID5_1_WS_AoI4$rondnss #22.83853

Site_ID5_2_WS_AoI4$A       #52
Site_ID5_2_WS_AoI4$Sphrcty #0.3195337
Site_ID5_2_WS_AoI4$Shp_Ind #3.129561
Site_ID5_2_WS_AoI4$elongtn #1.245981
Site_ID5_2_WS_AoI4$cmpctns #0.1017107
Site_ID5_2_WS_AoI4$rondnss #5.048634

Site_ID5_3_WS_AoI4$A       #66.5
Site_ID5_3_WS_AoI4$Sphrcty #0.6150606
Site_ID5_3_WS_AoI4$Shp_Ind #1.625856
Site_ID5_3_WS_AoI4$elongtn #1.137158
Site_ID5_3_WS_AoI4$cmpctns #0.1957799
Site_ID5_3_WS_AoI4$rondnss #7.665945

Site_ID5_4_WS_AoI4$A       #82.75
Site_ID5_4_WS_AoI4$Sphrcty #0.4885905
Site_ID5_4_WS_AoI4$Shp_Ind #2.046704
Site_ID5_4_WS_AoI4$elongtn #1.201858
Site_ID5_4_WS_AoI4$cmpctns #0.1555232
Site_ID5_4_WS_AoI4$rondnss #7.038805

Site_ID5_5_WS_AoI4$A       #72.25
Site_ID5_5_WS_AoI4$Sphrcty #0.5380663
Site_ID5_5_WS_AoI4$Shp_Ind #1.858507
Site_ID5_5_WS_AoI4$elongtn #1.283805
Site_ID5_5_WS_AoI4$cmpctns #0.1712718
Site_ID5_5_WS_AoI4$rondnss #7.289991

Site_ID5_6_WS_AoI4$A       #149.5
Site_ID5_6_WS_AoI4$Sphrcty #0.5222127
Site_ID5_6_WS_AoI4$Shp_Ind #1.914929
Site_ID5_6_WS_AoI4$elongtn #1.067092
Site_ID5_6_WS_AoI4$cmpctns #0.1662255
Site_ID5_6_WS_AoI4$rondnss #11.89209

Site_ID5_7_WS_AoI4$A       #100.75
Site_ID5_7_WS_AoI4$Sphrcty #0.5310711
Site_ID5_7_WS_AoI4$Shp_Ind #1.882987
Site_ID5_7_WS_AoI4$elongtn #1.373006
Site_ID5_7_WS_AoI4$cmpctns #0.1690452
Site_ID5_7_WS_AoI4$rondnss #7.952622

Site_ID5_8_WS_AoI4$A       #69.5
Site_ID5_8_WS_AoI4$Sphrcty #0.5794649
Site_ID5_8_WS_AoI4$Shp_Ind #1.72573
Site_ID5_8_WS_AoI4$elongtn #1.168269
Site_ID5_8_WS_AoI4$cmpctns #0.1844494
Site_ID5_8_WS_AoI4$rondnss #7.087005

Site_ID5_9_WS_AoI4$A       #69.25
Site_ID5_9_WS_AoI4$Sphrcty #0.4999917
Site_ID5_9_WS_AoI4$Shp_Ind #2.000033
Site_ID5_9_WS_AoI4$elongtn #1.448796
Site_ID5_9_WS_AoI4$cmpctns #0.1591523
Site_ID5_9_WS_AoI4$rondnss #6.794626

#######################################2.#######################################
#####-----------------#LET'S FILTER THE SEGMENTS DIFFERENTLY#---------------####
#----------------------------#LOAD SHAPE FILES & PLOT THEM#--------------------#
burial_mounds_32632 <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "burial_mounds_32632.shp"))
#we already have the additional descriptive variables calculated
segments_iSEG_mtpi_WS_AOI_4 <- readOGR(paste0(path_analysis_results_7d_iSEG05_AOI_4,
                                              "segments_shape_descriptive_joined_mtpi_WS_AOI_4.shp"))
crs(segments_iSEG_mtpi_WS_AOI_4)
names(segments_iSEG_mtpi_WS_AOI_4)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"
################################################################################
####---------------------------#MOUND THRESHOLDS#---------------------------####
#original mound thresholds:
segments_iSEG_mtpi_WS_ta_filt <- segments_iSEG_mtpi_WS_ta[segments_iSEG_mtpi_WS_ta$A <= 576.1 & segments_iSEG_mtpi_WS_ta$A >= 45.20 &
                                                          segments_iSEG_mtpi_WS_ta$Sphrcty >= 0.2951891 & segments_iSEG_mtpi_WS_ta$Sphrcty <= 0.6417927 &
                                                          segments_iSEG_mtpi_WS_ta$Shp_Ind >= 1.558135 & segments_iSEG_mtpi_WS_ta$Shp_Ind <= 3.387660 &
                                                          segments_iSEG_mtpi_WS_ta$elongtn >= 1.122960 & segments_iSEG_mtpi_WS_ta$elongtn <=1.913620 &
                                                          segments_iSEG_mtpi_WS_ta$cmpctns >= 0.09396160 & segments_iSEG_mtpi_WS_ta$cmpctns <= 0.2042890 &
                                                          segments_iSEG_mtpi_WS_ta$rondnss >= 5.00866 & segments_iSEG_mtpi_WS_ta$rondnss <= 22.2684,]

#let's increase the max threshold of iSEG_mtpi_WS_ta by 3% and lower the min threshold by 3%
segments_iSEG_mtpi_WS_AOI_4_filt_2 <- segments_iSEG_mtpi_WS_AOI_4[segments_iSEG_mtpi_WS_AOI_4$A <= 593.28 & segments_iSEG_mtpi_WS_AOI_4$A >= 43.844 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$Sphrcty >= 0.286333427 & segments_iSEG_mtpi_WS_AOI_4$Sphrcty <= 0.6661046481 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$Shp_Ind >= 1.51139095 & segments_iSEG_mtpi_WS_AOI_4$Shp_Ind <= 3.4892898 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$elongtn >= 1.0892712 & segments_iSEG_mtpi_WS_AOI_4$elongtn <=1.9710286 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$cmpctns >= 0.0911427617 & segments_iSEG_mtpi_WS_AOI_4$cmpctns <= 0.21041767 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$rondnss >= 4.85840796 & segments_iSEG_mtpi_WS_AOI_4$rondnss <= 22.936452,]
mapview::mapview(segments_iSEG_mtpi_WS_AOI_4_filt2) + burial_mounds_32632
#------------------------------------------------------------------------------#
rgdal::writeOGR(obj=segments_iSEG_mtpi_WS_AOI_4_filt_2, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/results/7d_iSEG05_AOI_4",
                layer ="iSEG_AOI_4_filt_3_perc", driver = "ESRI Shapefile", verbose = TRUE, overwrite_layer = TRUE)

#let's increase the max threshold of iSEG_mtpi_WS_ta by 10% and lower the min threshold by 10%
segments_iSEG_mtpi_WS_AOI_4_filt_3 <- segments_iSEG_mtpi_WS_AOI_4[segments_iSEG_mtpi_WS_AOI_4$A <= 633.71 & segments_iSEG_mtpi_WS_AOI_4$A >= 40.68 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$Sphrcty >= 0.26567019 & segments_iSEG_mtpi_WS_AOI_4$Sphrcty <= 0.70597197 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$Shp_Ind >= 1.4023215 & segments_iSEG_mtpi_WS_AOI_4$Shp_Ind <= 3.726426 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$elongtn >= 1.010664 & segments_iSEG_mtpi_WS_AOI_4$elongtn <=2.104982 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$cmpctns >= 0.08456544 & segments_iSEG_mtpi_WS_AOI_4$cmpctns <= 0.2247179 &
                                                                 segments_iSEG_mtpi_WS_AOI_4$rondnss >= 4.507794 & segments_iSEG_mtpi_WS_AOI_4$rondnss <= 24.49524,]
mapview::mapview(segments_iSEG_mtpi_WS_AOI_4_filt_3) + burial_mounds_32632
#------------------------------------------------------------------------------#
rgdal::writeOGR(obj=segments_iSEG_mtpi_WS_AOI_4_filt_3, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/results/7d_iSEG05_AOI_4",
                layer ="iSEG_AOI_4_filt_10_perc", driver = "ESRI Shapefile", verbose = TRUE, overwrite_layer = TRUE)
