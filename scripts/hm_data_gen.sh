#!/bin/bash
this_path=$(readlink -f $0) ## Path of this file including filename
dir_name=`dirname ${this_path}` ## Dir where this file is
myname=`basename ${this_path}` ## file name of this script.
logger="${myname}.log"

function usage {
  echo "
  usage:  $myname [options]

  -h                    Print this help message
  -m  <metric>          Metric column
  -d  <date(YYYYMMDD)>  Mysql frontend date for which to generate the metric
  -f  <free|paid|all>   free/paid flag
  -c  <category>        Category code.
  -o  [outdir]          optional store output here.
                        default is <category>/<metric>"
  exit 1
}

function logit {
  if [[ $quiet == "true" ]]; then
    echo $1 1>> $logger
  else
    echo $1 |tee -a $logger
  fi
  if test "$2" == "true"; then
    usage
  fi
}

logit "Initializing `date`"

## Start coding from here. Some basic flags are already provide. Feel free to override, add, delete
while getopts :hm:d:f:c:o: args
do
  case $args in
  h) usage ;;
  m) metric="$OPTARG" ;; ## Suppress messages, just log them.
  d) day="$OPTARG" ;;
  f) fp="$OPTARG" ;;
  c) category="$OPTARG" ;;
  o) outdir="$OPTARG" ;;
  *) usage ;;
  esac
done

## Do parameter validations here.
## Below is an example.

function input {
  if test -z $metric; then
    logit "Metric is required parameter" true
  fi

  if test -z $day; then
    logit "date (YYYYMMDD) is required parameter" true
  fi

  if test -z $category; then
    logit "category code is required parameter" true
  fi

  if test -z $outdir; then
    out_dir="${category}/${metric}"
  fi
  out_str=`echo "${out_dir}"|sed 's?/?_?g'`

  mkdir -p "${out_dir}"
  if [[ $? -ne 0 ]]; then
    echo "Could not create output directory"
    usage
  fi
  logger="${out_dir}/${myname}.log"

  case $fp in
    [aA][lL][lL])
      fp=""
      ;;
    [fF][rR][eE][eE])
      fp="F"
      ;;
    [pP][aA][iI][dD])
      fp="P"
      ;;
    *)
      logit "Free paid flag must be one of [free|paid|all]" true
      usage
      ;;
  esac
}

## Put your main code here.
function main {
  input
  qry="select concat(aggregate,'|', ${metric}) from aggregate_metrics where BINARY aggregate like \"${fp}Q|%\" and ds = $day ;"
  echo $qry > /tmp/${out_str}
  logit "$qry"
  /usr/bin/mysql -u datadash datadash_development < /tmp/${out_str} > ${out_dir}/${day}_1.out
  if test -s ${out_dir}/${day}_1.out; then
    awk -F'|' '{print $2","$3","$5}' ${out_dir}/${day}_1.out > ${out_dir}/${day}.out
  else
    logit "No data to process for ${out_str}" true
  fi
  ${dir_name}/heatmaps/scripts/createMap.pl ${dir_name}/heatmaps/templates/USA_Counties_large.svg ${out_dir}/${day}.out > ${out_dir}/${day}.svg
}
## Boot strap the script. Nothing much to do here.
main "$@"

#select aggregate, count_appearances from aggregate_metrics where BINARY aggregate like 'PQ|%' and ds = 20100621 ;

