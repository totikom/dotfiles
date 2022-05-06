#!/bin/bash

# The backup partition is mounted there
MOUNTPOINT={{mountpoint}}

# This is the location of the Borg repository
TARGET=$MOUNTPOINT/{{target}}

#Passphrase
export BORG_PASSCOMMAND="secret-tool lookup borg-repository $TARGET"

DATE=$(date)

BACKUPS="{{backups}}"
SPACED=""

#
# Create backups
#

# Options for borg create
BORG_OPTS="--stats --progress"

# Log Borg version
borg --version

echo "Starting backup for $DATE"

borg create $BORG_OPTS \
	$TARGET::{now} \
	$BACKUPS \
	--exclude-from /home/eugene/.borg/exclusions

echo "Completed backup for $DATE"

# Prune

PRUNE_OPTS="-d 7 -w 5 -m 6 -y 2"

if [ -n "$1"  ]; then
	echo 'Prunning:'
	borg prune -v --list --stats $PRUNE_OPTS $TARGET
  else
	echo 'Backups to prune:'
	borg prune -v --list --dry-run $PRUNE_OPTS $TARGET
fi

# Just to be completely paranoid
sync
