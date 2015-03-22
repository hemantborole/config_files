#!/bin/bash
ts=`date +%m-%d-%y`
out_base="/home/ves/to_chacha"
out="${out_base}/${ts}"
chacha_credentials='chacha-int@ftp.research.att.com'
chacha_destination='.'
watson_home='/opt/watson/x86_64-linux-gcc4.1-py2.4'

function to_wav {
  #Convert $1 (ssw file) to $2(wav filename)
  #Place the output in a output directory $OUT
  ${watson_home}/bin/sswstrip $1 > /tmp/audio.ul     ## Convert to raw
  sox /tmp/audio.ul ${out}/$2                       ## Convert raw to wav
  rm -rf /tmp/audio.ul                              ## delete raw
}

mkdir -p $out

find ${watson_home}/logs -name audio.ssw|while read a
do
  filename=`echo $a|awk -F'/' '{printf("%s.wav",$(NF-2))}'`
  to_wav $a $filename
done

cur_dir=`pwd`
cd ${out_base}
host_id=`hostname -s`
tar_file="${ts}_${host_id}.tgz"
tar zcvf ${tar_file} ${ts}

scp ${tar_file} ${chacha_credentials}:${chacha_destination}
cd $cur_dir
