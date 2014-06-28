#!/usr/bin/env python

import sys

def main():
    ages = age_map()
    gndrs = gndr_dict()
    incs = inc_dict()

    # Read all lines from stdin
    for line in sys.stdin:
        in_fields = line.strip().split('\t')
        icd9 = get_field(in_fields, 'procedure_code')
        if icd9 != 'NULL' and icd9 != '\\N':
            compute_features(in_fields)
            
            val_fields = []
            val_fields.append(icd9)

            key_fields = []
            key_fields.append(get_field(in_fields, 'patient_id'))
            key_fields.append(str(ages[get_field(in_fields, 'age')]))
            key_fields.append(str(gndrs[get_field(in_fields, 'gndr')]))
            key_fields.append(str(incs[get_field(in_fields, 'inc')]))
            key_fields.append(get_field(in_fields, 'label'))

            key = ':'.join(key_fields)

            print "%s\t%s" % (key, ':'.join(val_fields))

def compute_features(in_fields):
    # Month might be a useful predictor
    claim_month = in_fields[field_keys['claim_date']][4:6]
    in_fields.append(claim_month)

def get_field(in_fields, key):
    return in_fields[field_keys[key]]

def age_map():
    mapping = dict()
    mapping['\\N'] = 0
    mapping['NULL'] = 0
    mapping['<65'] = 1
    mapping['65-74'] = 2
    mapping['75-84'] = 3
    mapping['85+'] = 4
    return mapping

def gndr_dict():
    mapping = dict()
    mapping['M'] = 1
    mapping['F'] = 2
    return mapping

def inc_dict():
    mapping = dict()
    mapping['\\N'] = 0
    mapping['NULL'] = 0
    mapping['<16000'] = 1
    mapping['16000-23999'] = 2
    mapping['24000-31999'] = 3
    mapping['32000-47999'] = 4
    mapping['48000+'] = 5
    return mapping

field_keys = {
    # Input
    'patient_id': 0,
    'age': 1,
    'gndr': 2,
    'inc': 3,
    'claim_date': 4,
    'procedure_code': 5,
    'avg_charge': 6,
    'var_charge': 7,
    'avg_payment': 8,
    'var_payment': 9,
    'total_services': 10,
    'label': 11,
    # Computed
    'claim_month': 12
}

if __name__ == '__main__':
    main()