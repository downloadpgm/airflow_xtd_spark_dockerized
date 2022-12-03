trap "{ echo Stopping play app; /root/stop_airflow.sh; exit 0; }" SIGTERM

export JAVA_HOME=/usr/local/jre1.8.0_181
export HADOOP_CONF_DIR=/usr/local/spark-2.3.2-bin-hadoop2.7/conf

airflow webserver -D

airflow scheduler
