#!/bin/bash

HTML=release.html
ODT=release.odt

if [ ! -f release.odt ] || [ ! -f release.html ]
then
	curl -L "https://docs.google.com/document/d/1_KzahDmOf8cl-Oni1elbbnyDJIwhSDUMBa3L_dv5x2g/export?format=odt" -o $ODT
	soffice --headless --convert-to html $ODT
fi

perl -pe 's/###TEST###/`cat src\/TEST.html`/ge' -i $HTML

