#!/bin/bash

sudo openconnect --pid-file /tmp/vpn.pid -b -u hborole --authgroup='duo' https://vpn.yp.com/ 
