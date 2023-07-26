#!/bin/bash

# The backup partition is mounted there

{{#if (eq (command_output "hostname") "Main-pc\n")}}
MOUNTPOINT={{mountpoint}}
{{else}}
MOUNTPOINT=ssh://{{address}}:{{port}}{{mountpoint}}
{{/if}}

# This is the location of the Borg repository
TARGET=$MOUNTPOINT/{{target}}

#Passphrase
{{#if (eq (command_output "hostname") "Main-pc\n")}}
export BORG_PASSPHRASE="{{main_pass}}"
{{else}}
export BORG_PASSPHRASE="{{thinkpad_pass}}"
{{/if}}

DATE=$(date)

BACKUPS="{{backups}}"
SPACED=""

# Options for borg create
BORG_OPTS="--stats --progress"

PRUNE_OPTS="-d 1 -w 8 -m 6 -y 5"

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
