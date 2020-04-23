


AdaptOutput <- function(dataFrame, chainLength, executionTimes = TRUE){
  output <- integer(chainLength) 
  if(executionTimes){
    output <- dataFrame[, 1]
  }
  else{
    output <- dataFrame[, 2]
  }
  #  minTime = min(output)
  #  output <- output - minTime
  #  print("output")
  #  print(output[1:10])
  return(output)
}

LimitTimes <- function(dataFrame, resolution, chainLength){
  executionTime <- dataFrame$executionTime
  #wakeUpLatency <- dataFrame$wakeUpLatency
  for(i in 1:chainLength){
    etModulo = executionTime[i]%%resolution
    # go up to the next level decided by resolution
    if (etModulo != 0){
      executionTime[i] = resolution * ((executionTime[i] %/% resolution) + 1)
    }
   # latMod = wakeUpLatency[i]%%resolution
   # if (latMod != 0)
  #    wakeUpLatency[i] = resolution * ((wakeUpLatency[i] %/% resolution) + 1)
  }
  dataFrame$executionTime = executionTime
  #dataFrame$wakeUpLatency = wakeUpLatency
  return(dataFrame)
  
}

export("AdaptDataFrame")
AdaptDataFrame <- function (dataFrame, resolution = 1, executionTimes=TRUE)  {
  chainLength <- length(dataFrame$executionTime)
  dataFrame <- LimitTimes(dataFrame, resolution, chainLength)
  dataFrame$indices=seq(1, chainLength)
  dataFrame$outputs = AdaptOutput(dataFrame, chainLength, executionTimes)
  return(dataFrame)
}


export("AdaptDataFrameLog")
AdaptDataFrameLog <- function (dataFrame, resolution = 1, executionTimes=TRUE)  {
  chainLength <- length(dataFrame$executionTime)
  dataFrame <- LimitTimes(dataFrame, resolution, chainLength)
  dataFrame$indices=seq(1, chainLength)
  dataFrame$outputs = log(AdaptOutput(dataFrame, chainLength, executionTimes))
  return(dataFrame)
}




