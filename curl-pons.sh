#!/bin/bash

# account: connected with FB
# http://en.pons.com/open_dict/public_api

APIURL="https://api.pons.com/v1"
APIFUNC="dictionary"
APIPAR="l=espl"

OPTS=("--header" "X-Secret: 4f0b3a8f26c156592dca9351facb47d4f5c1a9bfe0192ae8a173290eec8bea07")

while [ $# -gt 0 ]; do
	a=$1; shift
	case "$a" in
		-list|-l)
			APIFUNC="dictionaries"
			APIPAR="language=es"
			break
		;;
		-from) APIPAR+="&in=$1";shift;;
		*)
			APIPAR+="&q=$a"
			break
		;;
	esac
done


echo "curl" "${OPTS[@]}"  "$APIURL/$APIFUNC?$APIPAR"
curl "${OPTS[@]}"  "$APIURL/$APIFUNC?$APIPAR"
echo
