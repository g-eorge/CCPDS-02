#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys,re

quoted = re.compile('^(.+),(.+),"(.+)",(.+),(.+),(.+),(.+),(.+),(.+),(.+)$')
unquoted = re.compile('^(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)$')

def to_tsv(matches):
  return "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % matches.groups()

for line in sys.stdin:
  match = quoted.match(line) or unquoted.match(line)

  if match:
    sys.stdout.write(to_tsv(match) + "\n")