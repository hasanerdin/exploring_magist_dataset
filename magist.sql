-- How many orders are there in the dataset?
-- 99441
SELECT 
	COUNT(*) 
FROM orders; 

-- Are orders actually delivered?
-- 'delivered','96478'
-- 'unavailable','609'
-- 'shipped','1107'
-- 'canceled','625'
-- 'invoiced','314'
-- 'processing','301'
-- 'approved','2'
-- 'created','5'
SELECT 
	order_status, 
    COUNT(*) AS count_by_status 
FROM orders 
GROUP BY order_status;

-- Is Magist having user growth?
-- Focus 12. month of each year
-- Bad start and bad end
-- 2018 the company does not grow totally
-- Growth speed of the company decrease in the last 5 months 
-- From the 1st month of the 2017 to 6th month of the 2018 their customer number is increasing or stable. But after that date there is a decreasement.
SELECT 
	YEAR(order_purchase_timestamp) AS order_year, 
    MONTH(order_purchase_timestamp) AS order_month, 
    COUNT(*) AS count_of_orders 
FROM orders 
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

SELECT 
	YEAR(order_purchase_timestamp) AS order_year, 
    MONTH(order_purchase_timestamp) AS order_month, 
    ROUND(SUM(price), 2) AS revenue
FROM order_items JOIN orders USING(order_id)
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- How many products are there on the products table? 
-- 32951
-- Huge portfolio of products
SELECT
	COUNT(product_id)
FROM products;

-- Which are the categories with the most products?
-- bed_bath_table, sports_leisure, furniture_decor, health_beauty, housewares
SELECT
	product_category_name_english AS product_category,
    COUNT(*) AS count_of_product
FROM products p 
	JOIN product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
GROUP BY product_category
ORDER BY count_of_product DESC;

-- How many of those products were present in actual transactions? 
-- Total 112650
-- There are 74 different product categories.
-- Best-selling products are "bed_bath_table", "health_beauty", "sports_leisure", "furniture_decor", "computer_accessories"
SELECT 
	count(DISTINCT product_id) AS n_products
FROM
	order_items;

-- What’s the price for the most expensive and cheapest products? 
-- The price of most expensive product is $6735
-- The price of most cheapest product is $0.85
SELECT 
	MAX(price) AS highest_price,
    MIN(price) AS lowest_price
FROM 
	order_items;

-- What are the highest and lowest payment values?
-- The highest payment is $13664.1
-- The lowest payment is $0
-- The highest paid order is $13664.1order_items
SELECT 
	MAX(payment_value) AS highest_payment,
    MIN(payment_value) AS lowest_payment
FROM 
	order_payments;
