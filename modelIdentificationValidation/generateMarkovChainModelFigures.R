library(ggplot2)

inputFiles = list("input/simpleMarkovTimesTrain.csv")
figuresDir = "output/simpleMarkovTest/"
resultsDir = list("output/simpleMarkovTest/")
fontSize=20

scaledNorm <- function(x, m, stddev, scale) {return(scale * dnorm(x, mean=m, sd=stddev))}

for(i in 1:length(inputFiles))
{
  dataFrame <- read.csv(inputFiles[[i]])
  chainLength <- length(dataFrame$executionTime)
  dataFrame$index = seq(1, chainLength)
  figureSeqFilePng <- paste(figuresDir, "executionTimeSeq", i, ".png", sep="")
  figureSeqFileEps <- paste(figuresDir, "executionTimeSeq", i, ".eps", sep="")
  ggplot(dataFrame, aes(x=index, y=executionTime)) +
    geom_point() + 
    ylim(20000, 70000) + theme(text = element_text(size = fontSize))
  ggsave(figureSeqFilePng)
  ggsave(figureSeqFileEps)
  figureHistFilePng <- paste(figuresDir, "executionTimeHist", i, ".png", sep="")
  figureHistFileEps <- paste(figuresDir, "executionTimeHist", i, ".eps", sep="")
  ggplot(dataFrame, aes(x=executionTime, y=..density..)) +
    geom_histogram(binwidth = 100, fill="cadetblue") +
    xlim(20000, 70000) + theme(text = element_text(size = fontSize))
  ggsave(figureHistFilePng)
  ggsave(figureHistFileEps)
  
  modelIndices <- c(1, 4, 6, 9)
  for (j in modelIndices){
    figureHistModelFilePng <- paste(figuresDir, "simpleMarkov", i, "Model", j, ".png", sep="")
    figureHistModelFileEps <- paste(figuresDir, "simpleMarkov", i, "Model", j, ".eps", sep="")
    normalParamsFile <- paste(resultsDir[[i]], "normalParams", j, ".txt", sep="")
    normalParams <-  read.table(file=normalParamsFile)
    stationaryDistrFile <- paste(resultsDir[[i]], "stationaryDistr", j, ".txt", sep="")
    stationaryDistr <- read.table(file=stationaryDistrFile)
    print(stationaryDistr)
    gg <- ggplot(dataFrame, aes(x=executionTime)) +
      geom_histogram(binwidth = 100, fill="cadetblue", aes(y=..density.., fill=..count..)) +
      xlim(20000, 70000) + theme(text = element_text(size = fontSize))

    for (k in 1:nrow(normalParams)){
      print(stationaryDistr[k, 1] * 2) 
      gg <- gg + stat_function(fun=scaledNorm, color="black",
                               args=list(m=normalParams[k, 1], stddev=normalParams[k, 2], scale=as.numeric(stationaryDistr[k, 1])))+
        geom_vline(xintercept=normalParams[k, 1])
      
    }
    
    ggsave(figureHistModelFilePng)
    ggsave(figureHistModelFileEps)
    
  }

}

