#!/usr/local/env bash

bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit

# http://www.benf.org/other/cfr/
# 需要将 cfr-0.152.jar 以及该 shell 脚本 同级目录

target_prefix=/tmp/output
target_dir=(elasticsearch elasticsearch-core)
jars_file=(/tmp/lib/elasticsearch-7.5.0.jar /tmp/lib/elasticsearch-core-7.5.0.jar)

function clear() {
    for dir in ${target_dir[@]}; do
        rm -rf ${target_prefix}/${dir}
    done
}


function unjar() {
    local len=${#jars_file[*]}
    echo ${len}
    for i in {0..1}; do
        local dir=${target_prefix}/${target_dir[${i}]}
        local file=${jars_file[${i}]}
        
        mkdir -p ${dir}
        cp ${file} ${dir}
    
        mkdir -p ${dir}/src
        # java -jar cfr-0.152.jar --hideutf false ${file} --outputdir ${dir}/src
        java -cp /home/li/Software/idea-IU-222.4167.29/plugins/java-decompiler/lib/java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dgs=true ${file} ${dir}/src
    
        mkdir -p ${dir}/jars
        unzip ${file} -d ${dir}/jars
    done
}

# bash shell.bash clear
# bash shell.bash unjar

$@
