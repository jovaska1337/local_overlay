#!/bin/env python

import re
import sys
import pathlib

prefs = pathlib.Path(__file__).parent / "jovaska-default-prefs.js"

RE_PREF = re.compile(r'(//)?([a-z_]*pref)\(\s*\"([^"]+)\"\s*,\s*\s*(.*?)\);');

class Pref:

    def __init__(self, m):
        self.off = m.group(1) == "//"
        self.key = m.group(3)
        self.val = m.group(4)

    def __repr__(self):
        return f"{"//" if self.off else ""}pref(\"{self.key}\", {self.val});"

    def __str__(self):
        return self.__repr__()

def read_pref(path):
    head = []
    pref = {}
    with open(prefs) as fp:
        for line in fp:
            m = RE_PREF.match(line);
            if not m:
                if len(pref) < 1:
                    head.append(line)
                else:
                    print(f"INVALID '{line}'")
            else:
                tmp = Pref(m)
                pref[tmp.key] = tmp
    return (head, pref)

head, pref = read_pref(prefs)

for arg in sys.argv[1:]:
    _, tmp = read_pref(arg)
    for key in tmp:
        pref[key] = tmp[key]

with open(prefs, "w") as fp:
    for line in head:
        fp.write(line)
    for key in sorted(pref.keys()):
        fp.write(str(pref[key]))
        fp.write("\n")
