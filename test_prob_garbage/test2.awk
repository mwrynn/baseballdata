/^\"MLB.*/ { print $0; next }#{gsub(/^\"MLB.*/, "", $0)} 
