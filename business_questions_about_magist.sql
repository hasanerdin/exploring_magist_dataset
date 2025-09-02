-- In relation to the product
-- What categories of tech products does Magist have?
-- "audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony" 
SELECT 
	DISTINCT product_category_name_english
FROM 
	products p JOIN product_category_name_translation pcnt On p.product_category_name = pcnt.product_category_name;
    
-- How many products of these tech categories have been sold (within the time window of the database snapshot)? 
-- What percentage does that represent from the overall number of products sold?

-- TOTAL SOLD PRODUCT <NOT DISTINCT>
-- total  -> 15798	--> 14.02%

SELECT 
    COUNT(*) AS count_sold_product,
    CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM order_items), 2), "%") AS percentage_sold_product
FROM order_items oi LEFT JOIN products p USING(product_id)
					LEFT JOIN product_category_name_translation pcnt USING(product_category_name)
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony");

-- TOTAL SOLD DISTINCT PRODUCT
-- total  -> 3390	--> 10.29%

SELECT 
    COUNT(DISTINCT product_id) AS count_sold_product,
    CONCAT(ROUND(COUNT(DISTINCT product_id) * 100 / (SELECT COUNT(DISTINCT product_id) FROM order_items), 2), "%") AS percentage_sold_product
FROM order_items oi LEFT JOIN products p USING(product_id)
					LEFT JOIN product_category_name_translation pcnt USING(product_category_name)
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony");


-- What’s the average price of the products being sold?
-- $120.65
SELECT 
	AVG(price) AS average_price
FROM 
	order_items;
    
-- Are expensive tech products popular?
-- 71.48% of the products are priced under average price.
-- 28.52% of the products are priced over average price.
SELECT
	CASE
		WHEN price > 1000 THEN "Expensive"
        WHEN price > 100 THEN "Mid_range"
        ELSE "Cheap"
	END AS price_range,
    COUNT(*) AS count_of_product,
    CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM order_items), 2), "%") AS percentage_of_product
FROM order_items oi LEFT JOIN products p USING(product_id)
					LEFT JOIN product_category_name_translation pcnt USING(product_category_name)
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony" )
GROUP BY price_range
ORDER BY count_of_product DESC;

    
-- How many months of data are included in the magist database?
-- There are 25 total month. 
-- 2016 --> 3
-- 2017 --> 12
-- 2018 --> 10
SELECT 
	year_purchase,
	COUNT(*) AS number_of_months
FROM
	(SELECT 
		YEAR(order_purchase_timestamp) AS year_purchase,
		MONTH(order_purchase_timestamp) AS month_purchase,
		COUNT(*) AS total_product
	FROM 
		orders
	GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
	) AS year_month_table
GROUP BY year_purchase
ORDER BY number_of_months;
    
-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-- There are 3095 sellers.
-- There are 454 (14.67%) tech sellers.
SELECT 
	COUNT(*) AS number_of_sellers
FROM sellers;

SELECT 
	COUNT(DISTINCT s.seller_id) AS number_of_tech_sellers,
    CONCAT(ROUND(COUNT(DISTINCT s.seller_id) * 100 / (SELECT COUNT(*) FROM sellers), 2), "%") AS percentage_of_tech_sellers 
FROM 
	sellers s JOIN order_items oi ON s.seller_id = oi.seller_id
			  JOIN products p ON oi.product_id = p.product_id
			  JOIN product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony" );

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-- $13.5M total amount earned
-- $ 1.7M total tech earned (12.27%)
SELECT 
	ROUND(SUM(price), 2) AS total_amount_earned
FROM 
	order_items LEFT JOIN orders USING(order_id)
WHERE 
	order_status NOT IN ("unavailable", "canceled");

SELECT
	ROUND(SUM(price), 2) AS total_tech_earned,
    CONCAT(ROUND(SUM(price) * 100 / (SELECT SUM(price) FROM order_items), 2), "%") AS tech_percentage
FROM 
	order_items oi LEFT JOIN orders o USING(order_id)
				   LEFT JOIN products p USING(product_id)
				   LEFT JOIN product_category_name_translation pcnt USING(product_category_name)
WHERE 
	order_status NOT IN ("unavailable", "canceled") AND
    product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony" );
                                        
                                        
-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
-- $115.42 for all sellers
-- $151.67 for tech sellers
-- ROUND(AVG(average_year_month_income), 2) AS average_income
SELECT 
	*
FROM (
	SELECT 
		ROUND(AVG(price), 2) AS average_year_month_income
	FROM 
		order_items oi LEFT JOIN sellers s USING(seller_id)
						LEFT JOIN orders o USING(order_id)
	WHERE order_status NOT IN ("unavailable", "canceled")
	GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
) AS year_month_income_table;

SELECT 
	ROUND(AVG(average_year_month_income), 2) AS average_income
FROM (
	SELECT 
		ROUND(AVG(price), 2) AS average_year_month_income
	FROM 
		order_items oi JOIN sellers s USING(seller_id)
						JOIN orders o USING(order_id)
                        JOIN products p USING(product_id)
                        JOIN product_category_name_translation pcnt USING(product_category_name)
    WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony" )
	GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
) AS year_month_income_table;

-- What’s the average time between the order being placed and the product being delivered?
-- It takes around 12.5 days.
SELECT 
	ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 2) AS avg_time
FROM 
	orders;

-- How many orders are delivered on time vs orders delivered with a delay?
-- On Time: 89805	<93%>
-- Delayed:  6665	< 7%>
SELECT
	CASE
		WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN "Delayed"
        ELSE "On Time"
	END AS delivery_status,
    COUNT(DISTINCT order_id) AS order_count
FROM 
	orders
WHERE 
	order_status = "delivered" 
    AND order_estimated_delivery_date IS NOT NULL
    AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
-- Average weight of the delayed products are 2 kg it is not too high.
-- Also average dimensions of the delayed products are not so high (22.99 x 16.56 x 30.15 cm^3)
SELECT 
	CASE 
		WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 100 THEN "More than 100 Days"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 7 THEN "7 To 100 Days"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 4 THEN "4 To 7 Days"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 1 THEN "1 To 4 Days"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN "Less than 1 Day"
        ELSE "On Time"
	END AS delay_range,
    AVG(product_weight_g) AS avg_weight_g,
    MAX(product_weight_g) AS max_weight_g,
    MIN(product_weight_g) AS min_weight_g,
    SUM(product_weight_g) AS total_weight_g,
    COUNT(DISTINCT order_id) AS order_count
FROM orders o
	LEFT JOIN order_items USING(order_id)
	LEFT JOIN products p USING(product_id)
WHERE order_estimated_delivery_date IS NOT NULL
	AND order_delivered_customer_date IS NOT NULL
    AND order_status = "delivered"
GROUP BY delay_range
ORDER BY order_count DESC;

-- Figure out the percentage of all the processes in delivery.

SELECT 
	AVG(TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_approved_at)) AS avg_approve_time,
    AVG(TIMESTAMPDIFF(HOUR, order_approved_at, order_delivered_carrier_date)) AS avg_preparation_time,
    AVG(TIMESTAMPDIFF(HOUR, order_delivered_carrier_date, order_delivered_customer_date)) AS avg_cargo_time
FROM 
	orders;
    
    
    
    
    
    
    
    