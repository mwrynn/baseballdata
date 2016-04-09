#!/bin/awk

#SOURCE
#id,[...]
#[...]
#info,date,2013/04/01
#info,number,0
#info,visteam,BOS #set visteam var
#info,hometeam,NYA #set hometeam var
#[...]
#start,[player id],[...],[visiting/home (0/1)],[...],[position (we want 1 which is pitcher)] #set pitcher var to player id here
#[...]
#play,[inning],[visiting/home (0/1)],[player ID],[...],[...],[A-Z0-9 (result)]/[...]
#[...]
#sub,[player id==pitcher var],[...] #set pitcher var to this in order

#DEST
#hometeam,visteam,2013-04-01,0,inning,player ID (batter), player ID (pitcher),result

BEGIN { FS=","; RS="\r\n"; OFS=","; ORS="\n" }
{
    if ($1 == "info") {
	arrinfo[$2]=$3;
    }
    else if ($1 == "start" && $6 == "1") {
	if ($4 == "1") {
	    homepitcher=$2;
	}
	else {
	    vispitcher=$2;
	}
    }
    else if ($1 == "sub" && $5 == "1") {
	if ($3 == "1") {
	    homepitcher=$2;
	}
	else {
	    vispitcher=$2;
	}
    }
    else if ($1 == "badj") {
	batteradjhand=$3;
    }

    else if ($1 == "play") {
	if ($3 == "0") {
	    playpitcher=homepitcher;
	}
	else {
	    playpitcher=vispitcher;
	}
	split($7, resultarr, "/");
	gsub("/","-",arrinfo["date"]);
	print arrinfo["hometeam"],arrinfo["visteam"],arrinfo["date"],arrinfo["number"],$2,$4,playpitcher,resultarr[1],batteradjhand;
	batteradjhand="";
    }

}
