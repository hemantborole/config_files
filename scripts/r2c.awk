awk '{       
 arr[$1]=arr[$1]" "$2
}
END {
 for ( i in arr) {
  print i,arr[i]
 }
}
' /tmp/1.ip

