#!/bin/bash

tail YELP_urls.csv| while read a;do
  u=`echo $a|awk -F',' '{print $NF}'`
  if [ "${u}x" == "x" ]; then
    echo "${a},"
  else
    redirect=`curl -sIL "$u" | grep Location|awk '{print$2}'`
    echo "${a},${redirect}"
  fi
done
