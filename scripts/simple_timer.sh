#!/bin/bash

out=/tmp/out
rm -rf ${out}
mkdir -p $out
total_requests=1
i=0

this_path=$(readlink -f $0)        ## Path of this file including filename
dir_name=`dirname ${this_path}`    ## Dir where this file is
myname=`basename ${this_path}`     ## file name of this script.
logger="${myname}.log"
interval='0.2'

function logit {
  if [[ $quiet == "true" ]]
  then
    echo $1 1>> $logger
  else
    echo $1 |tee -a $logger
  fi
}


function usage {
  echo "
  usage: ${myname} [options] <filename>

  -h           optional  Print this help message
  -q           optional  Suppress log messages on screen, just log them.
  -f <file>    required  file containing list of files that will be the
               post body to the curl requests
  -l <log>     optional  print errors and output to this file.
               default ${myname}.log
  -i <interl>  optional  Interval between 2 requests in seconds.
               default 0.2
  -o <outdir>  optional  store curl output to this directory.
               default is /tmp/out"
  exit 1
}


function invoke_url	{
	logit "using input $input, req number $i"
	bn=`basename "${input}"|cut -d'.' -f1`
	curl -i --header 'Transfer-Encoding: Chunked' --data-binary @${input} "http://12.175.178.26:8000/asr?imei=hemant&grammar=speak4it&resultFormat=json&audioFormat=amr" -o ${out}/result${bn}.out
}





function main {

	start=`date +%s`
	for input in `cat $filelist`
	do
		(( i = $i + 1 ))
		invoke_url &
		sleep ${interval}
	done
	wait
	end=`date +%s`


	total_requests=$i
	total_time=`echo "( ${end} - ${start} )"|bc -l`

	avg=`echo "${total_time}/${total_requests}"|bc -l`

	avg2=`grep "clockTime" ${out}/result*|sed 's/.*clockTime\":\(.*\),"sharedDirty".*/\1/g'| awk 'BEGIN { sum=0; count=0 } { sum+=$0; count+=1 } END { printf("total_time = %4.4f, num_req = %d, avg = %4.4f",sum, count, sum/count) }'`

	logit "Curl Stats: total_time = ${total_time}, num_req = ${total_requests}, avg = ${avg}"
	logit "ClockTime Stats: ${avg2}"

}


while getopts :hqf:l:i: args
do
  case $args in
  h) usage ;;
  q) quiet='true' ;; ## Suppress messages, just log them.
  f) filelist="${OPTARG}" ;; ## File containing list of files
  l) logger="$OPTARG" ;;
	i) interval="${OPTARG}" ;; ## Interval between 2 requests in seconds.
  o) out="${OPTARG}" ;;
  :) logit "The argument -$args requires a parameter"; exit 1 ;;
  *) usage ;;
  esac
done

if [[ ! -r $filelist ]]
then
	echo ""
	logit "$filelist does not exist or is not readable!"
	usage
fi

if [[ ! -z $out ]]
then
	if [[ ! -w $out ]]
	then
		logit "outdir [-o] is not writable. Using default ${out}"
	fi
fi

main "$@"
