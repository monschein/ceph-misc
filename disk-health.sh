#!/bin/bash
#set -x

# Set issue counter. 0 = OK, 1 = WARN, 2 = CRIT
issueCounter=0

function show_help(){
  echo "Usage:"
  echo -e "\t./disk-health -d [# of expected disks]"
}

OPTIND=1
while getopts "h?d:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    d)
        expectedDisks=${OPTARG}
        ;;
    esac
done

shift $((OPTIND-1))

# Set storcli path
storclibin="/usr/local/bin/storcli"

# Set smartctl path
smartctlbin="/usr/sbin/smartctl"

# Verify we have storcli
if ! [ -e "$storclibin" ]
then
  echo "WARNING - StorCli Not Found"
  exit 1
fi

# Verify we have smartmontools installed
if ! [ -e "$smartctlbin" ]
then
  echo "WARNING - smartctl Not Found"
  exit 1
fi

# Storcli takes a long time to return, so let's
# send storcli output to a text file so we can quickly search it
$storclibin /c0 show > /tmp/storcli-temp.txt

# Check number of disks presently attached to the HBA controller
numDisks=$(grep "Physical Drives" /tmp/storcli-temp.txt | awk '{print $4}')

# Set the number of disks we expect to be in the chassis
#expectedDisks=12

# First let's check if there are any missing disks
# This can be due to a bad HBA controller, SAS backplane, or bad cabling
if [[ $numDisks -ne $expectedDisks ]]; then
  let issueCounter++
  myCounter=0
  missingDisks=0
  declare -a missingArray
  # Since slots start at 0, take one away from total # of disks to assign slot count
  expectedSlots=expectedDisks-1

  # Let's find out which slot is missing a disk
  while [[ $myCounter -le $expectedSlots ]]; do
    mySlot=$(grep -c "^ :$myCounter" /tmp/storcli-temp.txt)

    if [[ $mySlot -eq 0 ]]; then
      let missingDisks++
      missingArray+=("[Slot: $myCounter] ")
    fi

    let myCounter++

  done
 
  slotStatus="$missingDisks missing drives ${missingArray[@]}"
else
  slotStatus="All drives present"
fi


# Look at smart disk stats
myDevices=$(lsscsi | awk '{print $NF}')
badDisks=0
declare -a badArray
for i in $myDevices; do
  diskHealth=$($smartctlbin -a $i | grep "SMART overall-health self-assessment test result" | awk '{print $NF}')
  if [[ $diskHealth == "FAILED" ]]; then
    let issueCounter++
    let badDisks++
    #echo "Disk $i failed SMART health self-assessment test"
    badArray+=("[Disk: $i]")
  fi
done

if [[ $badDisks -eq 0 ]]; then
  smartStatus="All disks are healthy"
else
  smartStatus="$badDisks bad disks: ${badArray[@]}"
fi

if [[ $issueCounter -eq 0 ]]; then
  echo -e "OK - $slotStatus | $smartStatus"
  exit 0
else
  echo -e "WARNING - $slotStatus | $smartStatus"
  exit 1
fi
