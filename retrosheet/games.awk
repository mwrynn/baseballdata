#!/bin/awk

#SOURCE
#id,[...]   ####start of record
#[...]
#info,visteam,BOS
#info,hometeam,NYA
#info,site,NYC21
#info,date,2013/04/01
#info,number,0
#[...]
#data,[...]
#[...]
#start,[...]
#[...]
#id,[...]    ####start of next record
#[REPEAT]

#DEST
#2013-04-01,0,NYA,BOS,NYC21
#[REPEAT]

#each incoming record ends with 0D0A (\r\n)
BEGIN { FS=","; RS="\r\n"; OFS=","; ORS="\n"}
{
    if ($1 == "info") {
	arrinfo[$2]=$3;
    }

    else if ($1 == "id" && NR != 1) {
	gsub("/","-",arrinfo["date"]);
	print arrinfo["date"],arrinfo["number"],arrinfo["hometeam"],arrinfo["visteam"],arrinfo["site"]
    }
}
