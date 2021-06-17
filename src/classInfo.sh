#!/bin/bash

cd $(dirname $0)

CLASS=$1
QUERY="$(cat classInfo.sparqlTemplate | sed 's|###CLASS###|'$CLASS'|g' )"

curl -s "https://mods.tools.dbpedia.org/sparql?format=text/csv" \
	--data-urlencode "query=$QUERY" \
	| sed 's|"||g' \
	| tail -1
