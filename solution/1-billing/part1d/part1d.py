#!/usr/bin/python
# -*- coding: utf-8 -*-

# Which three providers had the largest claim difference for the largest number of procedures, 
# where the claim difference is the difference between the average amount claimed by a provider 
# for a procedure and the average amount reimbursed for that provider and procedure.
# 
# To clarify, consider the following example. If out of two providers, if Provider A has the largest 
# claim difference for procedures 1 and 2, and Provider B has the largest claim difference for procedure 3, 
# then Provider A has the largest claim difference for the larger number of procedures (2 versus 1).

import sys

procedures = {}
counts = {}

# Find the provider that had the largest claim difference for each procedure
for line in sys.stdin:
  (proc_type, ipc9, procedure, provider_id, region, service_count, charges, payments) = line.split("\t")
  charges = float(charges)
  payments = float(payments)

  if ipc9 not in procedures:
    procedures[ipc9] = { 'max_diff': 0 }

  if charges - payments > procedures[ipc9]['max_diff']:
    procedures[ipc9]['max_diff'] = charges - payments
    procedures[ipc9]['provider_id'] = provider_id

# Count by provider
for k, v in map(lambda x: (x[1]['provider_id'], 1), procedures.items()):
  if k in counts:
    counts[k] = counts[k] + v
  else:
    counts[k] = v

# Order by count
counts = sorted(counts.items(), key=lambda t: t[1], reverse=True)

# for k, v in counts:
#   sys.stdout.write("%s\t%s\n" % (k, str(v)))

# List the top 3
for k, v in counts[0:3]:
  sys.stdout.write("%s\n" % k)