#!/bin/bash

INDEX="About/main.html"

#used to figure out if the file should be the index or not 
function getOfileName {
    if [ $1 = $INDEX ]  
    then
        echo "index.html"
    else
        echo "${1%/*}.html"
    fi
}

#build bar before we do anything else
BAR="<ul class=navbar>"
for content in */main.html ; do
    name=${content%/*}
    #BAR="$BAR <li class=navbar_li> <a class=navbar_li_a href=\"$(getOfileName $content)\">$name</a> </li>"
    BAR=`printf "%s\n    %s" "$BAR" "<li class=navbar_li> <a class=navbar_li_a href=\"$(getOfileName $content)\">$name</a> </li>"`
done
BAR="${BAR}</ul>"

#must set the variables $BAR $TEXT $EXTRA before using this function
function insertIntoTemplate {
    awk -v bar="$BAR" -v text="$TEXT" -v extra="$EXTRA" \
        '{gsub("BARGOESHERE", bar); gsub("TEXTGOESHERE", text); gsub("EXTRAGOESHERE", extra); print}' template.html
}

for content in */main.html ; do
    #This extra depends on the page, right now it is used to 
    #dynamically build the list of projects on the projects page
    EXTRA=""
    if [ $content = "Projects/main.html" ]
    then
        EXTRA="<ul>"
        OIFS="$IFS"
        IFS=$'\n'
        for project in $(ls Projects | grep -v main); do
            TEXT="$(cat Projects/$project)"
            EXTRA=`printf "%s\n    %s" "$EXTRA" "<li> <a href=\"$project\">$(sed 's/_/ /g' <(echo ${project%.html}))</a> </li>"`
            insertIntoTemplate > build/${project}
        done
        IFS=$OIFS
        EXTRA=`printf "%s\n%s" "$EXTRA" "</ul>"`
    fi

    #set the bar to have an active tab
    OLDBAR="$BAR"
    CURRENTTAB="${content%/*}"

    LINENUM=$(grep -n "$CURRENTTAB" <(echo "$BAR") | cut -d ':' -f 1)
    BAR="$(awk -v linenum="$LINENUM" 'NR == linenum {gsub("li class=navbar_li", "li class=navbar_li_active")}; {print}' <(echo "$BAR"))"

    OFILE="$(getOfileName $content)"
    mkdir -p build
    TEXT="$(cat $content)"
    insertIntoTemplate > build/${OFILE}
    BAR="$OLDBAR"
done

cp styles.css build/styles.css
cp -r pictures downloads build/
