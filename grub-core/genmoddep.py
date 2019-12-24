#!/usr/bin/env python

import sys


SYMBOL_TABLE={}
MODULE_TABLE={}
for line in sys.stdin.readlines():
    if not line:
        break
    is_defined, module, symbol = line.split()
    if is_defined == "defined":
        SYMBOL_TABLE["symbol"]
    elif is_defined == "undefined":
        pass
    else:
        pass
