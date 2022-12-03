WEBSVR_ID=`ps -ef | grep "airflow webserver" | grep -wv grep | awk '{ print $2 }'`
SCHED_ID=`ps -ef | grep "airflow scheduler" | grep python | grep -wv grep | awk '{ print $2 }'`

kill -TERM ${WEBSVR_ID} ${SCHED_ID}
