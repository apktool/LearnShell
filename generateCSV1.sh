#!/usr/bin/env bash

################################################
#
# Generate CSV file
# This script aims to prepare CSV format file
#
################################################

cd $(dirname ${BASH_SOURCE:-$0})

declare -r delimiter=","

declare -r fileName="usertable.csv"
rm -f ${fileName}

function generateRandomString() {
    local randomString=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1} | head --byte ${1})

    declare -n ret=${2}
    ret=${randomString}
}

function generateRandomNumber() {
    local randomNumber=$(cat /dev/urandom | tr -dc '0-9' | fold -w ${1} | head --byte ${1})

    declare -n ret=${2}
    ret=${randomNumber}
}


function generateALineData() {
    local rowKey=""
    local columns=""
    local column=""
    local i=0

    generateRandomNumber 19 rowKey

    rowKey=user$rowKey

    for (( i = 0; i < ${1:-100}; i++ )); do
        generateRandomString ${2:-4} column
        columns=$columns$delimiter$column
    done

    echo $rowKey$columns | tee -a ${fileName}
}


function generateMultiLineData() {
    local recordcount=${1}
    local fieldcount=${2}
    local fieldlength=${3}
    local i=0

    for (( i = 0; i < ${recordcount}; i++ )); do
        generateALineData ${fieldcount} ${fieldlength}
    done
}

generateMultiLineData 3 5 4
