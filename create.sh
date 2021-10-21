#!/bin/bash

HTML=release.html
ODT=release.odt

NEW_SNAP=2021-09
OLD_SNAP=2021-06
# create HTML
#if [ ! -f release.odt ] || [ ! -f release.html ]
#then
#	curl -L "https://docs.google.com/document/d/1_KzahDmOf8cl-Oni1elbbnyDJIwhSDUMBa3L_dv5x2g/export?format=odt" -o $ODT
#	curl -L "https://docs.google.com/document/d/1yFfeDiXsDRskkIz7xJBmUT87XfbdJt9aLNIkuQfmoQ0/export?format=odt" -o $ODT
#	soffice --headless --convert-to html $ODT
#fi
cp release.html.org release.html

#export preamble="$(sed -n '/BEGIN/,/END/p' release.html)"
#perl -pe 's/ENV{preamble}//ge' -i $HTML

# class stats
for class in $(grep -Po '###CLASS_\w+###' release.html)
do
	echo [DEBUG] @ $class 1>&2
	className=$(echo "$class" | grep -Po '_\K\w+')
	export result=$(src/class.sh "$className" "$OLD_SNAP" "$NEW_SNAP")
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
