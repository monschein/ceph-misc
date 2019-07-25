#!/bin/bash
echo "$(date)" >> /srv/daily-count.txt
echo "Number of volumes today: $(rbd -p block-volumes ls | wc -l)" >> /srv/daily-count.txt
echo "Cluster usage: $(/srv/sum-volume-size.py | grep "human readable form" | awk '{print $7,$8}')" >> /srv/daily-count.txt

