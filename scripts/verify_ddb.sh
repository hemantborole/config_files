#!/bin/bash
yesterday=
if test -z ${1}; then
  day=`date -d yesterday +%Y%m%d`
else
  day=$1
fi

sql="select\
  aggregate, listing_count, associations_nulls, heading_code_nulls,\
  mip_score_avg, oad_flag_count, payment_text_nulls,\
  dfp0, dfp5, count_appearances\
  from aggregate_metrics\
  where ds=20101130;"
#  where ds=${day};"

echo "${sql}" > /tmp/verify.sql

for host in np197.wc1.yellowpages.com datadash-stage.np.ev1.yellowpages.com; do
  short=`echo "${host}"|cut -f1 -d.`
  scp /tmp/verify.sql "${host}":/tmp/.
  ssh "${host}" "/usr/bin/mysql -u datadash datadash_development < /tmp/verify.sql 1>/tmp/verify.out 2>&1"
  scp "${host}":/tmp/verify.out /tmp/verify_${short}.out
done

diff /tmp/verify_*.out 1>/tmp/verify.diff

if test $? -ne 0; then
  echo "Manually verify the diff"
else
  echo "Regression looks good"
fi

