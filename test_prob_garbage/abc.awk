/^a.*/ { gsub(".*","w00t",$0) }; { print $0 }
#/^g.*/ { print $0 }
