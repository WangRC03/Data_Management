-- 使用默认数据库
USE default;

-- 删除旧表（若存在）
DROP TABLE IF EXISTS retail_sales_2023_2024;

-- 创建 Hive 表（根据 CSV 结构）
CREATE TABLE retail_sales_2023_2024 (
    year INT,
    month STRING,
    category STRING,
    sales FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/maria_dev/ml-100k/retail_sales_2023_2024.csv' INTO TABLE retail_sales_2023_2024;

-- 查询 1：每月总销售额
SELECT year, month, SUM(sales) AS total_sales
FROM retail_sales_2023_2024
GROUP BY year, month
ORDER BY year, month;

-- 查询 2：类别年度销售额
SELECT category, year, SUM(sales) AS total_sales
FROM retail_sales_2023_2024
GROUP BY category, year
ORDER BY category, year;

-- 查询 3：销售额最多的5个类别
SELECT category, SUM(sales) AS total_sales
FROM retail_sales_2023_2024
GROUP BY category
ORDER BY total_sales DESC
LIMIT 5;

-- 查询 4：同比增长
WITH yearly_sales AS (
  SELECT year, SUM(sales) AS total_sales
  FROM retail_sales_2023_2024
  GROUP BY year
)
SELECT a.year, a.total_sales, b.total_sales AS last_year_sales,
       ROUND(((a.total_sales - b.total_sales) / b.total_sales) * 100, 2) AS growth_rate
FROM yearly_sales a
JOIN yearly_sales b ON a.year = b.year + 1
ORDER BY a.year;
