#!/bin/bash
#set -x

OSD_ID=$1

OSD_DEVICE=$(mount | grep /var/lib/ceph/osd/ceph-$OSD_ID | awk '{print $1}' | tr -d [0-9])

echo "DEBUG: OSD Device is $OSD_DEVICE"
echo "DEBUG: BEGIN -- Current Time is $(date)"

echo "-- Setting OSD# $OSD_ID Out..."
ceph osd out $OSD_ID

echo "-- Waiting for cluster to rebalance OSD# $OSD_ID..."
while ! ceph osd safe-to-destroy $OSD_ID; do
    sleep 60
done

echo "-- Killing OSD process for OSD# $OSD_ID..."
systemctl kill ceph-osd@$OSD_ID
sleep 10

echo "-- Unmounting OSD# $OSD_ID Device $OSD_DEVICE..."
umount /var/lib/ceph/osd/ceph-$OSD_ID
sleep 10

echo "-- Zapping OSD# $OSD_ID Device $OSD_DEVICE..."
ceph-disk zap $OSD_DEVICE
sleep 10

echo "-- Destroying OSD# $OSD_DEVICE..."
ceph osd destroy $OSD_ID --yes-i-really-mean-it
sleep 10

echo "-- Preparing OSD# $OSD_ID for Bluestore..."
ceph-disk prepare --bluestore $OSD_DEVICE --osd-id $OSD_ID --block.db /dev/nvme0n1 --block.wal /dev/nvme0n1
sleep 60

echo "Finished re-provisioning $OSD_ID"


while ! ceph health | grep HEALTH_OK; do
    echo "Data is rebalancing. Waiting for Ceph Health to Return OK..."
    sleep 600;
done

echo "DEBUG: END -- Current Time is $(date)"

echo "Ceph Cluster healthy! Exiting."


