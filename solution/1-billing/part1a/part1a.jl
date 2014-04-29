#! /usr/bin/env julia

# Which three procedures have the highest relative variance in cost?

# Depends: Julia 0.2.1

# Install if necessary
#Pkg.add("DataFrames")
#Pkg.add("Cairo")
#Pkg.add("Gadfly")

using Gadfly
using DataFrames
using Base.Order

# Load the cleaned data
cwd = dirname(@__FILE__)
df = readtable(cwd * "/../.tmp/provider_charge.csv")

# Visualise the distributions
drgplot = plot(df, x = :IPC9, y = :Average_Total_Payments, Geom.point, Scale.x_discrete)
draw(PNG(cwd * "/plots/Procedure_Cost_Gadfly.png", 12inch, 4inch), drgplot)

# Compute the variance by IPC9 code
variance = by(df, :IPC9, df -> DataFrame(Variance = var(df[:Average_Total_Payments])))

# Get the top 3 codes
sortby!(variance, :Variance, Order.Reverse)
top3 = DataFrame(variance[1:3,:IPC9])

writetable("part1a.csv", top3, header = false)
