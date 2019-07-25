#!/usr/bin/env python
import json
import sys
import os
import math

def convert_size(size_bytes):
   if size_bytes == 0:
       return "0B"
   size_name = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
   i = int(math.floor(math.log(size_bytes, 1024)))
   p = math.pow(1024, i)
   s = round(size_bytes / p, 2)
   return "%s %s" % (s, size_name[i])

# Generate JSON file with volume information
print('Generating volume list...')
os.system("rbd -p block-volumes ls -l --format json > /tmp/volstats.json")
print('Volume list created at /tmp/volstats.json')

# Load JSON File
bsVolumes = json.load(open('/tmp/volstats.json'))

print('Calculating total size of all volumes...')
bsTotal = sum(s['size'] for s in bsVolumes)

print('Total size is: {} bytes'.format(bsTotal))

print('Converting sum total to human readable output...')

print('Total size in human readable form: {}'.format(convert_size(bsTotal)))

