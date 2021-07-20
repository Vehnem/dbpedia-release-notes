#!/bin/bash

HTML=release.html
ODT=release.odt

# create HTML
if [ ! -f release.odt ] || [ ! -f release.html ]
then
	curl -L "https://docs.google.com/document/d/1_KzahDmOf8cl-Oni1elbbnyDJIwhSDUMBa3L_dv5x2g/export?format=odt" -o $ODT
	soffice --headless --convert-to html $ODT
fi

#export preamble="$(sed -n '/BEGIN/,/END/p' release.html)"
#perl -pe 's/ENV{preamble}//ge' -i $HTML

# class stats
for class in $(grep -Po '###CLASS_\w+###' release.html)
do
	className=$(echo $class | grep -Po '_\K\w+')
	export result=$(src/classInfo.sh $className)
	perl -pe 's/'"$class"'/$ENV{result}/ge' -i $HTML
done

# dbo prop counts
export result=$(src/countProp)
perl -pe 's/###DBO_PROP_COUNT###/$ENV{result}/ge' -i $HTML

# class links
for classLink in $(grep -Po '###CLASSLINK_\w+###' release.html)
do
	echo $classLink
	className=$(echo $classLink | grep -Po '_\K\w+')
	export result=$(src/classLink.sh $className)
	perl -pe 's/'"$classLink"'/$ENV{result}/ge' -i $HTML
done


# Archivo
QUERY=$(curl -H "Accept:text/sparql" https://databus.dbpedia.org/denis/collections/latest_ontologies_as_nt)
ONTNUM=$(curl -s "https://databus.dbpedia.org/repo/sparql?format=text/csv" \
	--data-urlencode "query=$QUERY" \
	| sed 's|"||g' \
	| wc -l)
perl -pe 's/###ONTNUM###/'"$ONTNUM"'/ge' -i $HTML
