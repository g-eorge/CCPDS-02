# Draw an elbow plot to help work out the best number of clusters

library(ggplot2)

dataDir <- "../../data/sample"

# Read in the within set sums of squared errors for both folds
cls <- c(wssse = "numeric", purity = "numeric")
df <- read.csv(paste(dataDir, "/cluster-fold0.csv", sep=""), colClasses = cls)
fold1 <- read.csv(paste(dataDir, "/cluster-fold1.csv", sep=""), colClasses = cls)

# Merge the scores for plotting
colnames(df) <- c("k", "fold0.wssse", "purity")
df$fold1.wssse <- fold1$wssse

# Plot the elbow curve
ggplot(df) + 
  geom_line(aes(x=k, y=fold0.wssse, color="Fold 0")) +
  geom_point(aes(x=k, y=fold0.wssse, color="Fold 0")) +
  geom_line(aes(x=k, y=fold1.wssse, color="Fold 1")) +
  geom_point(aes(x=k, y=fold1.wssse, color="Fold 1")) +
  geom_smooth(aes(x=k, y=(fold0.wssse + fold1.wssse)/2)) +
  ylab("wssse") + theme(legend.title=element_blank())

ggsave(file = "plots/cluster-elbow.png", width = 8, height = 5, dpi = 300)
