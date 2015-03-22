channels=8000
ts=`date +%d%b%y`
grammar=speak4it
short_target=irvsrdves3
target="${short_target}.flight.yellowpages.com:8000"

for i in 2
do
log="/mnt/${short_target}/$grammar/log_${channels}_${i}_${ts}"
mkdir -p $log
~/scripts/whtest.py --mode=stream --list=/tmp/audio.list --num-threads="$i"  "http://${target}/asr?imei=hemant&appid=com.atti.speak4it.2.0&context=business&resultFormat=json&audioFormat=amr" --hist=cpu_vs_audio --hist=frames --trace-level=debug --report=$log/rpt${ts}.txt --verbose  1>>$log/whtest.log 2> $log/whtest.err
done

