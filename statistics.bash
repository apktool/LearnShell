#!/usr/bin/env bash
 
bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit
 
declare -r hosts=(node1 node2 node3)
declare -r shell_scripts=$(echo "${BASH_SOURCE-$0}")
 
function cpu() {
    local res=""
 
    res=$(cat /proc/cpuinfo | grep processor | wc -l)
    echo -e "\e[1;33m> CPU(s):\t ${res}\e[0m"
 
    res=$(lscpu | grep "Model name" | awk -F ':' '{print $2}')
    echo -e "\e[1;33m \t\t Model name: ${res// /}\e[0m"
 
    res=$(lscpu | grep "Socket(s)" | awk -F ':' '{print $2}')
    echo -e "\e[1;33m \t\t Socket(s): ${res// /}\e[0m"
 
    res=$(lscpu | grep "Core(s) per socket" | awk -F ':' '{print $2}')
    echo -e "\e[1;33m \t\t Core(s) per socket: ${res// /}\e[0m"
 
    res=$(lscpu | grep "Thread(s) per core" | awk -F ':' '{print $2}')
    echo -e "\e[1;33m \t\t Thread(s) per core: ${res// /}\e[0m"
}
 
function mem() {
    local res=""
 
    res=$(free -g | grep Mem | awk '{print $2}')
    echo -e "\e[1;33m> Mem(GB):\t ${res}\e[0m"
}
 
function net() {
    local res=""
 
    res=($(ip link | grep "mq state UP mode" | awk -F ':' '{print $2}'))
    echo -e "\e[1;33m> Card(s):\t $(echo ${#res[*]})\e[0m"
    for item in ${res[@]}; do
        res=$(ip address | grep ${item} | awk '{print$2}' | tr '\n' ' ')
        echo -e "\e[1;33m  \t\t ${res%/*}\e[0m"
    done
}
 
function disk() {
    local res=""
 
    res=($(lsblk -r | grep disk | awk '{print $1}'))
    echo -e "\e[1;33m> Disk(s):\t ${#res[*]}\e[0m"
    for item in ${res[@]}; do
        res=$(lsblk -o NAME,SIZE | grep "${item} " | awk '{print $2}')
        echo -e "\e[1;33m \t\t ${item}: ${res}\e[0m"
    done
}
 
function os() {
    local res=""
 
    res=$(cat /etc/redhat-release)
    echo -e "\e[1;33m> Linux OS:\t $(echo ${res})\e[0m"
}
 
function kernel() {
    local res=""
 
    res=$(uname -r)
    echo -e "\e[1;33m> Linux Kernel:\t $(echo ${res})\e[0m"
}
 
function list() {
    cpu
    mem
    net
    disk
 
    os
    kernel
}
 
function all() {
    local file=${bin}/${shell_scripts}
    for host in ${hosts[@]}; do
        scp ${file} root@${host}:/tmp/${shell_scripts}
 
        echo -e "\e[1;34m${host}\e[0m"
        ssh root@${host} "bash /tmp/${shell_scripts} list"
    done
}
 
$@
