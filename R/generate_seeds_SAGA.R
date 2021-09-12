generate_seedpoints_SAGA <- function(dtm, tmp, seedtype, method, band_width,
                                     normalize, dw_weighting, dw_idw_power,
                                     dw_bandwidth, crs) {
  cat(" ", sep = "\n")
  cat("----function generate_seedpoints_SAGA starts----")
  raster::writeRaster(dtm, filename=paste0(file.path(tmp),"/dtm.sdat"), overwrite = TRUE, NAflag = 0)
  RSAGA::rsaga.geoprocessor(lib = "imagery_segmentation", module = 2,
                            param = list(FEATURES=paste(tmp,"/dtm.sgrd", sep = ""),
                                         VARIANCE=paste(tmp,"/variance.sgrd", sep = ""),
                                         SEED_GRID=paste(tmp,"/seedpoints.sgrd", sep = ""),
                                         SEED_POINTS=paste(tmp,"/seeds.shp", sep = ""),
                                         SEED_TYPE=seedtype,
                                         METHOD=method,
                                         BAND_WIDTH=band_width,
                                         NORMALIZE=normalize,
                                         DW_WEIGHTING=dw_weighting,
                                         DW_IDW_POWER=dw_idw_power,
                                         DW_BANDWIDTH=dw_bandwidth),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  cat(" ", sep = "\n")
  cat("----projecting generated seedpoints----")
  prjctn <- crs
  seedpoints <- raster::raster(paste0(tmp, "/seedpoints.sdat"))
  proj4string(seedpoints) <- prjctn
  cat(" ", sep = "\n")
  cat("----projecting generated seeds----")
  prjctn <- crs
  seeds <- rgdal::readOGR(paste0(tmp, "/seeds.shp"))
  proj4string(seeds) <- prjctn
  cat(" ", sep = "\n")
  cat("----generate_seedpoints_SAGA finished----")
  cat(" ", sep = "\n")
}





