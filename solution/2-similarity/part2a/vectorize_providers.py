#!/usr/bin/python
# -*- coding: utf-8 -*-

# Some providers and regions are likely to be different in more subtle ways. Based on the data provided,
# which three providers are least like the others? Briefly explain what seems to be different about these providers.
#
# This tool transforms the procedure data into dense row vectors of features for each provider.
#
# For each provider row vector it outputs the columns:
#   provider id
#   drg count                   - the number of drg type procedures the provider has carried out
#   apc count                   - the number of apc type procedures the provider has carried out
#   For each procedure:
#     procedure service count   - the number of services provided by this provider for procedure x
#     procedure charges         - the charges for procedure x for this provider or NA if the provider doesn't provide the procedure
#     procedure payments        - the payments for procedure x for this provider or NA if the provider doesn't provide the procedure
#

import sys

providers = dict()
uniq_procs = set()


def proc_dict(icd9, service_count, charges, payments):
  return {"icd9": icd9, "service_count": service_count, "charges": charges, "payments": payments}

# Convert the sparse vector of procedures to a dense vector
def sparse_to_dense_procs(sparse_procs):
  dense_procs = dict()
  for proc in uniq_procs:
    dense_procs[proc] = proc_dict(proc, 0, "NA", "NA")
    if proc in sparse_procs:
      dense_procs[proc] = sparse_procs[proc]
  # Sort on the code so that every vector is always in the same order
  return map(lambda x: x[1], sorted(dense_procs.items(), key=lambda t: t[1]['icd9'], reverse=True))

def dense_matrix(regions):
  m = []
  i = 0
  for provider_id, val in providers.items():
    procedures = sparse_to_dense_procs(val["procedures"])
    m.append([ provider_id, val["drg_count"], val["apc_count"] ])
    for proc in procedures:
      m[i].append(proc["service_count"])
      m[i].append(proc["charges"])
      m[i].append(proc["payments"])
    i += 1
  return m

for line in sys.stdin:
  (proc_type, icd9, procedure, provider_id, provider_city, provider_state, region, service_count, charges, payments) = line.strip().split("\t")

  # Collect all the unique codes so we can make a dense feature vector
  uniq_procs.add(icd9)

  if provider_id not in providers:
    providers[provider_id] = {"city": provider_city, "state": provider_state, "region": region, "procedures": {}, "service_total": 0, "drg_count": 0, "apc_count": 0}

  # Record the provider procedure
  providers[provider_id]["procedures"][icd9] = proc_dict(icd9, service_count, charges, payments)
  # Keep a track of the total services the provider has
  providers[provider_id]["service_total"] += int(service_count)

  if proc_type == "DRG":
    providers[provider_id]["drg_count"] += 1
  elif proc_type == "APC":
    providers[provider_id]["apc_count"] += 1

m = dense_matrix(providers)

# Output a dense vector for every provider
for row in m:
  i = 0
  for col in row:
    if i > 0:
      sys.stdout.write("\t")
    sys.stdout.write(str(col))
    i += 1
  sys.stdout.write("\n")