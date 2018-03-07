#!/bin/bash

usage() {
    echo "${1} -u <nexus-url> [-e <asset-extension> -p <REST path>]"
}

while getopts "he:p:u:" opt; do
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
REST_PATH=${REST_PATH:-"/service/rest/beta/search/assets?"}

RESPONSE=`curl -s -L -X GET --header 'Accept: application/json' ${NEXUS_URL}${REST_PATH}${MAVEN_EXTENSION}?maven.extension=rpm`
RPMS=`echo ${RESPONSE} | jq '.items[].downloadUrl' | sed -e 's/"//g'`
CTTOK=`echo ${RESPONSE} | jq '.continuationToken' | sed -e 's/"//g'`

wget -nc ${RPMS};

while [ -n "${CTTOK}" ]; do
  RESPONSE=`curl -s -L -X GET --header 'Accept: application/json' ${NEXUS_URL}${REST_PATH}${MAVEN_EXTENSION}?maven.extension=rpm\&continuationToken=${CTTOK}`
  RPMS=`echo ${RESPONSE} | jq '.items[].downloadUrl' 2>/dev/null | sed -e 's/"//g'`
  CTTOK=`echo ${RESPONSE} | jq '.continuationToken' 2>/dev/null | sed -e 's/"//g'`
  wget -nc ${RPMS};
done
