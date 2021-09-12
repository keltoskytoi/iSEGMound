#this function was taken and changed based on the LEGION package
filtR <- function(Rstfile, filtRs="all", sizes, NArm=TRUE){

  ### set default
  if(any(filtRs=="all")){
    filtRs <-c("sum", "min","max", "mean", "median", "modal", "sd", "sobel")
  }else{filtRs==filtRs}

  #check for wrong sizes input
  if(any(sizes %% 2 == 0)){
    stop("sizes contain even values (use odd values only)")
  }

  filterstk <-lapply(filtRs, function(item){

    #sum filter
    if (item=="sum"){
      cat(" ", sep = "\n")
      cat("processing sum filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("-starting sum  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        sumfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f,ncol=f), fun=sum,na.rm=NArm)
        names(sumfR) <- paste0(names(Rstfile), "_sum" ,as.factor(f))
        stack(sumfR)
        return(sumfR)
      })
    }#end

    #min filter
    else if (item=="min"){
      cat(" ", sep = "\n")
      cat("processing minimum filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("-starting min  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        minfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f,ncol=f), fun=min, na.rm=NArm)
        names(minfR) <- paste0(names(Rstfile), "_min", as.factor(f))
        return(minfR)
      })
    }#end

    #max filter
    else if (item=="max"){
      cat(" ", sep = "\n")
      cat("processing maximum filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("-starting max  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        maxfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f, ncol=f), fun=max, na.rm=NArm)
        names(maxfR) <- paste0(names(Rstfile), "_max", as.factor(f))
        return(maxfR)
      })
    }#end

    #mean filter
    else if (item=="mean"){
      cat(" ", sep = "\n")
      cat("processing mean filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("-starting mean  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        meanfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f, ncol=f), fun=mean, na.rm=NArm)
        names(meanfR) <- paste0(names(Rstfile), "_mean", as.factor(f))
        return(meanfR)
      })
    }#end

    #median filter
    else if (item=="median"){
      cat(" ", sep = "\n")
      cat("processing median filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("-starting median  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        medianfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f, ncol=f), fun=median, na.rm=NArm)
        names(medianfR) <- paste0(names(Rstfile), "_median", as.factor(f))
        return(medianfR)
      })
    }#end

    #modal filter
    else if (item=="modal"){
      cat(" ",sep = "\n")
      cat("processing modal filter", sep = "\n")
      lapply(sizes,function(f){
        cat(paste0("-starting modal  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        modalfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f,ncol=f), fun=modal, na.rm=NArm)
        names(modalfR) <- paste0(names(Rstfile),"_modal" , as.factor(f))
        return(modalfR)
      })
    }#end

    #sd filter
    else if (item=="sd"){
      cat(" ",sep = "\n")
      cat("processing standard deviation filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("-starting sd   ", as.factor(f), "*", as.factor(f), sep = "\n"))
        sdfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f, ncol=f),fun=sd, na.rm=NArm)
        names(sdfR) <- paste0(names(Rstfile),"_sd", as.factor(f))
        return(sdfR)
      })
    }#end

    #sobel filter
    else if (item=="sobel"){
      cat(" ",sep = "\n")
      cat("processing sobel filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("-starting sobel  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        range = f/2
        mx = matrix(nrow = f, ncol = f)
        my = mx

        for(i in seq(-floor(range), floor(range))){
          for(j in seq(-floor(range), floor(range))){
            mx[i+ceiling(range),j+ceiling(range)] = i / (i*i + j*j)
            my[i+ceiling(range),j+ceiling(range)] = j / (i*i + j*j)
          }
        }

        mx[is.na(mx)] = 0
        my[is.na(my)] = 0

        sobelfR <- sqrt(raster::focal(Rstfile, mx, fun=sum, na.rm=NArm)**2+
                        raster::focal(Rstfile, my, fun=sum, na.rm=NArm)**2)
        names(sobelfR) <- paste0(names(Rstfile), "_sobel", as.factor(f))
        return(sobelfR)
      })
    }#end

  })#end main lapply

  #########################################
  #handle output format
  unLS <- unlist(filterstk)
  cat(" ",sep = "\n")
  cat("###########################",sep = "\n")
  cat("Filters are calculated",sep = "\n")
  return(raster::stack(unLS))

}#end fun
