FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=US/Central

RUN apt-get update && apt-get install -y supervisor vim iputils-ping python3-pip

RUN pip3 install apache-airflow
RUN pip3 install apache-airflow-providers-apache-spark

WORKDIR /root
RUN airflow db init
RUN airflow users create --username admin --firstname marcelok --lastname marcelok --role Admin --email mkenjis@gmail.com --password xxxxxx

WORKDIR /usr/local

# git clone https://github.com/mkenjis/apache_binaries
ADD jre-8u181-linux-x64.tar.gz .
# wget https://archive.apache.org/dist/spark/spark-2.3.2/spark-2.3.2-bin-hadoop2.7.tgz
ADD spark-2.3.2-bin-hadoop2.7.tgz .

WORKDIR /root
RUN echo "" >>.bashrc \
 && echo 'export JAVA_HOME=/usr/local/jre1.8.0_181' >>.bashrc \
 && echo 'export CLASSPATH=$JAVA_HOME/lib' >>.bashrc \
 && echo 'export PATH=$PATH:.:$JAVA_HOME/bin' >>.bashrc \
 && echo "" >>.bashrc \
 && echo 'export SPARK_HOME=/usr/local/spark-2.3.2-bin-hadoop2.7' >>.bashrc \
 && echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HADOOP_HOME/lib/native' >>.bashrc \
 && echo 'export HADOOP_CONF_DIR=$SPARK_HOME/conf' >>.bashrc \
 && echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >>.bashrc

COPY create_conf_files.sh .
RUN chmod +x create_conf_files.sh

COPY run_airflow.sh .
RUN chmod +x run_airflow.sh

COPY stop_airflow.sh .
RUN chmod +x stop_airflow.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord"]