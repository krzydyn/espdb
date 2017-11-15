#!/bin/bash

OPTS=()

while [ $# -gt 0 ]; do
	a=$1; shift
done

# add api params to func
if [ -n "$APIPAR" ]; then
	APIFUNC+="?$APIPAR"
fi

echo "curl" "${OPTS[@]}" "$APIURL/$APIFUNC" >&2
curl "${OPTS[@]}" "$APIURL/$APIFUNC"


# Hiszp w 1 dzien: 156 fiszek
curl 'https://fiszkoteka.pl/sebabox/learn/request?callback=jQuery183016718899634743134_1510224741363' -H 'Cookie: ab_base=21aa61133c83733b90bb740f5255a4bfcd69c3b08fe1ba148182c6204ba14df9a%3A2%3A%7Bi%3A0%3Bs%3A7%3A%22ab_base%22%3Bi%3A1%3Bs%3A43%3A%220SNBm-PFZXuziqtn_jPp8sblMijHSfNkKZ3m_WAZ_mo%22%3B%7D; _gaexp=GAX1.2.d8Inhbh6RKe6NyFTMmRZ8g.17545.0; PHPSESSID=qrhbd0lbrmf1sk5iabktgrnp17; fvaid=p5t1MLwtd9Oq5_zsoMwR; returningVisitor=true; _ga=GA1.2.576321829.1510224729; _gid=GA1.2.2026364003.1510224729; learnBox_config=%7B%22ignoreArticles%22%3A%221%22%2C%22saved%22%3Afalse%2C%22ignoreCase%22%3A%221%22%2C%22ignorePunctuation%22%3A%221%22%2C%22ignoreSpaces%22%3A%221%22%2C%22ignoreParentheses%22%3A%221%22%2C%22ignoreOrder%22%3A%221%22%2C%22ignoreCharset%22%3A%221%22%2C%22unifyAbbrev%22%3A%221%22%2C%22changedSide%22%3A%220%22%2C%22showText%22%3A%221%22%2C%22showHint%22%3A%221%22%2C%22showImage%22%3A%221%22%2C%22playText%22%3A%221%22%2C%22playExample%22%3A%220%22%2C%22playNative%22%3A%220%22%2C%22showExample%22%3A%221%22%2C%22stressGender%22%3A%221%22%2C%22timer%22%3A%220%22%2C%22queue%22%3A%221%22%2C%22error%22%3A%220%22%2C%22shuffle%22%3A%221%22%2C%22rewrite%22%3A%220%22%2C%22askLookingThrough%22%3A%220%22%2C%22askCopy%22%3A%220%22%2C%22askTextField%22%3A%220%22%2C%22askIfKnow%22%3A%221%22%2C%22askChoose%22%3A%220%22%2C%22star%22%3A%221%22%2C%22trash%22%3A%220%22%2C%22heart%22%3A%220%22%7D; _identity=b3d630c975ec6e32ffeffc1745e10e7d311f616b691dd1b3425f4e8cd073ee97a%3A2%3A%7Bi%3A0%3Bs%3A9%3A%22_identity%22%3Bi%3A1%3Bs%3A62%3A%22%5B617104%2C%22hxt5fmJ0QMo0L2-NHOWhreJa5UjDZNVgdsjgJAt53tE%22%2C2678400%5D%22%3B%7D' -H 'Origin: https://fiszkoteka.pl' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: pl-PL,en-US;q=0.8,pl;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01' -H 'Referer: https://fiszkoteka.pl/nauka' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data 'config%5Btrue%5D=true&content%5Bjn_id%5D=3632680&content%5Btype%5D=6&content%5Blimit%5D=156&content%5Boffset%5D=0&queue%5Blq_collection%5D=3632680' --compressed
