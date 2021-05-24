#!/usr/bin/env bash

bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit
cd ..

declare -r zk_server_ip=192.168.0.1:2181,192.168.0.2:2181,192.168.0.3:2181
declare -r kafka_broker_ip=192.168.0.4:6667
declare -r kafka_broker_path=/usr/hdp/current/kafka-broker

function run_cmd() {
    if [[ ! -f logs ]]; then
        mkdir -p logs
    fi

    local out_file="logs/${1:-a}.out"
    local date_format="+%Y-%m-%d %H:%M:%S"

    echo -e "----->| start   -->| $(date "$date_format") |<-----" | tee -a "$out_file"
    echo -e "----->| command -->| $*" | tee -a "$out_file"
    local cmd=$1
    shift

    ${cmd} "$@" | tee -a "$out_file"

    echo -e "----->| end     -->| $(date "$date_format") |<-----" | tee -a "$out_file"
}

function delete_topic() {
    cd ${kafka_broker_path}
    bin/kafka-topics.sh  --delete --zookeeper ${zk_server_ip} --topic $1
}

function create_topic() {
    cd ${kafka_broker_path}
    bin/kafka-topics.sh --create --zookeeper ${zk_server_ip} --replication-factor $1 --partitions $2 --topic $3
}

function describe_topic() {
    cd ${kafka_broker_path}
    bin/kafka-topics.sh --describe --zookeeper ${zk_server_ip} --topic $1
}

function list_topics() {
    cd ${kafka_broker_path}
    bin/kafka-topics.sh --list --zookeeper ${zk_server_ip}
}

function list_consumer_group() {
    cd ${kafka_broker_path}
    bin/kafka-consumer-groups.sh --bootstrap-server ${kafka_broker_ip} --list
}

function describe_consumer_group() {
    cd ${kafka_broker_path}
    bin/kafka-consumer-groups.sh --bootstrap-server ${kafka_broker_ip} --group $1 --describe
}

function count_topic_messages() {
    cd ${kafka_broker_path}
    bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${kafka_broker_ip} --topic $1 --time -1
}

function produce_topic() {
    cd ${kafka_broker_path}
    bin/kafka-console-producer.sh --broker-list ${kafka_broker_ip} --topic $1
}

function consume_topic() {
    cd ${kafka_broker_path}
    bin/kafka-console-consumer.sh --bootstrap-server ${kafka_broker_ip} --topic $1 --from-beginning | tee $1.out
}

function help() {
    declare -F
}

# run_cmd delete_topic tmp37
# run_cmd create_topic 1 10 tmp37
# run_cmd describe_topic tmp37
# run_cmd describe_consumer_group SDP_SANGFOR
# run_cmd count_topic_messages tmp37
# run_cmd produce_topic tmp37
# run_cmd consume_topic tmp37

run_cmd $@

# run_cmd delete_topic tmp51
# run_cmd create_topic 1 10 tmp51
# run_cmd delete_topic tmp52
# run_cmd create_topic 1 10 tmp52
# 
# run_cmd delete_topic tmp53
# run_cmd create_topic 1 20 tmp53
# run_cmd delete_topic tmp54
# run_cmd create_topic 1 20 tmp54
