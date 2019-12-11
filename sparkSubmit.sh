#!/usr/bin/env bash

export TERM=xterm-color

export JAVA_HOME=/home/li/Software/jdk1.8.0_212
export SCALA_HOME=/home/li/Software/scala-2.11.12

export HADOOP_HOME=/home/li/Software/hadoop-3.2.0
export SPARK_HOME=/home/li/Software/spark-2.4.4-bin-without-hadoop

export HADOOP_CONF_DIR=/home/li/Software/hadoop-3.2.0/etc/hadoop
export SPARK_CONF_DIR=/home/li/Software/spark-2.4.4-bin-without-hadoop/conf

export SPARK_DIST_CLASSPATH=$(hadoop classpath)

jars=$SPARK_HOME/conf/:$SPARK_HOME/jars/*:$SPARK_DIST_CLASSPATH
spark_yarn_jars=$SPARK_HOME/jars/*

function start_shell_1() {
    $JAVA_HOME/bin/java -cp $jars -Dscala.usejavacp=true -Xmx1g org.apache.spark.deploy.SparkSubmit --conf spark.yarn.jars=$spark_yarn_jars --master yarn --class org.apache.spark.repl.Main spark-shell
}

function start_shell_2() {
    $JAVA_HOME/bin/java -cp $jars -Dscala.usejavacp=true -Xmx1g org.apache.spark.deploy.SparkSubmit --conf spark.yarn.jars=$spark_yarn_jars --master yarn --class org.apache.spark.repl.Main $SPARK_HOME/jars/spark-repl_2.11-2.4.4.jar
}

function execute_pi() {
    $JAVA_HOME/bin/java -cp $jars -Dscala.usejavacp=true -Xmx1g org.apache.spark.deploy.SparkSubmit --conf spark.yarn.jars=$spark_yarn_jars --master yarn-client --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_2.11-2.4.4.jar
}

start_shell_1
start_shell_2
execute_pi
