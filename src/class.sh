#!/bin/bash

cd $(dirname $0)

CLASS=$1
OLD_VERS=$2
NEW_VERS=$3

OLD_COUNT=$(./snap-count-class.sh $OLD_VERS $CLASS)
NEW_COUNT=$(./snap-count-class.sh $NEW_VERS $CLASS)
OLDER_COUNT=$(./2016-count-class.sh $CLASS)

echo [DEBUG] @ $CLASS NEW $NEW_COUNT OLD $OLD_COUNT 2016 $OLDER_COUNT 1>&2

echo -n "$NEW_COUNT ("
awk 'BEGIN {printf "%3.2f", '$NEW_COUNT'/'$OLD_COUNT'}'
echo -n "%, "
awk 'BEGIN {printf "%3.2f", '$NEW_COUNT'/'$OLDER_COUNT'}'
echo "%)"
