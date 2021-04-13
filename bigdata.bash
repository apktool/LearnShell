#####################################
#
# apache zookeeper
# shell.bash
#
#####################################

#!/usr/local/env bash

bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit

declare current=$(pwd)
echo ${current}
cd ${current}

function start() {
    bin/zkServer.sh start
}

function stop() {
    bin/zkServer.sh stop
}

$@

#####################################
#
# apache hadoop
# shell.bash
#
#####################################

#!/usr/local/env bash

bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit

declare current=$(pwd)
echo ${current}
cd ${current}

function init() {
    bin/hdfs namenode -format
}

function start() {
    sbin/start-dfs.sh
    # sbin/start-yarn.sh
}

function stop() {
    sbin/stop-dfs.sh
    # sbin/stop-yarn.sh
}

$@

#####################################
#
# apache hbase
# shell.bash
#
#####################################

#!/usr/local/env bash

bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit

declare current=$(pwd)
echo ${current}
cd ${current}

function start() {
    bin/start-hbase.sh
    # bin/hbase-daemon.sh --config ${current}/conf start master
    # bin/hbase-daemons.sh --config ${current}/conf --hosts ${current}/conf/backup-masters start master-backup
    # bin/hbase-daemons.sh --config ${current}/conf --hosts ${current}/conf/regionservers start regionserver
}

function stop() {
    bin/stop-hbase.sh
    # bin/hbase-daemons.sh --config ${current}/conf --hosts ${current}/conf/regionservers stop regionserver
    # bin/hbase-daemons.sh --config ${current}/conf --hosts ${current}/conf/backup-masters stop master-backup
    # bin/hbase-daemon.sh --config ${current}/conf stop master
}

$@

#####################################
#
# apache alluxio
# shell.bash
#
#####################################

#!/usr/local/env bash

bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "$bin" > /dev/null || exit; pwd)
cd "$bin" || exit

declare current=$(pwd)
echo ${current}
cd ${current}

function init() {
    bin/alluxio copyDidr conf
    bin/alluxio-mount.sh Umount workers
    bin/alluxio-mount.sh Mount workers
    bin/alluxio validateEnv master
    bin/alluxio validateEnv worker
    bin/alluxio format
}

function start() {
    bin/alluxio-start.sh all
}

function stop() {
    bin/alluxio-stop.sh all
}

$@
