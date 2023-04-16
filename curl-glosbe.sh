#!/bin/bash

#  API description: https://glosbe.com/a-api
#https://iapi.glosbe.com/iapi3/wordlist?l1=es&l2=pl&q=m&after=20&includeTranslations=true&token=3bd303c4abdb40bc&timestamp=1681644453
#https://iapi.glosbe.com/iapi3/wordlist?l1=es&l2=pl&q=mesa&after=20&includeTranslations=true&token=2231a628377891c4&timestamp=1681654721
#https://iapi.glosbe.com/iapi3/translate?l1=es&l2=pl&phrase=mesa&page=1&includeWordlist=true&includeSimilar=true&includeTmem=true&includeAudioSentences=true&env=pl&token=46e5c7443df10c29&timestamp=1681655145

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
