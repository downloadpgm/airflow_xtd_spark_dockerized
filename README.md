# Airflow running into Spark Standalone cluster in Docker

Apache Airflow is an open-source, workflow management processing system used to coordinate big data workloads.

In this demo, a Airflow container uses a Spark Standalone cluster as a resource management and job scheduling technology to perform distributed data processing.

This Docker image contains Spark binaries prebuilt and uploaded in Docker Hub.

## Steps to Build Airflow image
```shell
$ git clone https://github.com/mkenjis/apache_binaries
$ wget https://archive.apache.org/dist/spark/spark-2.3.2/spark-2.3.2-bin-hadoop2.7.tgz
$ docker image build -t mkenjis/airflow_xtd_spark_img
$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: mkenjis
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
$ docker image push mkenjis/airflow_xtd_spark_img
```

## Shell Scripts Inside 

> run_airflow.sh

Sets up the environment for Spark client by executing the following steps :
- starts the Webserver service for UI Airflow 
- starts the Scheduler service


## Initial Steps on Docker Swarm

To start with, start Swarm mode in Docker in node1
```shell
$ docker swarm init
Swarm initialized: current node (xv7mhbt8ncn6i9iwhy8ysemik) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token <token> <IP node1>:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

Add more workers in cluster hosts (node2, node3, ...) by joining them to manager.
```shell
$ docker swarm join --token <token> <IP node1>:2377
```

Change the workers as managers in node2, node3, ...
```shell
$ docker node promote node2
$ docker node promote node3
$ docker node promote ...
```

Start Docker stack using docker-compose.yml
```shell
$ docker stack deploy -c docker-compose.yml spark
```

Check the status of each service started
```shell
$ docker service ls
ID             NAME             MODE         REPLICAS   IMAGE                             PORTS
t3s7ud9u21hr   spark_spk_mst    replicated   1/1        mkenjis/ubspkcluster_img:latest   
mi3w7xvf9vyt   spark_spk_wkr1   replicated   1/1        mkenjis/ubspkcluster_img:latest   
xlg5ww9q0v6j   spark_spk_wkr2   replicated   1/1        mkenjis/ubspkcluster_img:latest   
ni5xrb60u71i   spark_spk_wkr3   replicated   1/1        mkenjis/ubspkcluster_img:latest
```

## Loading Python scripts in Airflow Docker container

Identify which Docker container started as Airflow and logged into it
```shell
$ docker container ls   # run it in each node and check which <container ID> is running the Hadoop master constainer
CONTAINER ID   IMAGE                         COMMAND                  CREATED              STATUS              PORTS      NAMES
71717fcd5a01   mkenjis/ubspkcluster_img:latest   "/usr/bin/supervisord"   14 minutes ago   Up 14 minutes   4040/tcp, 7077/tcp, 8080-8082/tcp, 10000/tcp   spark_spk_wkr2.1.bf8tsqv5lyfa4h5i8utwvtpch
464730a41833   mkenjis/ubspkcluster_img:latest   "/usr/bin/supervisord"   14 minutes ago   Up 14 minutes   4040/tcp, 7077/tcp, 8080-8082/tcp, 10000/tcp   spark_spk_mst.1.n01a49esutmbgv5uum3tdsm6p

$ docker container exec -it <container ID> bash
```

Inside the Airflow container, load Python scripts as below
```shell
$ spark-shell --master spark://<hostname>:7077
2021-12-13 15:09:50 WARN  NativeCodeLoader:62 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Spark context Web UI available at http://464730a41833:4040
Spark context available as 'sc' (master = spark://464730a41833:7077, app id = app-20211213150958-0000).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.3.2
      /_/
         
Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_181)
Type in expressions to have them evaluated.
Type :help for more information.

scala> 
```