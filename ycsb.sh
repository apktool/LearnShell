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
declare -i record_count=1000
declare -i operation_count=${record_count}
declare -i insert_start=0
declare -i insert_count=${operate_count}

function init_os() {
    local hosts=("node1" "node2" "node3")
    local user=root
    local cmd="sync; echo 3 > /proc/sys/vm/drop_caches"

    for host in ${hosts[@]}; do
       ssh ${user}@${host} "${cmd}"
    done
}

function init_hbase() {
    cd ${hbase_path}

    local cmd="exists '${table_name}'"
    if echo -e ${cmd} | bin/hbase shell 2>&1 | grep -q "does exist"; then
        echo "Table usertable does exist"

        cmd="disable '${table_name}'"
        echo -e ${cmd} | bin/hbase shell

        cmd="drop '${table_name}'"
        echo -e ${cmd} | bin/hbase shell
    else
        echo "Table usertable does not exist"
    fi


    cmd="create '${table_name}','${hbase_cf}', {SPLITS => (1..32).map {|i| \"user#{1000+i*(9999-1000)/32}\"}, MAX_FILESIZE => 4*1024**3}"
    echo -e ${cmd} | bin/hbase shell
    
    cd ${current_path}
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
    local cmd="bin/ycsb load hbase20 -cp ${hbase_path}/conf -P workloads/${1} -s -threads ${thread_count} -p insertstart=${insert_start} -p insertcount=${insert_count} -p recordcount=${record_count} -p fieldcount=${field_count} -p fieldlength=${field_length} -p columnfamily=${hbase_cf}"
    ${cmd}
}

###############################################
#
# YCSB Execute the workload
#
##############################################
function run() {
    local cmd="bin/ycsb run hbase20 -cp ${hbase_path}/conf -P workloads/${1} -s -threads ${thread_count} -p insertstart=${insert_start} -p insertcount=${insert_count} -p operationcount=${operation_count} -p fieldcount=${field_count} -p fieldlength=${field_length} -p columnfamily=${hbase_cf}"
    ${cmd}
}

# bash ycsb.sh init
# bash ycsb.sh load workloada
# bash ycsb.sh run workloada

$@
