#!/usr/bin/env python

import sys

def main():
    last = None
    procedures = unique_procedures()

    # Read all the lines from stdin
    for line in sys.stdin:
        id, str = line.strip().split('\t', 1)

        if id != last:
            if last != None:
                dump(last, claims, procedures)

            last = id
            claims = None

        claims = claim(claims, str)

    dump(last, claims, procedures)

def dump(id, claims, procedures):
    vec = "%s,%s" % (','.join(id.split(':')), ','.join(dense_claims(claims, procedures)))
    print vec.strip()

def claim(claims, new):
    if claims:
        if new not in claims:
            claims[new] = 1
        else:
            claims[new] += 1
    else:
        claims = { new: 1 }

    return claims

def dense_claims(claims, procedures):
    vec = []
    for icd9 in procedures:
        if icd9 in claims:
            vec.append(str(claims[icd9]))
        else:
            vec.append(str(0))
    return vec

def unique_procedures():
    # From a hive query over all claims
    procedures = ["0012","0013","0015","0019","0020","0073","0074","0078","0096","0203","0204","0206","0207","0209","0265","0267","0269","0270","0336","0368","0369","0377","039","057","0604","0605","0606","0607","0608","064","065","066","069","0690","0692","0698","074","101","149","176","177","178","189","190","191","192","193","194","195","202","203","207","208","238","243","244","246","247","249","251","252","253","254","280","281","282","286","287","291","292","293","300","301","303","305","308","309","310","312","313","314","315","329","330","372","377","378","379","389","390","391","392","394","418","419","439","460","469","470","473","480","481","482","491","536","552","563","602","603","638","640","641","682","683","684","689","690","698","699","811","812","853","870","871","872","885","897","917","918","948"]
    return sorted(procedures)

if __name__ == '__main__':
    main()