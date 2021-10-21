#!/bin/bash

getFileList() {
	query=$(curl -s -H "Accept:text/sparql" https://databus.dbpedia.org/dbpedia/collections/dbpedia-snapshot-$1)
	curl -s -H "Accept: text/csv" --data-urlencode "query=${query}" https://databus.dbpedia.org/repo/sparql | tail -n+2 | sed 's/"//g'
}
