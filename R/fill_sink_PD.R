filled_DTM_SAGA_PD <- function(dtm, output, tmp, minslope, crs) {
  cat(" ", sep = "\n")
  cat("----function filled_DTM_SAGA_PD starts----")
  raster::writeRaster(dtm, filename=paste0(file.path(tmp),"/dtm.sdat"), overwrite = TRUE, NAflag = 0)
  RSAGA::rsaga.geoprocessor(lib = "ta_preprocessor", module = 3,
                            param = list(DEM =    paste(tmp,"/dtm.sgrd", sep = ""),
                                         RESULT =  paste(tmp,"/pf_ifDTM_PD.sgrd", sep = ""),
                                         MINSLOPE = minslope),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  cat(" ", sep = "\n")
  cat("----projecting pf_ifDTM_PD----")
  prjctn <- crs
  pf_ifDTM_PD <- raster::raster(file.path(tmp, "/pf_ifDTM_PD.sdat"))
  proj4string(pf_ifDTM_PD) <- prjctn
  cat(" ", sep = "\n")
  cat("----writing raster----")
  raster::writeRaster(pf_ifDTM_PD, filename=paste0(file.path(output),"/pf_ifDTM_PD.tif"), overwrite = TRUE, NAflag = 0)
  cat(" ", sep = "\n")
  cat("----function filled_DTM_SAGA_PD finished----")
  cat(" ", sep = "\n")
}
