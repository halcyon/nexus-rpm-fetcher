#!/usr/bin/env zsh

set -e

usage() {
    print "${1} -u <nexus-url> [-e <rpm> -p <path>]"
}

while getopts ":he:p:u:" opt; do
  case ${opt} in
    e)
        MAVEN_EXTENSION="maven.extension=${OPTARG}"
        ;;
    h)
        usage ${0}
        exit 0
        ;;
    p)
        REST_PATH=${OPTARG}
        ;;
    u)
        NEXUS_URL=${OPTARG}
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
  esac
done

if [[ -z ${NEXUS_URL} ]]
then
    usage ${0}
    echo "The base nexus URL must be specified with -u."
    exit 1
fi

MAVEN_EXTENSION=${MAVEN_EXTENSION:-"maven.extension=rpm"}
REST_PATH=${REST_PATH:-"/service/siesta/rest/beta/search/assets?"}

download() {
    for i in "${(@f)$(print ${1} | jq '.items[].downloadUrl')}"
    do
        url=${${i#\"}%\"}
        file=$(basename ${url})
        if [[ ! -e ${file} ]]
        then
            curl -o ${file} ${url}
        fi
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

page=$(curl -X GET --header 'Accept: application/json' "${NEXUS_URL}${REST_PATH}${MAVEN_EXTENSION}")
download ${page}
exit_on_err_or_finished ${page}

while true
do
    continuation_token=$(continuation ${page})
    page=$(curl -X GET --header 'Accept: application/json' "${NEXUS_URL}${REST_PATH}${MAVEN_EXTENSION}&continuationToken=${continuation_token}")
    download ${page}
    exit_on_err_or_finished ${page}
done
