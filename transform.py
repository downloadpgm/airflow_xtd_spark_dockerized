from pyspark.sql import SparkSession

if __name__ == "__main__":
    spark = SparkSession.builder.getOrCreate()

    df = spark.read.format("csv").option("header", True).option("inferSchema", True).option("sep",";").load("hdfs://<container_id>:9000/data/wine_quality.csv")

    df.printSchema()
    df.show()