#!/bin/bash

OLD_SNAP_VERS=$1
NEW_SNAP_VERS=$2

getFileList() {
	query=$(curl -s -H "Accept:text/sparql" https://databus.dbpedia.org/dbpedia/collections/dbpedia-snapshot-$1)
	curl -s -H "Accept: text/csv" --data-urlencode "query=${query}" https://databus.dbpedia.org/repo/sparql | tail -n+2 | sed 's/"//g'
}


OLD_F=$(getFileList $OLD_SNAP_VERS | sort -u)
NEW_F=$(getFileList $NEW_SNAP_VERS | sort -u)

separateVersion() {
	for id in $1
	do
		WO_VERS=$(echo "$id" | cut -d '/' -f1,2,3,4,5,6,8)
		VERS=$(echo "$id" | cut -d '/' -f7 )
		echo -e "$id\t$WO_VERS\t$VERS"
	done
}

OLD_TABLE=$(separateVersion "$OLD_F")
NEW_TABLE=$(separateVersion "$NEW_F")

BIG_TABLE=$(join -j 2 -e 'EMPTY' -o '1.1,1.2,1.3,2.1,2.2,2.3' -a 1 -a 2  <(echo "$OLD_TABLE") <(echo "$NEW_TABLE"))

checkSize() {
	curl -s -IL "$1" | grep -i 'content-length' | tail -1 | grep -Po '\d+'
}

echo "$BIG_TABLE" | while IFS=' ' read -r id1 tf1 ve1 id2 tf2 ve2
do
	TF=""
	OLD_SIZE=""
	NEW_SIZE=""
	if [ "$tf1" = "EMPTY" ]; then echo $tf2; else echo $tf1; fi
	if [ "EMPTY" = "$id1" ]; then echo [WARN] $OLD_SNAP_VERS IS MISSING \<$tf2\>; else [ ! "$ve1" = "$ve2" ] && OLD_SIZE=$(checkSize $id1); TF="$tf1"; fi 
	if [ "EMPTY" = "$id2" ]; then echo [WARN] $NEW_SNAP_VERS IS MISSING \<$tf1\>; else [ ! "$ve2" = "$ve1" ] && NEW_SIZE=$(checkSize $id2); TF="$tf2"; fi
	# size check
	if [ -n "$TF" ] && [ -n "$OLD_SIZE" ] && [ -n "$NEW_SIZE" ]
	then
		PERC=$(awk 'BEGIN {printf "%d",  100 * '$NEW_SIZE' / '$OLD_SIZE' }')
		if [ 91 -gt "$PERC" ] || [ 110 -lt "$PERC" ]
		then
			echo "[WARN] <$TF> NEW-BSIZE: $NEW_SIZE, is $PERC% of, OLD-BSIZE $OLD_SIZE"
		fi
	fi
done
