#!/bin/bash

#  API description: https://glosbe.com/a-api
#  

APIURL="https://glosbe.com/gapi"
APIFUNC="translate"
APIPAR="format=json"
APIPAR+="&pretty=true"

OPTS=()

while [ $# -gt 0 ]; do
	a=$1; shift
	case "$a" in
		-version|-v)
			APIURL="https://glosbe.com"
			APIFUNC="gapi_v0_1"
			APIPAR=""
			break
		;;
		-from) APIPAR+="&from=$1";shift;;
		-dest) APIPAR+="&dest=$1";shift;;
		*)
			if ! echo "$APIPAR" | grep "from" &> /dev/null; then
				APIPAR+="&from=pol"
				APIPAR+="&dest=spa"
			fi
			APIPAR+="&phrase=$a"
			break
		;;
	esac
done

# add api params to func
if [ -n "$APIPAR" ]; then
	APIFUNC+="?$APIPAR"
fi

echo "curl" "${OPTS[@]}" "$APIURL/$APIFUNC" >&2
curl "${OPTS[@]}" "$APIURL/$APIFUNC"
