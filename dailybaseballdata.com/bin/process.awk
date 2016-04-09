NR==1,/pre/ { if($0 ~ /pre(.*$)/) {gsub(/.*pre[^0-9]+/,"",$0); gsub(/, \(.*\)/,"",$0); D=$0 } next }
/^[0-9]+,/ {print $0 "," D "/" theyear}
/^\"MLB/ { }


