#!/bin/zsh
function caln {
sign=$1
incr=$2
incr=${incr:=1}
typeset -a d
d=($(date --date " $sign ${incr} months" "+%m %Y"))
m=${d[1]}
y=${d[2]}
cal $m $y
}

function cal3 {
caln '-'
cal
caln '+'
}
