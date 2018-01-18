#!/usr/bin/env zsh

REPO=${1}
REST_PATH="/service/siesta/rest/beta/search/assets?"
PARAMS="maven.extension=rpm"

download() {
    for i in "${(@f)$(print ${1} | jq '.items[].downloadUrl')}"
    do
        url=${${i#\"}%\"}
        curl -o $(basename ${url}) ${url}
    done
}

continuation() {
    print "$(print ${1} | jq '.continuationToken')"
}

exit_on_err_or_finished() {
    if [[ -z "$(continuation ${1})" ]]
    then
        exit 1
    elif [[ $(continuation ${1}) == "null" ]]
    then
        exit 0
    fi
}

page=$(curl -X GET --header 'Accept: application/json' "${REPO}${REST_PATH}${PARAMS}")
download ${page}
exit_on_err_or_finished ${page}

while true
do
    continuation_token=$(continuation ${page})
    page=$(curl -X GET --header 'Accept: application/json' "${REPO}${REST_PATH}${PARAMS}&continuationToken=${continuation_token}")
    download ${page}
    exit_on_err_or_finished ${page}
done
