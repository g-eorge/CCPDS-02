# Plot each cluster k as a stacked bar plot showing the number of
# suspicious points vs the unknown points in the cluster. This helps
# give an idea if the suspicious points are being clustered together.
# Note that this does not necessarily tell us anything about the 
# quality of the clustering.

library(reshape2)
library(grid)
library(ggplot2)

dataDir <- "../../data/cluster-metrics"
hdfs <- "/part-00000"

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

# Draw a plot for k
drawPlot <- function(df,k) {
  df2 <- melt(df)
  label <- factor(rep(0:1,length=nrow(df2)))
  df2 <- cbind(df2, label)
  p <- ggplot(df2[3:nrow(df2),], aes(x = variable, y = value, fill = label)) + 
    geom_bar(stat = "identity") + 
    xlab("cluster") + 
    ylab("points") +
    labs(title=paste("k =", k))
  return(p)
}

# Output the plot as a PDF
outputFile <- paste("plots/confusion-", from, "to", to, "by", by, ".pdf", sep="")
pdf(outputFile, width=cols*plotWidth, height=rows*plotHeight)
grid.newpage()
pushViewport(viewport(layout = grid.layout(rows, cols)))
vplayout <- function(x, y)
  viewport(layout.pos.row = x, layout.pos.col = y)

# Draw each plot on to the grid
row_idx <- 0
col_idx <- 0
for (k in steps) {
  file <- paste(dataDir, "/confusion-k", k, ".csv", hdfs, sep="")
  df <- read.csv(file)
  p <- drawPlot(df,k)
  print(p, vp = vplayout(row_idx + 1, col_idx + 1))
  col_idx <- col_idx + 1
  if (col_idx %% cols == 0) {
    row_idx <- row_idx + 1
    col_idx <- 0
  }
}

dev.off()

