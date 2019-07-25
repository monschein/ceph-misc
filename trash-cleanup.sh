#!/bin/bash
#set -x

echo "+ [$(date)] " >> /srv/trashed-vols.log
echo "+ Beginning Trash Cleanup..." >> /srv/trashed-vols.log

# Gather list of volumes that are in the trash
/usr/bin/rbd -p block-volumes trash ls | awk '{print $1}' > /srv/cleanup-list.txt

# Begin cleanup - iterate over cleanup list
for vol in $(cat /srv/cleanup-list.txt); do
	echo "Trashing Volume: $vol ..." >> /srv/trashed-vols.log
	/usr/bin/rbd -p block-volumes trash rm $vol
	echo "Finished Trashing Volume: $vol" >> /srv/trashed-vols.log
	sleep 10
done

echo "+ [$(date)] " >> /srv/trashed-vols.log
echo "+ Finished Trash Cleanup!" >> /srv/trashed-vols.log
