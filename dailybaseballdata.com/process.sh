sed '/script/,$d;/^$/d' | awk -f process.awk -v theyear=$1 
