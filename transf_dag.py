from datetime import datetime
from airflow.models import DAG
from airflow.contrib.operators.spark_submit_operator import SparkSubmitOperator

with DAG(dag_id="transf_dag", start_date=datetime.now()) as dag:
    transf_proc = SparkSubmitOperator(
        task_id="transf_proc",
        application=("/root/transform.py"),
        name="transf_proc"
        )