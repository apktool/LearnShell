#!/usr/bin/env bash

export TERM=xterm-color

export JAVA_HOME=/home/li/Software/jdk1.8.0_212
export SCALA_HOME=/home/li/Software/scala-2.12.8

export HADOOP_HOME=/home/li/Software/hadoop-3.2.0
export SPARK_HOME=/home/li/Software/spark-2.4.4-bin-without-hadoop-scala-2.12

export HADOOP_CONF_DIR=/home/li/Software/hadoop-3.2.0/etc/hadoop
export SPARK_CONF_DIR=/home/li/Software/spark-2.4.4-bin-without-hadoop-scala-2.12/conf

export SPARK_DIST_CLASSPATH=$(hadoop classpath)

java_jars=$SPARK_HOME/conf/:$SPARK_HOME/jars/*:$SPARK_DIST_CLASSPATH
spark_yarn_jars=$SPARK_HOME/jars/*

function start_shell_1() {
    $JAVA_HOME/bin/java -cp $java_jars -Dscala.usejavacp=true -Xmx1g org.apache.spark.deploy.SparkSubmit --conf spark.yarn.jars=$spark_yarn_jars --master yarn --class org.apache.spark.repl.Main spark-shell
}

function start_shell_2() {
    $JAVA_HOME/bin/java -cp $java_jars -Dscala.usejavacp=true -Xmx1g org.apache.spark.deploy.SparkSubmit --conf spark.yarn.jars=$spark_yarn_jars --master yarn --deploy-mode client --driver-memory 2g --executor-memory 4g --executor-cores 3 --class org.apache.spark.repl.Main $SPARK_HOME/jars/spark-repl_2.12-2.4.4.jar
}

function execute_pi() {
    $JAVA_HOME/bin/java -cp $java_jars -Dscala.usejavacp=true -Xmx1g org.apache.spark.deploy.SparkSubmit --conf spark.yarn.jars=$spark_yarn_jars --master yarn-client --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_2.12-2.4.4.jar
}

function execute_repl() {
    local app_path=/home/li/WorkSpace/LearnSpark/spark-repl/target/spark-repl-1.0-SNAPSHOT-my-assembly/spark-repl-1.0-SNAPSHOT
    cp -f $app_path/spark-repl-1.0-SNAPSHOT.jar $app_path/lib

    readonly spark_yarn_dist_jars=$(echo $app_path/lib/* | tr ' ' ,)

    $JAVA_HOME/bin/java -cp $java_jars -Dscala.usejavacp=true -Xmx1g org.apache.spark.deploy.SparkSubmit --conf spark.yarn.jars=$spark_yarn_jars --master yarn --deploy-mode client --driver-memory 2g --executor-memory 4g --executor-cores 3 --jars $spark_yarn_dist_jars --verbose --class com.spark.repl.Main $app_path/spark-repl-1.0-SNAPSHOT.jar
}

start_shell_1
start_shell_2
execute_pi
execute_repl
