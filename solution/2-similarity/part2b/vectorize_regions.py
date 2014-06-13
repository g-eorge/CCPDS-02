#!/usr/bin/python
# -*- coding: utf-8 -*-

# Which three regions are least like the others? Briefly explain what seems to be different about these regions.
#
# This tool transforms the procedure data into dense row vectors of features for each region.
#
# For each region row vector it outputs the columns:
#   region id
#   provider count        - the number of providers in the region
#   apc count             - the number of apc type procedures providers in the region carried out
#   drg count             - the number of drg type procedures providers in the region carried out
#   For each procedure:
#     count               - the number of providers in the region providing this procedure
#     service count       - the total number of services provided for this procedure in the region
#     charges             - the average charges for this procedure in the region or NA
#     payments            - the average payments for this procedure in the region or NA
#

import sys

regions = dict()
uniq_procs = set()

def proc_dict(icd9, count, service_count, avg_charge, avg_payment):
  return {"icd9": icd9, "count": count, "service_count": service_count, "avg_charge": avg_charge, "avg_payment": avg_payment}

# Convert the sparse vector of procedures to a dense vector
def sparse_to_dense_procs(sparse_procs):
  dense_procs = dict()
  for proc in uniq_procs:
    dense_procs[proc] = proc_dict(proc, 0, 0, "NA", "NA")
    if proc in sparse_procs:
      dense_procs[proc] = sparse_procs[proc]
  # Sort on the code so that every vector is always in the same order
  return map(lambda x: x[1], sorted(dense_procs.items(), key=lambda t: t[1]['icd9'], reverse=True))

def update_avg(new_datum, current_avg, num_datums):
  return (new_datum + (num_datums * current_avg)) / (num_datums + 1)

def dense_matrix(regions):
  m = []
  i = 0
  for region, val in regions.items():
    procedures = sparse_to_dense_procs(val["procedures"])
    m.append([ region, len(val["providers"]), val["apc_count"], val["drg_count"] ])
    for proc in procedures:
      m[i].append(proc["count"])
      m[i].append(proc["service_count"])
      m[i].append(proc["avg_charge"])
      m[i].append(proc["avg_payment"])
    i += 1
  return m

for line in sys.stdin:
  (proc_type, icd9, procedure, provider_id, provider_city, provider_state, region, service_count, charges, payments) = line.strip().split("\t")
  charges = float(charges)
  payments = float(payments)
  service_count = int(service_count)

  # Collect all the unique codes so we can make a dense feature vector
  uniq_procs.add(icd9)

  if region not in regions:
    regions[region] = { "procedures": {}, "providers": set(), "service_total": 0, "apc_count": 0, "drg_count": 0 }

  # Add provider to the region set
  regions[region]["providers"].add(provider_id)
  # Keep track of the total services the region provided
  regions[region]["service_total"] += service_count

  if proc_type == "DRG":
    regions[region]["drg_count"] += 1
  elif proc_type == "APC":
    regions[region]["apc_count"] += 1

  if icd9 not in regions[region]["procedures"]:
    # Add the procedure to the region
    regions[region]["procedures"][icd9] = proc_dict(icd9, 1, service_count, charges, payments)
  else:
    # Update the averages for the procedure
    current = regions[region]["procedures"][icd9]
    avg_charge = update_avg(charges, current["avg_charge"], current["count"])
    avg_payment = update_avg(charges, current["avg_payment"], current["count"])
    updated = proc_dict(icd9, current["count"] + 1, current["service_count"] + service_count, avg_charge, avg_payment)
    regions[region]["procedures"][icd9] = updated


m = dense_matrix(regions)

for row in m:
  i = 0
  for col in row:
    if i > 0:
      sys.stdout.write("\t")
    sys.stdout.write(str(col))
    i += 1
  sys.stdout.write("\n")