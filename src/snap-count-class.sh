#!/bin/bash
VERSION=$1
CLASS=$2

QUERY='
PREFIX void: <http://rdfs.org/ns/void#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT (SUM(?triples) AS ?count) WHERE {
  VALUES ?file {
'$(for i in $(./snap-get-files.sh $VERSION); do echo "<$i>"; done)'
  }
  ?mam prov:used ?file .
  ?mam a <https://mods.tools.dbpedia.org/ns/rdf#VoidMod> .
  FILTER( regex(str(?file), "https://databus.dbpedia.org/dbpedia/mappings/*"))
  ?mam prov:generated [
       <http://rdfs.org/ns/void#classPartition> [
         void:class <http://dbpedia.org/ontology/'$CLASS'> ;
         void:triples ?triples
      ]
  ]
}
'

curl -s "https://mods.tools.dbpedia.org/sparql?format=text/csv" \
	--data-urlencode "query=$QUERY" \
	| sed 's|"||g' \
	| tail -1
