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
rm -f $fileName

function generateRandomString() {
    local randomString=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $1 | head --byte $1)

    declare -n ret=$2
    ret=$randomString
}

function generateRandomNumber() {
    local randomNumber=$(cat /dev/urandom | tr -dc '0-9' | fold -w $1 | head --byte $1)

    declare -n ret=$2
    ret=$randomNumber
}

################################################
#
# Note: Principle
# I can generate two part of bytes data, one is rowkey, another are columns composed with cell.
#
# For rowkey,
# All bytes data will be generated, which length is equal to number of rows mutiply by size of rowkey,
# and then, I will split this byte data agaist rowKeylength
#
# For columns
# All table data will be generated, which length is equal to number of column mutiply by number of rows
# mutiply by size of cells
# and then, same steps as rowkey
#
################################################

function generateMultiLineData() {
    declare -ir recordcount=$1
    declare -ir fieldcount=$2
    declare -ir fieldlength=$3

    local rowKeylength=20

    let oneLineBytes="$fieldcount * $fieldlength"
    let allFieldsBytes="$recordcount * $oneLineBytes"
    let allRowKeyBytes="$recordcount * $rowKeylength"

    generateRandomNumber $allRowKeyBytes rowKeys
    generateRandomString $allFieldsBytes cells

    local row=""
    declare -i cnt=0

    local i=0 j=0
    while (( i <= $allFieldsBytes && j <= $allRowKeyBytes )); do
        cell=${cells:$i:$fieldlength}

        if (( $i % $oneLineBytes == 0 && $i != 0 )); then
            rowKey=user${rowKeys:$j:$rowKeylength}
            printf $rowKey$row"\n" >> $fileName

            let j="$j + $rowKeylength"

            row=""
            let cnt="$cnt+1"

            if (( $cnt % 10 == 0)); then
                printf "Finished $cnt \t rows\n"
            fi

        fi

        let i="$i + $fieldlength"
        row=$row$delimiter$cell
    done
}

generateMultiLineData 10 100 4
