#!/bin/bash
find $HOME/irclogs -type f|xargs grep -i '17:35 <Aniruddh>'|awk '{print $NF}'
