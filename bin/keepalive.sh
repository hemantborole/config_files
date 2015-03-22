#!/bin/bash

## For some reason wireless keeps dropping, if there is no network activity
## Hence this script to force network activity

# Allow network connection to established
sleep 10
cd /tmp
nohup ping -i 3 www.google.com >/dev/null 2>&1 &
