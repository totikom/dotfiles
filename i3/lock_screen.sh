#!/bin/bash

# Only exported variables can be used within the timer's command.
export PRIMARY_DISPLAY="DVI-0"

xidlehook \
	`# Don't lock when there's a fullscreen application` \
	--not-when-fullscreen \
	`# Don't lock when there's audio playing` \
	--not-when-audio \
	`# Dim the screen after 300 seconds, undim if user becomes active` \
	--timer 300 \
	'xrandr --output "$PRIMARY_DISPLAY" --brightness .5' \
	'xrandr --output "$PRIMARY_DISPLAY" --brightness 1' \
	`# Undim & lock after 300 more seconds` \
	--timer 300 \
	'xrandr --output "$PRIMARY_DISPLAY" --brightness 1; betterlockscreen -l dim --off 30' \
	'' \
	`# Finally, suspend an hour after it locks` \
	#--timer 3600 \
	#'systemctl suspend' \
	#''
