#!/usr/local/env bash

path=$(dirname "${BASH_SOURCE-$0}")
path=$(cd "${path}" > /dev/null || exit; pwd)
cd "${path}" || exit


declare -r hbase_path=/home/li/Software/apache-hbase-2.4.1
declare -r hbase_cf=f1

declare -r current_path=$(pwd)
declare -r table_name=usertable
declare -i thread_count=8
declare -i field_count=10
declare -i field_length=100
declare -i record_count=1000000
declare -i operation_count=${record_count}
declare -i insert_start=0
declare -i insert_count=${operation_count}

function log() {
    local out_path=${current_path}/logs
    local out_file=${out_path}/ycsb.log
    if [ ! -f ${out_file} ]; then
        mkdir -p ${current_path}/logs
    fi

    local res=$(printf "%s %s [%s] : %s\n" "$(date +'%Y-%m-%d %H:%M:%S,%3N')" "${FUNCNAME[1]^^}" "$(whoami)" "${*}" | tee -a ${out_file})

    local cmd=$1; shift
    $cmd "$@"
}

function info() {
    log $*
}

function warn() {
    log $*
}

function init_os() {
    local hosts=("node1" "node2" "node3")
    local user=root
    local cmd="sync; echo 3 > /proc/sys/vm/drop_caches"

    for host in ${hosts[@]}; do
       info ssh ${user}@${host} "${cmd}"
    done
}

function init_hbase() {
    info cd ${hbase_path}

    if echo -e "exists '${table_name}'" | bin/hbase shell 2>&1 | grep -q "does exist"; then
        info echo "Table usertable does exist"
        info echo -e "disable '${table_name}'" | bin/hbase shell
        info echo -e "drop '${table_name}'" | bin/hbase shell
    else
        warn echo "Table usertable does not exist"
    fi

    info echo -e "create '${table_name}','${hbase_cf}', {SPLITS => (1..8).map {|i| \"user#{1000+i*(9999-1000)/8}\"}, MAX_FILESIZE => 4*1024**3}" | bin/hbase shell

    info cd ${current_path}
}

###############################################
#
# YCSB Init everything
#
##############################################
function init() {
    init_os
    init_hbase
}

###############################################
#
# YCSB Load the data
#
##############################################
function load() {
    info bin/ycsb.sh load hbase20 -P workloads/${1} -s -threads ${thread_count} -p insertstart=${insert_start} -p insertcount=${insert_count} -p recordcount=${record_count} -p fieldcount=${field_count} -p fieldlength=${field_length} -p columnfamily=${hbase_cf}
}

###############################################
#
# YCSB Execute the workload
#
##############################################
function run() {
    info bin/ycsb.sh run hbase20 -P workloads/${1} -s -threads ${thread_count} -p insertstart=${insert_start} -p insertcount=${insert_count} -p operationcount=${operation_count} -p fieldcount=${field_count} -p fieldlength=${field_length} -p columnfamily=${hbase_cf}
}

# bash ycsb.sh init
# bash ycsb.sh load workloada
# bash ycsb.sh run workloada

$@
