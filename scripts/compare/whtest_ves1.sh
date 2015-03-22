c=_chacha_ves1
ts=`date +%d%b%y`
for i in 3
do
log="/mnt/whtest_logs/compare/log${c}_${i}"
mkdir -p $log
~/scripts/whtest.py --mode=stream --list=./audio.list --num-threads="$i"  'http://irvsrdves3.flight.yellowpages.com:6565/asr?imei=hemant&grammar=business.search.lm&audioFormat=au' --hist=cpu_vs_audio --hist=frames --trace-level=debug --report=$log/rpt${ts}.txt --verbose  1>>$log/whtest.log 2> $log/whtest.err
done

