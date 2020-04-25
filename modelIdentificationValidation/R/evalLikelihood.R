
EstimateCalcSufficientStatistics <- function(dataFrame, nStates, nPartitions, partitionsStop){
  chainLength <- length(dataFrame$outputs)
  rowStop = partitionsStop
  as.integer(seq(1:nPartitions)*chainLength/nPartitions)
  rowStart = c(1, rowStop[1:nPartitions-1]+1)
  
  A0 = matrix(0, nrow=nStates, ncol=nPartitions)
  #A1 and A2 can be matrixes of vectors if the observation is multidimensional
  A1 = matrix(0, nrow=nStates, ncol=nPartitions)
  A2 = matrix(0, nrow=nStates, ncol=nPartitions)
  
  
  clusters <- stats::kmeans(dataFrame$outputs, nStates)
  centers <- clusters$centers
  startStdDevs <- sqrt(clusters$withinss/clusters$size)

  respStartParams <- vector()
  for(i in 1:nStates){
    respStartParams <- c(respStartParams, centers[i], startStdDevs[i])
  }
  for (i in 1:nPartitions){
    rows <- vector()
    nTimes <- vector()
    for (j in 1:(nPartitions)){
      if (j != i){
        rows <- c(rows, rowStart[j]:rowStop[j])
        nTimes <- c(nTimes, rowStop[j] - rowStart[j] + 1)
      }
    }
    df <- dataFrame[rows,]
    #fit the model for nPartitions -1 partitions
    mod <- depmixS4::depmix(outputs ~ 1, data = df, nstates=nStates, family = stats::gaussian(), ntimes=nTimes, respstart = respStartParams) # use gaussian() for normally distributed data
    fittedmod<-mod
    fittedmod <- depmixS4::fit(mod)
    #save the means of the states for ordering them
    stateMeans <- numeric(nStates)

    for (j in 1:nStates){
      stateMeans[j] <- fittedmod@response[[j]][[1]]@parameters$coefficients[[1]]
    }
    #determine the occupancy probabilities using the remaining partition
    rows <- c(rowStart[i]:rowStop[i])
    nTimes <- c(rowStop[i]-rowStart[i]+1)
    dfLikelihood <- dataFrame[rows,]
    modViterbi <- depmixS4::depmix(outputs~1, data=dfLikelihood, nstates=nStates, ntimes=nTimes, family = stats::gaussian())
    modViterbi <- depmixS4::setpars(modViterbi, depmixS4::getpars(fittedmod))
    viterbiStateProbs <- depmixS4::viterbi(modViterbi)
    # the state with the lowest mean is ordered first in As
    # This is to get a consistent ordering across folds
    meanRanks <- rank(stateMeans)
    for (j in 1:nStates){
      A0[meanRanks[j], i] <- A0[meanRanks[j], i] + sum(viterbiStateProbs[, j+1])
      A1[meanRanks[j], i] <- A1[meanRanks[j], i] + sum(viterbiStateProbs[, j+1]*dfLikelihood$outputs)
      A2[meanRanks[j], i] <- A2[meanRanks[j], i] + sum(viterbiStateProbs[, j+1]*(dfLikelihood$outputs^2))
    }
  }
  return(list(A0, A1, A2))
}


CalcLikelihoodCluster <- function(sufficientStatistics, statesInCluster, nPartitions){
  meanML <- numeric(nPartitions)
  varML <- numeric(nPartitions)
  A0 <- sufficientStatistics[[1]]
  A1 <- sufficientStatistics[[2]]
  A2 <- sufficientStatistics[[3]]

  for (i in 1:nPartitions){
    sumA0 <- 0
    #sumA1 and sumA2 will be vectors if observations are multidim
    sumA1 <- 0
    sumA2 <- 0
    for (j in 1:(nPartitions)){
      if (j != i){
        sumA0 <- sumA0 + sum(A0[statesInCluster, j])
        sumA1 <- sumA1 + sum(A1[statesInCluster, j])
        sumA2 <- sumA2 + sum(A2[statesInCluster, j])
      }
    }
    meanML[i] = sumA1/ sumA0
    varML[i] = sumA2/ sumA0 - meanML[i]^2
  }
  likelihoodPartitions <- numeric(nPartitions)
  for (i in 1:nPartitions){
    for (j in statesInCluster){
      # note, this is for 1-dim observations
      term1 = log(2* pi* varML[i]) * A0[j, i]
      term2 = A2[j, i]/ varML[i]
      term3 = - 2*meanML[i]*A1[j, i]/ varML[i]
      term4 = meanML[i]^2*A0[j, i]/ varML[i]
      likelihoodPartitions[i] = likelihoodPartitions[i] - 0.5*(term1 + term2 + term3 + term4)
    }
  }
  return(sum(likelihoodPartitions))
}

CalcMeanCluster <- function(sufficientStatistics, statesInCluster, nPartitions){
  A0 <- sufficientStatistics[[1]]
  A1 <- sufficientStatistics[[2]]
  sumA0 <- 0
  #sumA1 and sumA2 will be vectors if observations are multidim
  sumA1 <- 0
  for (j in 1:(nPartitions)){
      sumA0 <- sumA0 + sum(A0[statesInCluster, j])
      sumA1 <- sumA1 + sum(A1[statesInCluster, j])
  }
  mean = sumA1/ sumA0
  return(mean)
}

CalcStdDevCluster <- function(sufficientStatistics, statesInCluster, mean, nPartitions){
  A0 <- sufficientStatistics[[1]]
  A2 <- sufficientStatistics[[3]]
  
  sumA0 <- 0
  #sumA1 and sumA2 will be vectors if observations are multidim
  sumA2 <- 0
  for (j in 1:(nPartitions)){
    sumA0 <- sumA0 + sum(A0[statesInCluster, j])
    sumA2 <- sumA2 + sum(A2[statesInCluster, j])
  }
  stdDev = sqrt(sumA2/ sumA0 - mean^2)
  return(stdDev)
}



GetSplitStatesMeansStddevsCluster <- function(sufficientStatistics, states, nPartitions){
  # if only two states are left, we split them without applying kMeans
  if (length(states) == 2){
    return(list(c(states[1]), c(states[2])))
  }
  # we use the means, A1/A0, for k-means clustering with k=2
  meansStdDevs <- matrix(nrow=length(states), ncol=2)
  for (i in 1:length(states)){
    meansStdDevs[i, 1]<- 
      CalcMeanCluster(sufficientStatistics, c(states[i]), nPartitions)
    meansStdDevs[i, 2]<- 
      CalcStdDevCluster(sufficientStatistics, c(states[i]), meansStdDevs[i, 1], nPartitions)
  }
  statesLeftChild <- vector()
  statesRightChild <- vector()
  clusters <- stats::kmeans(meansStdDevs, 2, nstart=5)
  cl <- clusters$cluster
  for (i in 1:length(states)){
    if (cl[i] == 1){
      statesLeftChild <- c(statesLeftChild, states[i])
    } 
    else{
      statesRightChild <- c(statesRightChild, states[i])
    }
  }
  return(list(statesLeftChild, statesRightChild, rank(meansStdDevs[,2])))
}



CalcLikelihoodTree <- function(sufficientStatistics, tree, nPartitions){
  # assign likelihood to all tree nodes
  # all states are in the leaves, so only calculate for these
  tree$Do(function(node) node$likelihood <- CalcLikelihoodCluster(sufficientStatistics, node$states, nPartitions), filterFun = data.tree::isLeaf)
  tree$Do(function(node) node$likelihood <- data.tree::Aggregate(node, attribute = "likelihood", aggFun = sum), traversal = "post-order")
  return(tree$likelihood)
}

TestSplitNodeLikelihood <- function(sufficientStatistics, node, nPartitions){
  # if only two states are left, we split them without applying kMeans
  newNode <- data.tree::Node$new(name="subTreeRoot", states=vector())
  nStatesInCluster <- length(node$states)
  
  leftChild <- newNode$AddChild("left", states=node$states[1])
  rightChild <- newNode$AddChild("right", states=node$states[2:nStatesInCluster])
  node$leftStates=leftChild$states
  node$rightStates=rightChild$states
  
  CalcLikelihoodTree(sufficientStatistics, newNode, nPartitions)
  if (nStatesInCluster == 2){
    return(newNode)
  }
  testLikelihood <- newNode$likelihood
  
  # check possible split as clustering in 2-D with means and stddevs
  clustersStddevRank <- GetSplitStatesMeansStddevsCluster(sufficientStatistics, node$states, nPartitions)
  testNode <- data.tree::Node$new(name="subTreeRoot", states=vector())
  leftChild <- testNode$AddChild("left", states=clustersStddevRank[[1]])
  rightChild <- testNode$AddChild("right", states=clustersStddevRank[[2]])
  tl <- CalcLikelihoodTree(sufficientStatistics, testNode, nPartitions)
  if (tl > testLikelihood){
    newNode <- testNode
    testLikelihood <- tl
    node$leftStates=leftChild$states
    node$rightStates=rightChild$states
  }
  #check to split anywhere along means
  for (split in 2:(nStatesInCluster-1)){
    testNode <- data.tree::Node$new(name="subTreeRoot", states=vector())
    leftChild <- testNode$AddChild("left", states=node$states[1:split])
    rightChild <- testNode$AddChild("right", states=node$states[(split+1):nStatesInCluster])
    tl <- CalcLikelihoodTree(sufficientStatistics, testNode, nPartitions)
    if (tl > testLikelihood){
      newNode <- testNode
      testLikelihood <- tl
      node$leftStates=leftChild$states
      node$rightStates=rightChild$states
    }
  }
  #check to split anywhere along stddevs
  stddevRank <- clustersStddevRank[[3]]
  for (split in 1:(nStatesInCluster-1)){
    testNode <- data.tree::Node$new(name="subTreeRoot", states=vector())
    leftChild <- testNode$AddChild("left", states=node$states[stddevRank[1:split]])
    rightChild <- testNode$AddChild("right", states=node$states[stddevRank[(split+1):nStatesInCluster]])
    tl <- CalcLikelihoodTree(sufficientStatistics, testNode, nPartitions)
    if (tl > testLikelihood){
      newNode <- testNode
      testLikelihood <- tl
      node$leftStates=leftChild$states
      node$rightStates=rightChild$states
    }
  }
  return(newNode)
}

SplitNodeIfAdvantage<- function(sufficientStatistics, node, nPartitions){
  if (node$advantage < 1E-5){
    return()
  }
  node$states <- vector()
  leftChild <- node$AddChild("left", states=node$leftStates)
  rightChild <- node$AddChild("right", states=node$rightStates)
}

CalcSplitAdvantage <- function(sufficientStatistics, node, nPartitions){
  # cannot split if only one state in cluster 
  if (length(node$states) < 2){
    return(-1)
  }
  splitNode <- TestSplitNodeLikelihood(sufficientStatistics, node, nPartitions)
  advantage = splitNode$likelihood - node$likelihood
  return(advantage)
}

export("CrossValidationLikelihoodsAndClusteredTree")
CrossValidationLikelihoodsAndClusteredTree <- function(dataFrame, nStates, nPartitions=4, partitionsStop = integer()){
  if(length(partitionsStop) == 0){
    chainLength <- length(dataFrame$outputs)
    partitionsStop <- as.integer(seq(1:nPartitions)*chainLength/nPartitions)
  }
  tree <- data.tree::Node$new(name="test", states=seq(1,nStates))
  likelihoodsNCluster <- numeric(nStates)
  try({
    sufficientStats <- EstimateCalcSufficientStatistics(dataFrame, nStates, nPartitions, partitionsStop)
    likelihood <- CalcLikelihoodTree(sufficientStats, tree, nPartitions)
    # calculate the advantage of splitting each leaf
    tree$Do(function(node) node$advantage <- CalcSplitAdvantage(sufficientStats, node, nPartitions), filterFun = data.tree::isLeaf)
    tree$Do(function(node) node$advantage <- data.tree::Aggregate(node, attribute = "advantage", aggFun = max), traversal = "post-order")
    likelihoodsNCluster[1] <- likelihood
    nClusters <- 1
    while ((tree$advantage > 0) && (tree$leafCount < nStates)){
      tree$Do(function(node) SplitNodeIfAdvantage(sufficientStats, node, nPartitions), filterFun = data.tree::isLeaf)
      likelihood <- CalcLikelihoodTree(sufficientStats, tree, nPartitions)
      likelihoodsNCluster[(nClusters+1):tree$leafCount] <- likelihood
      nClusters <- tree$leafCount
      tree$Do(function(node) node$advantage <- CalcSplitAdvantage(sufficientStats, node, nPartitions), filterFun = data.tree::isLeaf)
      tree$Do(function(node) node$advantage <- data.tree::Aggregate(node, attribute = "advantage", aggFun = max), traversal = "post-order")
    }
    # calculate the mean for each leaf cluster
    tree$Do(function(node) node$mean <- CalcMeanCluster(sufficientStats, node$states, nPartitions), filterFun = data.tree::isLeaf)
    tree$Do(function(node) node$stdDev <- CalcStdDevCluster(sufficientStats, node$states, node$mean, nPartitions), filterFun = data.tree::isLeaf)
  })
  likelihoodsNCluster<- likelihoodsNCluster[1:tree$leafCount]
  return(list(likelihoodsNCluster, tree))
}

export("FitMarkovChainFromClusteredTree")
FitMarkovChainFromClusteredTree <- function(dataFrame, tree){
  nStates <- tree$leafCount
  treeAsDF <- data.tree::ToDataFrameTree(tree, "mean", "stdDev", filterFun = data.tree::isLeaf)
  respStartParams <- vector()
  print(treeAsDF)
  print(treeAsDF["mean"])
  for(i in 1:nStates){
    respStartParams <- c(respStartParams, treeAsDF[i, "mean"], treeAsDF[i, "stdDev"])
  }
  mod <- depmixS4::depmix(outputs ~ 1, data = dataFrame, nstates=nStates, family = stats::gaussian(), respstart = respStartParams) # use gaussian() for normally distributed data
  fittedmod<-mod
  tryCatch(fittedmod <- depmixS4::fit(mod), 
           error=function(cond) {
             message(paste("depmixS4::fit caused an error"))
             message("Here's the original warning message:")
             message(cond)
             # Choose a return value in case of error
             return(NULL)
           }, 
           warning=function(cond) {
             message(paste("depmixS4::fit caused a warning"))
             message("Here's the original warning message:")
             message(cond)
             # Choose a return value in case of warning
             return(NULL)
           })
  return(fittedmod)
}
