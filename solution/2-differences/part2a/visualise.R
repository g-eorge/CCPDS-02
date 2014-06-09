#! /usr/bin/env Rscript

# Dependencies
# install.packages("ggplot2")
# install.packages("reshape")

# Load packages
library(ggplot2)
library(reshape)

# The providers that are least like the others
provider_ids <- c('50195', '390180', '50441')

# Plot colours for the providers
scale_colours <- c()
scale_colours[[provider_ids[1]]] <- '#1AA794'
scale_colours[[provider_ids[2]]] <- '#F5435D'
scale_colours[[provider_ids[3]]] <- '#A532FF'

# Plot shapes for the procedures
scale_shapes <- c()
scale_shapes[[provider_ids[1]]] <- 15
scale_shapes[[provider_ids[2]]] <- 16
scale_shapes[[provider_ids[3]]] <- 17

numcols = 392 # The number of columns the vectorizer produced - 1
cls <- c("character", rep("numeric",numcols))
# Read in the data file
df <- read.csv("vector_providers.txt", header=F, stringsAsFactors=F, colClasses=cls, row.names=1, sep="\t", na.strings="NA")


## Plot number of procedures types each provider carries out (DRG, APC, Total)
counts <- df[,1:2] # Subset the procedure type count columns
colnames(counts) <- c("drg_count", "apc_count")
counts$total_count <- counts$drg_count + counts$apc_count # Compute a total column
# Use a Z scale for easier comparison
scaled_counts <- data.frame(scale(counts, center=T, scale=T))
# Pick out the providers we are interested in
compare_counts <- scaled_counts[provider_ids,]
compare_counts$id <- provider_ids
# Build the plot with a box plot for comparison
p <- ggplot(data = melt(scaled_counts), aes(x=variable, y=value))
p + geom_boxplot(alpha=0.4, size=0.5, color="grey") + 
  geom_point(aes(colour=provider_ids[1], shape=provider_ids[1]), data=melt(compare_counts[1,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[2], shape=provider_ids[2]), data=melt(compare_counts[2,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[3], shape=provider_ids[3]), data=melt(compare_counts[3,], id.vars='id')) +
  scale_colour_manual(name="Provider", values=scale_colours) + scale_shape_manual(name="Provider", values=scale_shapes) +
  xlab("procedure type counts") + ylab("z-score")
# Output the plot to a file
ggsave(file = "exploring/plots/procedure_type_counts.png", width = 11, height = 8, dpi = 300)


## Plot the number of services each provider carries out for each procedure
counts <- df[,seq(3,ncol(df),3)] # Subset the service count column for each procedure
# Use a Z scale for easier comparison
scaled_counts <- data.frame(scale(counts, center=T, scale=T))
# Pick out the providers we are interested in
compare_counts <- scaled_counts[provider_ids,]
compare_counts$id <- provider_ids
# Build the plot
p <- ggplot(data = melt(scaled_counts), aes(x=variable, y=value))
p + geom_point(aes(colour=provider_ids[1], shape=provider_ids[1]), data=melt(compare_counts[1,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[2], shape=provider_ids[2]), data=melt(compare_counts[2,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[3], shape=provider_ids[3]), data=melt(compare_counts[3,], id.vars='id')) +
  scale_colour_manual(name="Provider", values=scale_colours) + scale_shape_manual(name="Provider", values=scale_shapes) +
  xlab("procedure service counts") + ylab("z-score") +
  theme(axis.text.x = element_blank())
# Output the plot to a file
ggsave(file = "exploring/plots/service_counts.png", width = 11, height = 8, dpi = 300)


## Plot the charges for procedures each provider carries out
counts <- df[,c(seq(4,ncol(df),3))] # Subset the charges columns for each procedure
# Use a Z scale for easier comparison
scaled_counts <- data.frame(scale(counts, center=T, scale=T))
# Pick out the providers we are interested in
compare_counts <- scaled_counts[provider_ids,]
compare_counts$id <- provider_ids
# Build the plot
p <- ggplot(data = melt(scaled_counts), aes(x=variable, y=value))
p + geom_point(aes(colour=provider_ids[1], shape=provider_ids[1]), data=melt(compare_counts[1,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[2], shape=provider_ids[2]), data=melt(compare_counts[2,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[3], shape=provider_ids[3]), data=melt(compare_counts[3,], id.vars='id')) +
  scale_colour_manual(name="Provider", values=scale_colours) + scale_shape_manual(name="Provider", values=scale_shapes) +
  xlab("procedure charges") + ylab("z-score") +
  theme(axis.text.x = element_blank())
# Output the plot to a file
ggsave(file = "exploring/plots/charges.png", width = 11, height = 8, dpi = 300)


## Plot the payments for procedures each provider carries out
counts <- df[,c(seq(5,ncol(df),3))] # Subset the payments columns for each procedure
# Use a Z scale for easier comparison
scaled_counts <- data.frame(scale(counts, center=T, scale=T))
# Pick out the providers we are interested in
compare_counts <- scaled_counts[provider_ids,]
compare_counts$id <- provider_ids
# Build the plot
p <- ggplot(data = melt(scaled_counts), aes(x=variable, y=value))
p + geom_point(aes(colour=provider_ids[1], shape=provider_ids[1]), data=melt(compare_counts[1,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[2], shape=provider_ids[2]), data=melt(compare_counts[2,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[3], shape=provider_ids[3]), data=melt(compare_counts[3,], id.vars='id')) +
  scale_colour_manual(name="Provider", values=scale_colours) + scale_shape_manual(name="Provider", values=scale_shapes) +
  xlab("procedure payments") + ylab("z-score") +
  theme(axis.text.x = element_blank())
# Output the plot to a file
ggsave(file = "exploring/plots/payments.png", width = 11, height = 8, dpi = 300)


## Plot everything in one plot
scaled_all <- data.frame(scale(df, center=T, scale=T))
# Pick out the providers we are interested in
compare_counts <- scaled_all[provider_ids,]
compare_counts$id <- provider_ids
# Build the plot
p <- ggplot(data = melt(scaled_all), aes(x=variable, y=value))
p + geom_point(color='#202020', size=1, alpha=0.2) +
  geom_point(aes(colour=provider_ids[1], shape=provider_ids[1]), data=melt(compare_counts[1,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[2], shape=provider_ids[2]), data=melt(compare_counts[2,], id.vars='id')) + 
  geom_point(aes(colour=provider_ids[3], shape=provider_ids[3]), data=melt(compare_counts[3,], id.vars='id')) +
  scale_colour_manual(name="Provider", values=scale_colours) + scale_shape_manual(name="Provider", values=scale_shapes) +
  xlab("procedure counts, service counts, charges and payments") + ylab("z-score") +
  theme(axis.text.x = element_blank())
# Output the plot to a file
ggsave(file = "exploring/plots/all.png", width = 11, height = 8, dpi = 300)
