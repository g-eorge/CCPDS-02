#! /usr/bin/env julia

# ...?

# Depends: Julia 0.2.1

# Install if necessary
#Pkg.add("Distance")

using Distance
# using Base.Order

# Load the cleaned data
cwd = dirname(@__FILE__)

# Vector buffer keyed by provider id
m = Dict{String,Array{Float32}}()

# Calculate the similarity between each provider
function similarity(m::Dict{String,Array{Float32}})
  sim = Dict{String,Float64}()
  for (kx, vx) in m
    for (ky, vy) in m
      key = "$kx:$ky"
      sim[key] = euclidean(vx, vy)
      write(STDOUT, "$key\t$(sim[key])\n")
    end
  end
  return sim
end

# Convert dict to an array and sort the result by similarity
function rank(sim::Dict{String,Float64})
  a = map((x)->x, sim)
  sort!(a, by=(y)->y[1], rev=true)
  return a
end

# Read in each provider vector
for line in eachline(open(cwd * "/vector_providers.csv"))
  row = split(line, ",")
  key = string(row[1])
  vec = map((x) -> float32(x), row[2:])
  m[key] = vec
end

# Get the similarities
tic()
# sim = rank(similarity(m))
sim = similarity(m)
toc()

# println(sim)
