#bin/bash
[[ "-x" == "${1}" ]] && set -x && set -v && shift 1
count=1
for X in /sys/class/scsi_host/host?/scan
  do
  echo '- - -' > ${X}
done

for X in /dev/sd?
  do
  list+=$(echo $X " ")
  done

#for X in /dev/sd??
  #do
  #list+=$(echo $X " ")
  #done

for X in $list
  do
  echo "========"
  echo $X
  echo "========"
  BOOTFLAG=$(/sbin/parted -s ${X} print quit|/bin/grep -c boot)
  if [[ -b ${X} && $BOOTFLAG -ne 0 ]]
  then
    echo "$X bootable - skipping."
    continue
  else
    #Y=${X##*/}1
    echo "Formatting and Mounting Drive => ${X}"
    echo "Running Command: /sbin/mkfs.xfs -f ${X}"
    /sbin/mkfs.xfs -f ${X}
    (( $? )) && continue
    #Identify UUID
    echo "Identifying UUID by running blkid ${X} for device ${X}"
    UUID=$(blkid $X | cut -c17-52)
    #UUID=`blkid ${X} | cut -d " " -f2 | cut -d "=" -f2 | sed 's/"//g'`
    echo "Making directory by running /bin/mkdir -p /data/disk${count}"
    /bin/mkdir -p /data/disk${count}
    (( $? )) && continue
    #echo "UUID of ${X} = ${UUID}, mounting ${X} using UUID on /data/disk${count}"
    #/bin/mount -t xfs -o inode64,noatime,nobarrier -U ${UUID}/data/disk${count}
    #(( $? )) && continue
    echo "Making entry in /etc/fstab as UUID=${UUID} /data/disk${count} xfs inode64,noatime,nobarrier 0 0"
    echo "UUID=${UUID} /data/disk${count} xfs inode64,noatime,nobarrier 0 0" >> /etc/fstab
    (( $? )) && continue
    echo "UUID of ${X} = ${UUID}, mounting ${X} using UUID on /data/disk${count} by running /bin/mount -a" 
    /bin/mount -a
    ((count++))
  fi
done
