# Plot the purity of each clustering as defined here:
#   http://nlp.stanford.edu/IR-book/html/htmledition/evaluation-of-clustering-1.html

library(ggplot2)

dataDir <- "../../data/sample/cluster"
hdfs <- "/part-00000"

cls <- c(wssse = "numeric", purity = "numeric")
df <- read.csv(paste(dataDir, "/cluster-scores.csv", hdfs, sep=""), colClasses = cls)

ggplot(df) + 
  geom_line(aes(x=k, y=purity)) +
  geom_point(aes(x=k, y=purity)) +
  geom_smooth(aes(x=k, y=purity)) +
  ylab("test set purity") + theme(legend.title=element_blank())

ggsave(file = "plots/cluster-purity.png", width = 8, height = 5, dpi = 300)
