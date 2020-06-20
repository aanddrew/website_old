#!/bin/bash

INDEX="About/main.html"

function insertIntoTemplate {
    BARLINE=$(grep -n BARGOESHERE template.html | cut -d ':' -f 1)
    TEXTLINE=$(grep -n TEXTGOESHERE template.html | cut -d ':' -f 1)

    TOP="$(sed -n 1,$(expr ${BARLINE} - 1)p template.html)"
    MIDDLE="$(sed -n $(expr ${BARLINE} + 1),$(expr ${TEXTLINE} - 1)p template.html)"
    BOT="$(sed -n $(expr ${TEXTLINE} + 1),$(wc -l template.html | cut -d ' ' -f 1)p template.html)"

    echo -e "$TOP\n $BAR $MIDDLE <br> $1\n $2 \n $BOT"
}

function getOfileName {
    if [ $1 = $INDEX ]  
    then
        echo "index.html"
    else
        echo "${1%/*}.html"
    fi
}

BAR="<ul class=navbar>"
for content in */main.html ; do
    name=${content%/*}
    BAR="$BAR <li class=navbar_li> <a class=navbar_li_a href=\"$(getOfileName $content)\">$name</a> </li>"
done
BAR="${BAR}</ul>"

for content in */main.html ; do
    EXTRA=""
    if [ $content = "Projects/main.html" ]
    then
        EXTRA="<ul>"
        OIFS="$IFS"
        IFS=$'\n'
        for project in $(ls Projects | grep -v main); do
            EXTRA="$EXTRA <li> <a href=\"$project\">$(sed 's/_/ /g' <(echo ${project%.html}))</a> </li>"
            echo $(insertIntoTemplate "$(cat Projects/$project)") > build/${project}
        done
        IFS=$OIFS
        EXTRA="$EXTRA </ul>"
    fi

    OFILE="$(getOfileName $content)"

    mkdir -p build
    echo $(insertIntoTemplate "$(cat $content)" "$EXTRA") > build/${OFILE}
done

cp styles.css build/styles.css
cp -r pictures downloads build/
