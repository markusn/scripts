#!/bin/bash

help='translate [[<source language>] <target language>] [incre]
[Usage]
if target missing, uses DEFAULT_TARGET_LANG (en)
if source missing, uses auto
if incre is defined only translate <text> if incre matches,
otherwise echo untranslated

[Example]
To translate a shell script with comments in french to english do:

cat SCRIPT.sh | translate.sh fr en "^ *#[^\!] > SCRIPT_en.sh"

[Dependencies]
bash, curl, grep, html2text

[Based on]
A script by johnraff (http://crunchbang.org/forums/viewtopic.php?pid=176917#p176917)

[Author]
Markus Näsman
'

DEFAULT_TARGET_LANG=en

if [[ $1 = -h || $1 = --help ]]
then
    echo "$help"
    exit
fi

while IFS= read text ;
do
    if [[ $3 ]]; then
        source="$1"
        target="$2"
        incre="$3"
    elif [[ $2 ]]; then
        source="$1"
        target="$2"
        incre=".*"
    elif [[ $1 ]]; then
        source=auto
        target="$1"
        incre=".*"
    else
        incre=".*"
        source=auto
        target="$DEFAULT_TARGET_LANG"
    fi

    if [[ -n $(echo $text | grep -e "$incre") ]]; then
        result=$(curl -s -i --user-agent "" -d "sl=$source" -d "tl=$target" --data-urlencode "text=$text" http://translate.google.com)
        encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
        iconv -f $encoding <<<"$result" |  awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 -width 160
    else
        echo "$text"
    fi
done
