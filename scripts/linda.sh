#!/bin/bash
curl "http://rservices.wc1.yellowpages.com/v1/listing_by_id?q=465408861" 2>/dev/null| /home/hborole/scripts/pp.rb| grep -i coupontitle > /tmp/lindas_coupons.txt

c1=`grep -c "BUYER REBATES! FREE HOME INSPECTION AND MORE!" /tmp/lindas_coupons.txt`
c2=`grep -c "REMODEL YOUR KITCHEN WITH GRANITE TRANSFORMATION! ADD VALUE & SELL FASTER! PAY AT CLOSING!" /tmp/lindas_coupons.txt`
c3=`grep -c 'SELL YOUR HOME FOR $1995 WITH FULL SERVICE! WHY PAY MORE!' /tmp/lindas_coupons.txt`

if [ $c1 -ne 2 -a $c2 -ne 1 -a $c3 -ne 1 ];then
  echo "Linda's coupon missing"
  echo "Linda's coupons are missing. Refer DS-7098" | /usr/bin/mail -s "Lindas coupons missing **PAGER**" hborole@atti.com
fi
