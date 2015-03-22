#!/bin/bash


## Base dir pointing to whtest logs. Expected to containing directories
## by the name log_*

log_base=/mnt/whtest_logs/

## formatted display
function display {
  echo "$1"
}

## Calculate average time of a value which sits in a
## json string that starts with $1 and ends with $2
function _time {
  hmm=$1
  hmm2=$2
  avg=`grep "${hmm}" ${log_dir}/rpt*.txt |sed "s/${hmm}\(.*\)${hmm2}.*/\1/g"|awk 'BEGIN {sum=0.0; count=0}
  {
    sum+=$0
    count+=1
  }
  END {
    printf("%4.4f",sum/count)
  }'`
  echo $avg
}

function main {
  display '-------------------------------------'
  display 'threads | latency |   clk   |  cpu   |'
  display '-------------------------------------'
  ls -d ${log_base}/log_*|sort -n -t'_' -k 4|while read i
  do
    threads=`basename $i|awk -F'_' '{print $3}'`
    latency=`grep 'Avg:' $i/whtest.log|awk '{print $2}'`
    log_dir=${i}
    clk=`_time '.*clockTime": ' ', "shared.*'`
    cpu=`_time '.*cpuTime": ' ', "start.*'`
    results=`echo -e "${results[@]}\n$threads $latency $clk $cpu"`
    echo "after $results"
  done
  echo "Array Results are ${results[@]}"
  echo "Results are $results"
  echo ${results}|awk -F'|' '{printf("%5s   |  %-7s| %-7s | %-7s|\n",$1,$2,$3,$4)}'
  display '-------------------------------------'
}

main $@
