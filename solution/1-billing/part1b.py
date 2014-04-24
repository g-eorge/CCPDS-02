#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys

nlines = 0
procedures = {}
counts = {}


# Find the provider that charged the most for each procedure
for line in sys.stdin:

  (proc_type, ipc9, procedure, provider_id, hrr, service_count, charges, payments) = line.split("\t")

  if ipc9 not in procedures:
    procedures[ipc9] = { 'max_charge': 0 }

  charges = float(charges)

  if charges > procedures[ipc9]['max_charge']:
    procedures[ipc9]['max_charge'] = charges
    procedures[ipc9]['provider_id'] = provider_id

  nlines = nlines + 1

# Order by max_charge desc
top_charges = sorted(procedures.items(), key=lambda t: t[1]['max_charge'], reverse=True)

# Count by provider
for k, v in map(lambda x: (x[1]['provider_id'], 1), top_charges):
  if k in counts:
    counts[k] = counts[k] + v
  else:
    counts[k] = v

# Order by count
counts = sorted(counts.items(), key=lambda t: t[1], reverse=True)

# List the top 3
for k, v in counts[0:3]:
  sys.stdout.write("%s\n" % k)