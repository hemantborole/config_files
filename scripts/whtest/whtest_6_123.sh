c=_chacha
ts=`date +%d%b%y`
for i in 1 2 3
do
log="/mnt/whtest_logs/log${c}_${i}"
mkdir $log
~/scripts/whtest.py --mode=stream --list=/tmp/audio.list --num-threads="$i"  'http://ves2.wc1.yellowpages.com:9999/smm/watson?imei=hemant&grammar=chacha&resultFormat=json&metrics=1&audioFormat=au' --hist=cpu_vs_audio --hist=frames --trace-level=debug --report=$log/rpt${ts}.txt --verbose  1>>$log/whtest.log 2> $log/whtest.err
done

