#!/bin/bash
echo "Searching local address book"
#grep -i $1 ~/scripts/dat.ab
awk -v search=$1 'BEGIN{count=0} tolower($0) ~ search {count++; print} END{
if( count == 0 )  {
  qry_cmd = "~/scripts/mutt_ldap.pl " search
  system(qry_cmd);
}
}' ~/scripts/dat.ab
