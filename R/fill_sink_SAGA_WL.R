filled_DTM_SAGA_WL <- function(dtm, output, tmp, minslope, crs) {
  cat(" ", sep = "\n")
  cat("----function filled_DTM_SAGA_W&L starts----")
  raster::writeRaster(dtm, filename=paste0(file.path(tmp),"/dtm.sdat"), overwrite = TRUE, NAflag = 0)
  RSAGA::rsaga.geoprocessor(lib = "ta_preprocessor", module = 4,
                            param = list(ELEV =    paste(tmp,"/dtm.sgrd", sep = ""),
                                         WSHED =   paste(tmp,"/wshed.sgrd", sep = ""),
                                         FDIR =    paste(tmp,"/fdir.sgrd", sep = ""),
                                         FILLED =  paste(tmp,"/pf_ifDTM_W&L.sgrd", sep = ""),
                                         MINSLOPE = minslope),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  cat(" ", sep = "\n")
  cat("----projecting pf_ifDTM_W&L----")
  prjctn <- crs
  pf_ifDTM_WL <- raster::raster(file.path(tmp, "/pf_ifDTM_W&L.sdat"))
  proj4string(pf_ifDTM_WL) <- prjctn
  cat(" ", sep = "\n")
  cat("----writing raster----")
  raster::writeRaster(pf_ifDTM_WL, filename=paste0(file.path(output), "/pf_ifDTM_W&L.tif"), overwrite = TRUE, NAflag = 0)
  cat(" ", sep = "\n")
  cat("----function filled_DTM_SAGA_W&L finished----")
  cat(" ", sep = "\n")
}
