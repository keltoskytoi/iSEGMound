generate_mtpi_SAGA <- function(dtm, output, tmp, scale_min, scale_max, scale_num, crs) {
  cat(" ", sep = "\n")
  cat("----function generate_mtpi_SAGA starts----")
  raster::writeRaster(dtm, filename=paste0(file.path(tmp),"/dtm.sdat"), overwrite = TRUE, NAflag = 0)
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 28,
                            param = list(DEM=paste(tmp,"/dtm.sgrd", sep = ""),
                                         TPI=paste(tmp,"/mtpi.sgrd", sep = ""),
                                         SCALE_MIN=scale_min,
                                         SCALE_MAX=scale_max,
                                         SCALE_NUM=scale_num),
                              show.output.on.console = TRUE, invisible = TRUE,
                              env = env)
  cat(" ", sep = "\n")
  cat("----projecting pf_mtpi----")
  prjctn <- crs
  mtpi <- raster::raster(file.path(tmp, "/mtpi.sdat"))
  proj4string(mtpi) <- prjctn
  cat(" ", sep = "\n")
  cat("----writing raster----")
  raster::writeRaster(mtpi, filename=paste0(file.path(output), "/dDTM05.tif"), overwrite = TRUE, NAflag = 0)
  cat(" ", sep = "\n")
  cat("----function generate MTPI SAGA finished----")
  cat(" ", sep = "\n")
}
