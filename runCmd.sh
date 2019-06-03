#!/usr/local/env bash

bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit


function run_cmd() {
    local out_file="${1:-a}.out"
    local date_format="+%Y-%m-%d %H:%M:%S"

    echo -e "----->| start   -->| $(date "$date_format") |<-----" | tee -a "$out_file"
    echo -e "----->| command -->| $*" | tee -a "$out_file"
    local cmd=$1
    shift

    $cmd "$@" | tee -a "$out_file"

    echo -e "----->| end     -->| $(date "$date_format") |<-----" | tee -a "$out_file"
}


function fun() {
    echo "${0:-"function"}"
    echo "${1:-"First"}"
    echo "${2:-"Second"}"
}


run_cmd fun Hello world
fun Hello world
