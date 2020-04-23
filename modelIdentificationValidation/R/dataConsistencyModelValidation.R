
export("simulateTrajectory")
simulateTrajectory <- function(depmixModel){
  sim <- depmixS4::simulate(depmixModel)
  dataFrameSim <- data.frame("states"=sim@states)
  nResponses <- length(sim@response)
  nSamples <- depmixModel@ntimes[1]
  outputPerState <- array(dim=c(nResponses, nSamples))
  for (i in 1:nResponses){
    outputPerState[i,] <- depmixS4::simulate(sim@response[[i]][[1]])
  }
  
  simOutput <- array(dim=nSamples)
  for(i in 1:nSamples){
    simOutput[i] <- outputPerState[sim@states[i], i]
  }
  dataFrameSim$outputs = simOutput
  return(dataFrameSim)
}


export("logLikelihoodStatesTraj")
logLikelihoodStatesTraj <- function(dataFrame, depmixModel, transitionMatrix, normalParams){
  evalModel <- depmixS4::depmix(outputs~1, data=dataFrame, nstates=depmixModel@nstates, family = stats::gaussian())
  evalModel <- depmixS4::setpars(evalModel, depmixS4::getpars(depmixModel))
  forwardBackwardResults <- depmixS4::forwardbackward(evalModel, return.all=TRUE)
  logLikelihoodsStatesTraj <- matrix(nrow=length(forwardBackwardResults$sca)-1, ncol=depmixModel@nstates + 1)
  for(i in 2:length(forwardBackwardResults$sca)){
    for (j in 1:depmixModel@nstates){
      probj <- 0
      for (k in 1:depmixModel@nstates){
        probj = probj + transitionMatrix[k, j]*forwardBackwardResults$alpha[i-1, k]
      }
      logLikelihoodsStatesTraj[i-1, j] = log(probj) + stats::dnorm(dataFrame$outputs[i], mean=normalParams[j,1],
                                                                 sd=normalParams[j, 2], log=TRUE)
    }
    logLikelihoodsStatesTraj[i-1, depmixModel@nstates +1] = -log(forwardBackwardResults$sca[i])
  }
  return(logLikelihoodsStatesTraj)
}

export("simZStatesTraj")
simZStatesTraj <- function(depmixModel, N, transitionMatrix, normalParams){
  simList = replicate(n = N,
                      expr = {simulateTrajectory(depmixModel)},
                      simplify = F)
  zList <- lapply(simList, logLikelihoodStatesTraj, depmixModel, transitionMatrix, normalParams)
  z <- list()
  for (i in 1:(depmixModel@nstates +1)) {
    z[[i]] <- matrix(nrow=depmixModel@ntimes-1, ncol=N)
    for (j in 1:N){
      z[[i]][,j] <- zList[[j]][,i]
    }
  }
  return(z)
}







