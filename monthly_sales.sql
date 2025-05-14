-- 创建数据库（可选）
CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

-- 删除旧表（防止冲突）
DROP TABLE IF EXISTS retail_sales;

-- 创建表（请根据实际数据字段调整）
CREATE TABLE retail_sales (
    year INT,
    month STRING,
    category STRING,
    sales FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 加载数据（路径假设你已经上传CSV到HDFS）
LOAD DATA INPATH '/user/maria_dev/ml-100k/mrtssales92-present25.csv' INTO TABLE retail_sales;

-- 1. 每月总销售额
SELECT year, month, SUM(sales) AS total_sales
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;

-- 2. 各类别每年销售额
SELECT category, year, SUM(sales) AS total_sales
FROM retail_sales
GROUP BY category, year
ORDER BY category, year;

-- 3. 找出销售最多的类别（总和）
SELECT category, SUM(sales) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC
LIMIT 5;

-- 4. 销售额同比增长（简化版）
WITH yearly_sales AS (
    SELECT year, SUM(sales) AS total_sales
    FROM retail_sales
    GROUP BY year
)
SELECT a.year, a.total_sales, b.total_sales AS last_year_sales,
       ROUND(((a.total_sales - b.total_sales) / b.total_sales) * 100, 2) AS growth_rate
FROM yearly_sales a
JOIN yearly_sales b ON a.year = b.year + 1
ORDER BY a.year;

-- 5. 导出结果为CSV（可选，在HDFS中保存结果）
INSERT OVERWRITE DIRECTORY '/user/maria_dev/ml-100k/monthly_sales'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT year, month, SUM(sales) AS total_sales
FROM retail_sales
GROUP BY year, month;

-- 导出月度销售数据
INSERT OVERWRITE DIRECTORY '/user/maria_dev/hive_output_2023_2024_monthly_sales'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT year, month, SUM(sales) AS total_sales
FROM retail_sales_2023_2024
GROUP BY year, month;

-- 导出年度销售增长数据
INSERT OVERWRITE DIRECTORY '/user/maria_dev/hive_output_2023_2024_yearly_growth'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT year, total_sales, last_year_sales, growth_rate
FROM retail_sales_2023_2024_yearly_growth;

-- 导出按类别和年度销售数据
INSERT OVERWRITE DIRECTORY '/user/maria_dev/hive_output_2023_2024_category_year'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT category, year, SUM(sales) AS total_sales
FROM retail_sales_2023_2024
GROUP BY category, year;

-- 导出前 10 销售类别
INSERT OVERWRITE DIRECTORY '/user/maria_dev/hive_output_2023_2024_top_categories'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT category, SUM(sales) AS total_sales
FROM retail_sales_2023_2024
GROUP BY category
ORDER BY total_sales DESC
LIMIT 10;
