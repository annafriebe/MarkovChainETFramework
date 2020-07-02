lib <- modules::use("R")

library(depmixS4)
library(ggplot2)
library(data.tree)

EstimateValidateModel <- function(index, dataFrame, dfTestList, outputDir, maxNStates, nPartitions){
  print(index)
  likelihoodsAndTree  <- lib$evalLikelihood$CrossValidationLikelihoodsAndClusteredTree(dataFrame, maxNStates, nPartitions)
  likelihoodsNCluster <- likelihoodsAndTree[[1]]
  plot(1:length(likelihoodsNCluster), likelihoodsNCluster)
  tree <- likelihoodsAndTree[[2]]
  print(likelihoodsNCluster)
  if(likelihoodsNCluster[1] == 0){
    return(list())
  }
  fittedMod <- lib$evalLikelihood$FitMarkovChainFromClusteredTree(dataFrame, tree)
  nStates <- tree$leafCount
  transitionMatrix <- matrix(nrow=nStates, ncol=nStates)
  # get the transition matrix
  for (r in 1:nStates){
    transitionRow = fittedMod@transition[[r]]@parameters$coefficients
    for (c in 1:nStates){
      transitionMatrix[r, c]<- transitionRow[c]
    }
  }
  filename <- paste(outputDir, "transitionMatrix", index, ".txt", sep="")
  write.table(transitionMatrix, file=filename, row.names=FALSE, col.names=FALSE)
  #get the normal distribution mean and stddev
  normalParams <- matrix(nrow=nStates, ncol=2)
  for (r in 1:nStates){
    normalParams[r, 1] <- fittedMod@response[[r]][[1]]@parameters$coefficients[[1]]
    normalParams[r, 2] <- fittedMod@response[[r]][[1]]@parameters$sd
  }
  filename <- paste(outputDir, "normalParams", index, ".txt", sep="")
  write.table(normalParams, file=filename, row.names=FALSE, col.names=FALSE)
  # get the stationary distribution
  # Get the eigenvectors of P, note: R returns right eigenvectors
  r=eigen(transitionMatrix)
  rvec=r$vectors
  # left eigenvectors are the inverse of the right eigenvectors
  lvec=ginv(r$vectors)
  # normalized is the stationary distribution
  pi_eig<-lvec[1,]/sum(lvec[1,])
  
  filename <- paste(outputDir, "stationaryDistr", index, ".txt", sep="")
  write.table(pi_eig, file=filename, row.names=FALSE, col.names=FALSE)
  
  dfsim <- lib$dataConsistencyModelValidation$simulateTrajectory(fittedMod)
  dfsim$index = seq(1, length(dfsim$outputs))
  p <- ggplot(dfsim, aes(x=index, y=outputs)) +
    geom_point()
  print(p)
  filename <- paste(outputDir, "simExecutionTimeSeq", index, ".eps", sep = "")
  ggsave(filename)
  filename <- paste(outputDir, "simExecutionTimeSeq", index, ".png", sep = "")
  ggsave(filename)
  p <- ggplot(dfsim, aes(x=outputs)) +
    geom_histogram(binwidth = 100) 
  print(p)
  filename <- paste(outputDir, "simExecutionTimeHist", index, ".eps", sep = "")
  ggsave(filename)
  filename <- paste(outputDir, "simExecutionTimeHist", index, ".png", sep = "")
  ggsave(filename)
  # simulate data from the fitted model
  # first for estimation of mean and variance
  zSim1 <- lib$dataConsistencyModelValidation$simZStatesTraj(fittedMod, MP, transitionMatrix, normalParams)
  Ez <- lapply(zSim1, apply, 1, mean)
  Vz <- lapply(zSim1, apply, 1, var)
  # then for consistency comparison
  zSim2 <- lib$dataConsistencyModelValidation$simZStatesTraj(fittedMod, M, transitionMatrix, normalParams)
  TSim <- list()
  for (i in 1:(nStates+1)){
    tmp <- (zSim2[[i]] - Ez[[i]])^2/Vz[[i]]
    TSim[[i]] <- apply(tmp, 2, mean)
  }
  print("get observation likelihoods")
  zObs <- lib$dataConsistencyModelValidation$logLikelihoodStatesTraj(dfsim, fittedMod, transitionMatrix, normalParams)
  TObs <- list()
  for (i in 1:(nStates+1)){
    TObs[[i]] <- mean((zObs[,i] - Ez[[i]])^2/Vz[[i]])
  }
  betaSim <- numeric(nStates + 1)
  for (j in 1:(nStates+1)){
    betaSim[j] = length(which(TSim[[j]] > TObs[[j]]))/ M
  }

  nTest <- length(dfTestList)
  print(nTest)
  betas <- matrix(nrow=nTest, ncol=nStates+1)
  for (i in 1:nTest){
    dfTest <- dfTestList[[i]]
    zObs <- lib$dataConsistencyModelValidation$logLikelihoodStatesTraj(dfTest, fittedMod, transitionMatrix, normalParams)
    TObs <- list()
    for(j in 1:(nStates+1)){
      TObs[[j]] <- mean((zObs[,j] - Ez[[j]])^2/Vz[[j]])
    }
    for (j in 1:(nStates+1)){
      betas[i, j] = length(which(TSim[[j]] > TObs[[j]]))/ M
    }
  }

  zObs <- lib$dataConsistencyModelValidation$logLikelihoodStatesTraj(dataFrame, fittedMod, transitionMatrix, normalParams)
  TObs <- list()
  for(j in 1:(nStates+1)){
    TObs[[j]] <- mean((zObs[,j] - Ez[[j]])^2/Vz[[j]])
  }
  betaModelTrain <- numeric(nStates + 1)
  for (j in 1:(nStates+1)){
    betaModelTrain[j] = length(which(TSim[[j]] > TObs[[j]]))/ M
  }
  filename <- paste(outputDir, "PFAuTable", index, ".txt", sep = "")
  write.table(betas, file=filename, row.names=FALSE, col.names=FALSE, sep=" & ")
  
  return(list(betas, betaModelTrain, betaSim))
}

dataFrame1 <- read.csv("input/simpleMarkovTimesTrain.csv")
dataFrame1 <- lib$importData$AdaptDataFrame(dataFrame1, 1, TRUE)

dataFrameTestList <- list()

for(i in seq(1:20)){
  filename <- paste("input/simpleMarkovTimesTest", i, ".csv", sep="")
  dfTest <- read.csv(filename)
  dfTest <- lib$importData$AdaptDataFrame(dfTest, 1, TRUE)
  dataFrameTestList[[i]] <- dfTest
}

indices <- seq(1, 10)
nPartitions <- 4
maxNStates <- 8
MP <- 100
M <- 100
nTest <- 1
outputDir <- "output/simpleMarkovTest/"


set.seed(13)
pfauList = lapply(indices, try(EstimateValidateModel), dataFrame1, dataFrameTestList, outputDir, maxNStates, nPartitions)
print(pfauList)



