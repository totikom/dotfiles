#!/bin/bash

# The backup partition is mounted there

MOUNTPOINT="/mnt/Backup"

# This is the location of the Borg repository
TARGET=$MOUNTPOINT/Main-pc

#Passphrase
export BORG_PASSPHRASE="{{main_pc_offline_pass}}"

PRUNE_OPTS="-d 1 -w 8 -m 6 -y 5"

DATE=$(date)

BACKUPS="/dev/sda /mnt/Media/Books /mnt/Media/cloud_archive /mnt/Media/Pictures"
SPACED=""

# Options for borg create
BORG_OPTS="--stats --progress --read-special"

# Log Borg version
borg --version

if [ -n "$1"  ]; then
	# Prune
	echo 'Prunning:'
	borg prune -v --list --stats $PRUNE_OPTS $TARGET
	borg compact --verbose --progress $TARGET
  else
	#
	# Create backups
	#

	echo "Starting backup for $DATE"

	borg create $BORG_OPTS \
		$TARGET::{now} \
		$BACKUPS \
		--exclude-from /home/eugene/.borg/exclusions

	echo "Completed backup for $DATE"

	echo 'Backups to prune:'
	borg prune -v --list --dry-run $PRUNE_OPTS $TARGET
fi

# Just to be completely paranoid
sync
