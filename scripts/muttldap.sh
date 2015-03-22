 
#!/bin/sh
# Requires: echo, expr, grep, ldapsearch, sed, test
# Set your PATH accordingly.
#

max=100
timeout=60
sort=givenName
base='DC=corp,DC=yp,DC=com'
host='corp.yp.com'
dn='corp\hborole'
passwd='October2013'
filter="(&(objectClass=*)(|(cn=*$@*)(displayName=*$@*)(givenName=*$@*)(mail=*$@*)))"

status=`ldapsearch -z $max -x -s sub -l $timeout -b "$base" -h $host -D $dn -w $passwd "$filter" 1.1 2>&1 | grep -E '^(# )?(numResponses|numEntries|result|ldapsearch): '`

count="`echo $status | grep numResponses: | sed -e 's/.*numResponses: \([0-9.+-]*\).*/\1/'`"
count="`expr ${count:-1} - 1`"
result="`echo $status | grep result: | sed -e 's/.*result: \([0-9.+-]*\) \([^ ]*\).*/\1/'`"
result="`expr ${result:--7} + 0`"
rmesg="`echo $status | grep ldapsearch:`"
test -z "$rmesg" && rmesg="rcode=$result `echo $status | grep result: | sed -e 's/.*result: \([0-9.+-]*\) \([^#:]*\) [#]*[ ]*[A-Za-z]*[:]*.*/\2/'`"

if test "${result:-1}" -ne 0 -a "${result:-1}" -ne 4
then
  echo "ERROR: $rmesg"
  exit 2
fi

if test ${count:-0} -eq 0
then
  echo "Searching database ... $max entries ... $count matching."
  exit 1
fi

(
ldapsearch -S $sort -LLL -z $max -x -s one -l $timeout -b "$base" -a search "$filter" \ 
mail displayName mozillaSecondEmail givenName initials surname ; \ 
echo dn: DONE \ 
) 2>/dev/null | while read ATTR VAL
do
  if test -z "$ATTR"; then continue; fi
  attr="`echo $ATTR | sed -e 's/:$//'`"
  case "$attr" in
    dn)
        if test -z "$dn"
        then
          echo "Searching database ... $max entries ... $count matching:"
        else
          echo -n "$mail        $displayName"
          if test -n "$sn"
          then
            echo -n "   "
            ( ( test -n "$initials" && echo -n $initials ) || (test -n "$givenName" && echo -n $givenName) )
            echo -n " $sn"
          fi
          test -n "$mozillaSecondEmail" && echo -n " <$mozillaSecondEmail>"
          echo
        fi
        dn="$VAL"
        eval unset $VARS VARS
        ;;
    *)
        test -n "$attr" -a -n "$VAL" && setvar $attr "$VAL"  && VARS="$VARS $attr"
        ;;
  esac
done

exit ${result:-0}
