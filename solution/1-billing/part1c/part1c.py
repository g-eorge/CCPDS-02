#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys

regions = {}
max_charges = {}
counts = {}

# Find the average charge for each procedure by region
for line in sys.stdin:
  (proc_type, ipc9, procedure, provider_id, region, service_count, charges, payments) = line.split("\t")
  charges = float(charges)

  # code-state-city
  key = "%s-%s" % (ipc9, region)

  if key not in regions:
    regions[key] = { 'avg_charge': 0, 'provider_count': 0 }

  # Update cumulative moving average
  regions[key]['avg_charge'] = charges + (regions[key]['provider_count'] * regions[key]['avg_charge']) / (regions[key]['provider_count'] + 1)
  regions[key]['provider_count'] = regions[key]['provider_count'] + 1


# Find the regions that charged the most for the procedures
for key, val in regions.items():
  # sys.stdout.write(key + "\n")
  (ipc9, region) = key.split("-", 1)
  if ipc9 not in max_charges:
    max_charges[ipc9] = { 'max_charge': 0 }

  if regions[key]['avg_charge'] > max_charges[ipc9]['max_charge']:
    max_charges[ipc9]['max_charge'] = regions[key]['avg_charge']
    max_charges[ipc9]['region'] = region

# sys.stdout.write(str(len(max_charges)))

for k, v in max_charges.items():
  # sys.stdout.write("%s\t%s\t%s\n" % (k, v['region'], v['max_charge']))
  if v['region'] not in counts:
    counts[v['region']] = 1
  else:
    counts[v['region']] = counts[v['region']] + 1

for k, v in sorted(counts.items(), key=lambda t: t[1], reverse=True)[0:3]:
  # sys.stdout.write("%s\t%s\n" % (k, v))
  (state, city) = k.split('-', 1)
  sys.stdout.write("%s,%s\n" % (city.strip(), state.strip()))
