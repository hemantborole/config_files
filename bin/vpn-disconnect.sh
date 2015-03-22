#!/bin/bash

pid=`cat /tmp/vpn.pid`
sudo kill -SIGINT $pid
