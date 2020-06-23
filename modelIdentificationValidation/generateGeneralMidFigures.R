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

ggsave("output/VideoExecutionTimeTestSeqLog.png")
ggsave("output/VideoExecutionTimeTestSeqLog.eps")



