#!/bin/bash
http_code=`curl -I 'http://datadash.wc1.yellowpages.com:3072/health.txt' 2>/dev/null |grep '^HTTP' |awk '{print $2}'`
if test "${http_code}" != "200"; then
  for emails in hborole@atti.com akim@atti.com; do
    echo "The dashboard UI in production is perhaps down, Attempting to self-heal" | mutt -s "**DATADash UI Alert!!!**" "${emails}"
  done
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  rvm use 1.8.7
  cd $HOME/projects/ds/dui && cap deploy:restart -S deploy_env=production
else
  echo "The dashboard is up and kicking...." > /dev/null
fi

#http_code=`curl -I 'http://dashboardprod.np.wc1.yellowpages.com:3072/health.txt' 2>/dev/null |grep '^HTTP' |awk '{print $2}'`
#if test "${http_code}" != "200"; then
#  for emails in hborole@atti.com akim@atti.com; do
#    echo "The NEW dashboard UI in production is perhaps down" | mutt -s "** NEW DATADash UI Alert!!!**" "${emails}"
#  done
#else
#  echo "The new dashboard is up and kicking...." > /dev/null
#fi
