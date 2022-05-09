from pyspark.sql import SparkSession

if __name__ == "__main__":
    spark = SparkSession.builder.getOrCreate()

    df = spark.read.format("csv").option("header", True).option("inferSchema", True).load("/home/marcelok/datasets_heart_attack.csv")

    df.printSchema()
    df.show()