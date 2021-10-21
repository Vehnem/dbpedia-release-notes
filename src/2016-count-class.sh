#!/bin/bash

CLASS=$1

QUERY='
PREFIX void: <http://rdfs.org/ns/void#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX dcat: <http://www.w3.org/ns/dcat#>
SELECT (SUM(?triples) as ?t2016) WHERE {
		SERVICE <http://databus.dbpedia.org/repo/sparql> {
                ?dataid dct:hasVersion "2016.10.01"^^xsd:string .
                ?dataid dcat:distribution/dataid:file ?file .
    			FILTER regex(str(?file),"^https://databus.dbpedia.org/dbpedia/.*lang=en.*")
        }
  	?activity a <https://mods.tools.dbpedia.org/ns/rdf#VoidMod> .
    ?activity prov:used ?file .
    ?activity prov:generated [
    <http://rdfs.org/ns/void#classPartition> [
       void:class <http://dbpedia.org/ontology/'$CLASS'> ;
       void:triples ?triples
    ]
  ]
}
'

#curl "https://mods.tools.dbpedia.org/sparql?format=text/csv" \
#	--data-urlencode "query=$QUERY"

curl "https://mods.tools.dbpedia.org/sparql?format=text/csv" \
	--data-urlencode "query=$QUERY" \
	| sed 's|"||g' \
	| tail -1
