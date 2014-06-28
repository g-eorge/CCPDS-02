# Plot the purity of each clustering as defined here:
#   http://nlp.stanford.edu/IR-book/html/htmledition/evaluation-of-clustering-1.html

library(ggplot2)

dataDir <- "../../data/sample"

cls <- c(wssse = "numeric", purity = "numeric")
df <- read.csv(paste(dataDir, "/cluster-fold0.csv", sep=""), colClasses = cls)
fold1 <- read.csv(paste(dataDir, "/cluster-fold1.csv", sep=""), colClasses = cls)

colnames(df) <- c("k", "wssse", "fold0.purity")
df$fold1.purity <- fold1$purity

ggplot(df) + 
  geom_line(aes(x=k, y=fold0.purity, color="Fold 0")) +
  geom_point(aes(x=k, y=fold0.purity, color="Fold 0")) +
  geom_line(aes(x=k, y=fold1.purity, color="Fold 1")) +
  geom_point(aes(x=k, y=fold1.purity, color="Fold 1")) +
  geom_smooth(aes(x=k, y=(fold0.purity + fold1.purity)/2)) +
  ylab("test set purity") + theme(legend.title=element_blank())

ggsave(file = "plots/cluster-purity.png", width = 8, height = 5, dpi = 300)
