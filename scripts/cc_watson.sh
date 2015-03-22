#!/bin/bash
ts=`date +%d%b%y`
work_dir=/tmp/watson
export_dir=/tmp/$ts
svn_repo=trunk
from_git=tmp_git
logger=/tmp/cc_watson.log

function logit {
  if [[ $2 == 'q' ]]
  then
    echo $1 1>> $logger
  else
    echo $1 |tee -a $logger
  fi
}

if [ ! -d $work_dir ]
then
  mkdir -p $work_dir 2>/dev/null
fi
mkdir -p $export_dir 2>/dev/null
cd $work_dir

svn info $svn_repo 1>/dev/null 2>&1
is_svn=$?

if [[ $is_svn -ne 0 ]]
then
  logit "Watson svn does not exist, creating a new one."
  svn co http://watson.research.att.com/repos/watson/$svn_repo
else
  svn update $svn_repo
fi
rev=`svn info $svn_repo|awk  '$1 ~ /^Revision/ {print $2}'`
rm -rf ${export_dir}/$rev/ 2>/dev/null
$svn_repo/build  --export=${export_dir}/$rev/

rm -rf $from_git 2>/dev/null
git clone giteval@np145.wc1.yellowpages.com/watson/watson-weekly-updated.git $from_git
cp -r ${export_dir}/* $from_git/.
cd $from_git
git tag -a rev_$rev -m "Auto weekly update, new tag for watson update"
git add .
git commit -m "Updating to $rev" .
git push --all git@irvsrddev4.flight.yellowpages.com:watson/watson-weekly-updated.git
git push --tag git@irvsrddev4.flight.yellowpages.com:watson/watson-weekly-updated.git

## Cleaning up
rm -rf $from_git 2>/dev/null
