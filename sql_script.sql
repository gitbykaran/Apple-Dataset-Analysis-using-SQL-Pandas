use apple_db;

-- Find the number of stores in each country. 

CREATE VIEW Stores_Per_Country AS 
SELECT 
country,
COUNT(store_id) AS cnt
FROM stores
GROUP BY country
ORDER BY COUNT(store_id) desc;


-- Calculate the total number of units sold by each store.


CREATE VIEW Total_Units_Sold_Per_Store as
SELECT 
s.store_name,
SUM(sl.quantity) AS units_sold
FROM stores s JOIN sales sl 
ON s.store_id = sl.store_id
GROUP BY s.store_name;


-- Identify how many sales occurred in December 2023.


CREATE VIEW December_2023_Sales AS 
SELECT
'December 2023' AS Date, 
SUM(quantity) sales
FROM sales
WHERE  MONTH(sale_date) = 12 AND YEAR(sale_date) = 2023 ;


-- Determine how many stores have never had a warranty claim filed.

CREATE VIEW Stores_With_No_Warranty AS 
SELECT COUNT(*) AS cnt FROM stores 
WHERE store_id NOT IN (
						SELECT DISTINCT store_id
						FROM sales s 
						RIGHT JOIN warranty w 
						ON s.sale_id = w.sale_id
						);


-- Calculate the percentage of warranty claims marked as "Warranty Void". 


CREATE VIEW Warranty_Void_Percentage AS 
SELECT 
(COUNT(claim_id)/(SELECT COUNT(*) FROM warranty)) * 100 AS percentage
FROM warranty
WHERE repair_status = 'Warranty Void'


-- Identify which store had the highest total units sold in the last year

CREATE VIEW Store_Most_Units_Sold AS 
SELECT 
s.product_id,
st.store_name,
SUM(s.quantity) as units 
FROM sales s JOIN stores st
ON s.store_id = st.store_id
WHERE YEAR(s.sale_date) = 2024
GROUP BY s.product_id , st.store_name
ORDER BY SUM(s.quantity) DESC
LIMIT 1


-- Count the number of unique products sold in the last year. 


CREATE VIEW Unique_Product_Sold AS 
SELECT
COUNT(DISTINCT product_id) AS unique_products
FROM sales 
WHERE YEAR(sale_date) = 2024;


-- Find the average price of products in each category.


CREATE VIEW Avg_Price_Per_Category AS
SELECT 
p.category_id,
c.category_name,
AVG(p.price) AS avg_price
FROM products p JOIN categories c 
ON p.category_id = c.category_id
GROUP BY p.category_id ,c.category_name ;


-- How many warranty claims were filed in 2022? 

CREATE VIEW  No_Claims_2022 AS 
SELECT COUNT(*) cnt
FROM warranty
WHERE YEAR(claim_date) = 2022


-- For each store, identify the best-selling day based on highest quantity sold


CREATE VIEW Store_Best_Selling_Day AS 
SELECT * 
FROM 
(SELECT 
store_id,
WEEKDAY(sale_date) day,
SUM(quantity) units_sold,
RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rnk
FROM sales
GROUP BY store_id,WEEKDAY(sale_date)
) AS t1
WHERE rnk = 1;


-- Identify the least selling product in each country for each year based on total units sold.


CREATE VIEW Least_Selling_Product_Country AS
WITH product_rank
AS
(SELECT 
p.product_name,
st.country,
SUM(s.quantity) units_sold,
RANK() OVER(PARTITION BY st.country ORDER BY SUM(s.quantity)) AS rnk
FROM sales s JOIN products p 
ON s.product_id = p.product_id
JOIN stores st 
ON s.store_id = st.store_id
GROUP BY 2,1
)
SELECT *
FROM product_rank
WHERE rnk = 1;


-- Calculate how many warranty claims were filed within 180 days of a product sale.


CREATE VIEW Warranty_Claims_180 AS
WITH claims AS 
(SELECT 
w.*,
s.sale_date,
DATEDIFF(w.claim_date,s.sale_date) AS day_diff
FROM warranty w
LEFT JOIN sales s
ON w.sale_id = s.sale_id
WHERE DATEDIFF(w.claim_date,s.sale_date) > 0 AND DATEDIFF(w.claim_date,s.sale_date) <=180
)
SELECT COUNT(*) AS cnt FROM claims


-- Determine how many warranty claims were filed for products launched in the last two years.

CREATE VIEW Warranty_Claims_2_Year AS
SELECT COUNT(w.claim_id) as cnt
FROM warranty w 
JOIN sales s 
ON w.sale_id = s.sale_id
JOIN products p
ON s.product_id = p.product_id
WHERE YEAR(p.launch_date) = 2022


-- List the months in the last three years where sales exceeded 1,000 units in the USA.


CREATE VIEW Months_Sales_Above_1000_3_Years AS 
SELECT 
MONTH(s.sale_date) AS month,
SUM(s.quantity) AS units
FROM sales s
JOIN stores st 
ON s.store_id = st.store_id
WHERE st.country = 'United States of America' 
AND YEAR(s.sale_date) IN (2024,2023,2022)
GROUP BY MONTH(s.sale_date)
HAVING SUM(s.quantity) > 1000


-- Identify the product category with the most warranty claims filed in the last two years.


CREATE VIEW Product_Category_Most_Claims_Last_2_Years AS 
SELECT 
ct.category_name,
COUNT(w.claim_id) claims
FROM warranty w 
LEFT JOIN sales s
ON w.sale_id = s.sale_id
JOIN products p 
ON p.product_id = s.product_id
JOIN categories ct 
ON ct.category_id = p.category_id
WHERE YEAR(w.claim_date) IN(2023,2024) 
GROUP BY ct.category_name
ORDER BY 2 DESC


-- Determine the percentage chance of receiving warranty claims after each purchase for each country.

CREATE VIEW Claim_Percentage_After_Purchase_Country AS 
SELECT 
country,
(total_units_sold/total_claims) * 100  AS claim_ratio
FROM
(SELECT 
st.country,
SUM(s.quantity) total_units_sold,
SUM(w.claim_id) total_claims
FROM sales s
JOIN stores st 
ON s.store_id = st.store_id
LEFT JOIN warranty w 
ON s.sale_id = w.sale_id
GROUP BY 1
) t1
GROUP BY 1


-- Analyze the year-by-year growth ratio for each store.


CREATE VIEW YoY_Growth_Ratio_Store AS
WITH yearly_sales 
AS
(SELECT 
s.store_id,
st.store_name,
YEAR(s.sale_date) as year,
SUM(s.quantity * p.price) as current_year_sales
FROM sales s 
JOIN products p
ON s.product_id = p.product_id
JOIN stores st 
ON st.store_id = s.store_id
GROUP BY 1,2,3
ORDER BY 2,3 
),
growth_ratio 
AS
(
SELECT 
store_id,
store_name,
year,
current_year_sales,
LAG(current_year_sales,1) OVER(PARTITION BY store_name ORDER BY year) AS previous_year_sale
FROM yearly_sales
)
SELECT
store_id,
store_name,
year,
current_year_sales,
previous_year_sale,
((current_year_sales - previous_year_sale)/previous_year_sale) * 100 AS growth
FROM growth_ratio


-- Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range


CREATE VIEW Claims_Segmented_Price_Range AS 
WITH range_table AS 
(SELECT 
p.product_id,
p.price,
w.claim_id,
CASE 
	WHEN p.price < 500 THEN 'Cheap Product'
    WHEN p.price BETWEEN 500 AND 1500 THEN 'Affordable Product'
    ELSE 'Expensive'
    END AS price_range
FROM warranty w
LEFT JOIN sales s 
ON w.sale_id = s.sale_id
JOIN products p 
ON p.product_id = s.product_id
)
SELECT 
price_range,
COUNT(claim_id) claims
FROM range_table
GROUP BY 1 


-- Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.


CREATE VIEW Store_High_PaidRepaired_Percentage AS
WITH claims_paid_repaired AS 
(SELECT 
s.store_id,
COUNT(*) paid_repaired 
FROM warranty w
LEFT JOIN sales s 
ON w.sale_id = s.sale_id
WHERE w.repair_status = 'Paid Repaired'
GROUP BY 1
),
total_claims AS 
(SELECT 
s.store_id,
COUNT(*) no_claims 
FROM warranty w
LEFT JOIN sales s 
ON w.sale_id = s.sale_id
GROUP BY 1
)
SELECT 
tc.store_id,
pc.paid_repaired,
tc.no_claims ,
(pc.paid_repaired/tc.no_claims)*100 paid_claims_percentage
FROM total_claims tc
JOIN claims_paid_repaired pc
ON tc.store_id = pc.store_id


-- Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.


CREATE VIEW Monthly_Running_Total_Store AS 
WITH monthly_sales AS 
(SELECT 
s.store_id,
YEAR(s.sale_date) AS year,
MONTH(s.sale_date) AS month,
SUM(s.quantity * p.price) sales
FROM sales s
JOIN products p 
ON s.product_id = p.product_id
GROUP BY s.store_id ,YEAR(s.sale_date),MONTH(s.sale_date)
ORDER BY 1 ,2 ,3 
)
SELECT 
store_id,
year,
month,
SUM(sales) OVER(PARTITION BY store_id ORDER BY year,month) AS running_total
FROM monthly_sales

