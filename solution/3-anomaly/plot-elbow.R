# Draw an elbow plot to help work out the best number of clusters

library(ggplot2)

dataDir <- "../../data/cluster-metrics"
hdfs <- "/part-00000"

# Read in the within set sums of squared errors for both folds
cls <- c(wssse = "numeric", purity = "numeric")
df <- read.csv(paste(dataDir, "/cluster-scores.csv", hdfs, sep=""), colClasses = cls)

# Plot the elbow curve
ggplot(df) + 
  geom_line(aes(x=k, y=wssse)) +
  geom_point(aes(x=k, y=wssse)) +
  geom_smooth(aes(x=k, y=wssse)) +
  ylab("wssse") + theme(legend.title=element_blank())

ggsave(file = "plots/cluster-elbow.png", width = 8, height = 5, dpi = 300)
