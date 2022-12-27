# Airflow running into Spark Standalone cluster in Docker

Apache Airflow is an open-source, workflow management processing system used to coordinate big data workloads.

In this demo, a Airflow container uses a Spark Standalone cluster as a resource management and job scheduling technology to perform distributed data processing.

This Docker image contains Airflow and Spark binaries prebuilt and uploaded in Docker Hub.

## Build Airflow/Spark image
```shell
$ docker image build -t mkenjis/airflow_xtd_spark_img .
$ docker login   # provide user and password
$ docker image push mkenjis/airflow_xtd_spark_img
```

## Shell Scripts Inside 

> run_airflow.sh

Sets up the environment for Spark client by executing the following steps :
- starts the Webserver service for UI Airflow 
- starts the Scheduler service


## Start Swarm cluster

1. start swarm mode in node1
```shell
$ docker swarm init --advertise-addr <IP node1>
$ docker swarm join-token worker  # issue a token to add a node as worker to swarm
```

2. add 3 more workers in swarm cluster (node2, node3, node4)
```shell
$ docker swarm join --token <token> <IP nodeN>:2377
```

3. label each node to anchor each container in swarm cluster
```shell
docker node update --label-add hostlabel=hdpmst node1
docker node update --label-add hostlabel=hdp1 node2
docker node update --label-add hostlabel=hdp2 node3
docker node update --label-add hostlabel=hdp3 node4
```

4. create an external "overlay" network in swarm to link the 2 stacks (hdp and spk)
```shell
docker network create --driver overlay mynet
```

5. start the Hadoop cluster (with HDFS and YARN)
```shell
$ docker stack deploy -c docker-compose-hdp.yml hdp
$ docker stack ps hdp
jeti90luyqrb   hdp_hdp1.1     mkenjis/ubhdpclu_vol_img:latest   node2     Running         Preparing 39 seconds ago             
tosjcz96hnj9   hdp_hdp2.1     mkenjis/ubhdpclu_vol_img:latest   node3     Running         Preparing 38 seconds ago             
t2ooig7fbt9y   hdp_hdp3.1     mkenjis/ubhdpclu_vol_img:latest   node4     Running         Preparing 39 seconds ago             
wym7psnwca4n   hdp_hdpmst.1   mkenjis/ubhdpclu_vol_img:latest   node1     Running         Preparing 39 seconds ago
```

3. start airflow with spark client
```shell
$ docker stack deploy -c docker-compose.yml spk
$ docker service ls
ID             NAME           MODE         REPLICAS   IMAGE                                  PORTS
lkm9m7w4tcwg   spk_airflow    replicated   1/1        mkenjis/airflow_xtd_spark_img:latest   *:8080->8080/tcp
```

## Load dataset in HDFS

1. access hadoop master node, create HDFS directory and copy dataset in this directory
```shell
$ docker container ls   # check which <container ID> is running the hadoop master constainer
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS      NAMES
a62b5898628c   mkenjis/ubhdp_img:latest   "/usr/bin/supervisord"   5 minutes ago   Up 5 minutes   9000/tcp   hdp_hadoop.1.efxw2rbw83ypoz0bqizd7nczx

$ docker container exec -it <hdp_mst ID> bash

$ hdfs dfs -mkdir /data 
$ hdfs dfs -put /root/staging/wine_quality.csv /data
$ hdfs dfs -ls /data
Found 1 items
-rw-r--r--   1 root supergroup      84199 2022-05-10 14:55 /data/wine_quality.csv
```

## Loading Python scripts in Airflow

1. copy Python scripts to airflow container
```shell
$ docker container ls   # run it in each node and check which <container ID> is running the airflow constainer
CONTAINER ID   IMAGE                                  COMMAND                  CREATED          STATUS          PORTS                                          NAMES
af30de6ade07   mkenjis/airflow_xtd_spark_img:latest   "/usr/bin/supervisord"   13 minutes ago   Up 13 minutes   8080/tcp                                       airf_airflow.1.qmhzon64szjb0fnrlucnxe1mn
3b591e008a92   mkenjis/ubspkcluster_img:latest        "/usr/bin/supervisord"   15 minutes ago   Up 15 minutes   4040/tcp, 7077/tcp, 8080-8082/tcp, 10000/tcp   airf_spk1.1.ir53adba58f2x6l2hdl2eckw7

$ docker container cp transform.py <airflow ID>:/root
$ docker container cp transf_dag.py <airflow ID>:/root/airflow/dags/transf_dag.py
```

2. edit spark-defaults.conf
```shell
$ docker container exec -it <airflow ID> bash

$ vi $SPARK_HOME/conf/spark-defaults.conf
spark.driver.memory  1024m
spark.yarn.am.memory 1024m
spark.executor.memory  1536m
```

2. edit files with proper settings 
```shell
$ vi transform.py  # change HDFS path pointing to hadoop container (in the script hdfs://<hdpmst_id>:9000)

$ vi $SPARK_HOME/conf/spark-env.sh
export JAVA_HOME=/usr/local/jre1.8.0_181
```

## Execute the following steps in Airflow UI

![AIRFLOW login](docs/airflow_login.png)

![AIRFLOW home](docs/airflow_home.png)

![AIRFLOW spark_connection](docs/airflow_spark_connection.png)

![AIRFLOW setup_spark_connection](docs/airflow_setup_spark_connection.png)

![AIRFLOW enable_dag](docs/airflow_enable_dag.png)

![AIRFLOW run_dag](docs/airflow_run_dag.png)

![AIRFLOW run_dag_result](docs/airflow_run_dag_result.png)

![AIRFLOW run_dag_log](docs/airflow_run_dag_log.png)
