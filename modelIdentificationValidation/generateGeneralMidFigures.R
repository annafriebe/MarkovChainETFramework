library(ggplot2)

fontSize = 20


dataFrame <- read.csv("input/videoStateTimesTest.csv")

chainLength <- length(dataFrame$executionTime)
dataFrame$index = seq(1, chainLength)

ggplot(dataFrame, aes(x=index, y=executionTime)) +
  geom_point() + theme(text = element_text(size = fontSize)) + 
  scale_y_log10(limits = c(5000,30000000)) + annotation_logticks() +
  theme(
    # Remove panel border
    #panel.border = element_blank(),  
    # Remove panel grid lines
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    # Remove panel background
    panel.background = element_blank(),
    # Add axis line
    axis.line = element_line(colour = "grey")
  )

  #scale_y_continuous(trans='log2', limits = c(50000,30000000)) #+ ylim(50000, 30000000)
ggsave("output/VideoExecutionTimeTestSeqLog.png")
ggsave("output/VideoExecutionTimeTestSeqLog.eps")

ggplot(dataFrame, aes(x=executionTime)) +
  geom_histogram(binwidth = 1000) +
  xlim(0, 1000000) + theme(text = element_text(size = fontSize))
ggsave("output/VideoTestHist1000000.png")
ggsave("output/VideoTestHist1000000.eps")



