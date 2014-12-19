#!/bin/bash

if [ -f /tmp/second_on.lock ]; then
	xrandr --output HDMI1 --off
	rm /tmp/second_on.lock
else
	xrandr --auto --output HDMI1 --mode 1680x1050 --above eDP1
	touch /tmp/second_on.lock
fi
