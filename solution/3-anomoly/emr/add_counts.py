#!/usr/bin/env python

import sys

def main():
    for line in sys.stdin:
        fields = line.strip().split(',')
        procs = to_int(fields[5:])
        num_procs = sum(procs)
        out_fields = fields[:5]
        out_fields.append(num_procs)
        print ','.join(to_str(out_fields + procs))

def to_int(list):
    return map(lambda x: int(x), list)

def to_str(list):
    return map(lambda x: str(x), list)

if __name__ == '__main__':
    main()