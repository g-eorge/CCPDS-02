#! /usr/bin/env Rscript

# Which three procedures have the highest relative variance in cost?

# Dependencies
# install.packages("psych")
# install.packages("ggplot2")
# install.packages("reshape")
# install.packages("dplyr")

# Load packages
library(psych)
library(ggplot2)
library(reshape)
library(dplyr)

## Read in the data files
cls <- c(IPC9 = "character")
df <- read.csv("../.tmp/provider_charge.csv", header = T, stringsAsFactors = F, colClasses = cls)

# Plot DRGs
qplot(IPC9, Average_Total_Payments, data = subset(df, df$Type=="DRG"), geom = "point", alpha = I(0.1), xlab = "DRG Code", 
      ylab = "Average Total Payments") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=6))
ggsave(file = "plots/DRG_Procedure_Cost.png", width = 12, height = 6, dpi = 300)

# Plot APCs
qplot(IPC9, Average_Total_Payments, data = subset(df, df$Type=="APC"), geom = "point", alpha = I(0.1), xlab = "APC Code", 
      ylab = "Average Total Payments") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=6))
ggsave(file = "plots/APC_Procedure_Cost.png", width = 12, height = 6, dpi = 300)

# Compute the variance by IPC9 code
variance <- ddply(df, 'IPC9', function(x) c(Count=nrow(x), Variance=var(x$Average_Total_Payments)))

# Get the top 3 codes
sortedvariance <- arrange(variance, desc(Variance))
top3 <- as.character(sortedvariance[1:3,1])

write(t(top3), file = "part1a.csv" )
