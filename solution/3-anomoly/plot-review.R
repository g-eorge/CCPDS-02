# Plots the clusters where the majority of points are suspicious
# so we can examine the ratio of suspicious points to unknown (ranking).
# The higher the ratio, the better the chance that the unknown points
# are also suspicious. Note that this does not necessarily 
# tell us anything about the quality of the clustering.

library(grid)
library(ggplot2)

dataDir <- "../../data/sample"

# k runs we are interested in
from <- 2
to <- 20
by <- 1
steps <- seq(from, to, by=by)

# For simplicity only plot data from one fold
fold <- 0

# How many rows and cols on the plot grid
cols <- 4
rows <- ceiling(length(steps) / cols)

# Dimensions of the PDF plot
plotWidth <- 6
plotHeight <- 4

# Draw a stacked bar plot showing the clusterings where there are some
# clusters with more than half being suspicious
drawPlot <- function(df, k) {
  df$cid <- factor(df$cid)
  p <- ggplot(df) + 
    geom_bar(aes(x = cid, y = total, fill = "total"), stat = "identity") + 
    geom_bar(aes(x = cid, y = count, fill = "suspicious"), stat = "identity") +
    xlab("cluster id") + 
    ylab("points") +
    theme(legend.title=element_blank()) +
    labs(title=paste("k =", k))
  return(p)
}

# Computes a simple 'rank' for this clustering based on the 
# overall ratio of suspicious to unkown points
rank <- function(df, k) {
  return(c(k, 1 / nrow(df) * sum(df$count / df$total)))
}

# Output the review plots on a grid
outputFile <- paste("plots/review-", from, "to", to, "by", by, ".pdf", sep="")
pdf(outputFile, width=cols*plotWidth, height=rows*plotHeight)
grid.newpage()
pushViewport(viewport(layout = grid.layout(rows, cols)))
vplayout <- function(x, y)
  viewport(layout.pos.row = x, layout.pos.col = y)

row_idx <- 0
col_idx <- 0
ranking <- data.frame()

# Read the review data for each run of k and plot it on the grid
for (k in steps) {
  file <- paste(dataDir, "/review-k", k, "-fold", fold, ".csv", sep="")
  df <- read.csv(file)
  if (nrow(df) > 0) {
    p <- drawPlot(df, k)
    ranking <- rbind(ranking, rank(df,k))
    print(p, vp = vplayout(row_idx + 1, col_idx + 1))
    col_idx <- col_idx + 1
    if (col_idx %% cols == 0) {
      row_idx <- row_idx + 1
      col_idx <- 0
    }
  }
}

dev.off()

# Output the ranking plot
colnames(ranking) <- c("k", "rank")
ranking$k <- factor(ranking$k)
ggplot(ranking) + 
  geom_bar(aes(x = k, y = rank), stat = "identity") +
  xlab("k") + 
  ylab("rank") +
  theme(legend.title=element_blank())


ggsave(file=paste("plots/review-ranking-", from, "to", to, "by", by, ".png", sep=""), width = 8, height = 6, dpi = 300)
