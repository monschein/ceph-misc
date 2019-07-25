#!/usr/bin/env python
import json
import sys
import os

# Generate JSON file with volume information
os.system("rbd -p block-volumes ls -l --format json > /tmp/volstats.json")
# Load JSON File
bsVolumes = json.load(open('/tmp/volstats.json'))
bsTotal = sum(s['size'] for s in bsVolumes)
print("node_ceph_ls_sum_bytes{pool=\"block-volumes\"} %s") % (bsTotal)
