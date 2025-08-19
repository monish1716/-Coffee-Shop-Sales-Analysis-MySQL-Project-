CREATE DATABASE COFFEE_DB;
USE COFFEE_DB;

SELECT * FROM COFFEE_SHOP_SALES;

SELECT count(*) FROM COFFEE_SHOP_SALES;

DESC COFFEE_SHOP_SALES;

#CONVERT DATE (transaction_date) COLUMN TO PROPER DATE FORMAT

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

#ALTER DATE (transaction_date) COLUMN TO DATE DATA TYPE

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

DESC COFFEE_SHOP_SALES;

#CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

#ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

DESC COFFEE_SHOP_SALES;

#TOTAL SALES

SELECT SUM(unit_price*transaction_qty) AS Total_sale
FROM COFFEE_SHOP_SALES;

# for specific month 

SELECT SUM(unit_price*transaction_qty) AS Total_sale
FROM COFFEE_SHOP_SALES
WHERE 
MONTH(transaction_date) = 5; -- MAY MONTH

SELECT ROUND(SUM(unit_price*transaction_qty),1) AS Total_sale
FROM COFFEE_SHOP_SALES
WHERE 
MONTH(transaction_date) = 3; -- MARCH MONTH

#TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT 
    MONTH(transaction_date) AS month, -- NUMBER OF MONTH
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,-- TOTAL SALES COLUMN
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- MONTH SALE DIFFERENCE
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- DIVIDION BY PM SALE
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- PERCENTAGE
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

#TOTAL ORDERS

SELECT COUNT(TRANSACTION_ID) AS Total_sale
FROM COFFEE_SHOP_SALES
WHERE 
MONTH(transaction_date) = 3; -- FOR MARCH MONTH 

#TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
#TOTAL QUANTITY SOLD

SELECT month(transaction_date) as month,SUM(TRANSACTION_QTY) AS Total_quantity_sold
FROM COFFEE_SHOP_SALES
WHERE 
MONTH(transaction_date) = 5
group by 
	month(transaction_date);
    
#TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH  

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_qty)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);  
    
#CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS

SELECT 
	CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS Total_Sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS Total_Qty_sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS Total_Order
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18';

#SALES BY WEEKDAY / WEEKEND:

-- WEEKENDS - Sat-Sun
-- WEEKDAYS - Mon-Fri

#Sun = 1
#Mon = 2 
#.
#.
#Sat = 7;

SELECT 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'WEEKENDS'
    ELSE 'WEEKDAYS'
    END AS DAY_TYPE,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS Total_sales 
FROM coffee_shop_sales
where month(transaction_date) = 2 -- FEB month
group by 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'WEEKENDS'
    ELSE 'WEEKDAYS'
    END ;
    
#SALES BY STORE LOCATION

SELECT 
	store_location,
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS TOTAL_SALES
FROM COFFEE_SHOP_SALES
WHERE MONTH(transaction_date) = 5 -- MAY MONTH
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

#DAILY SALES ANALYSIS WITH AVERAGE LINE 
#SALES AVG OF A PARTICULAR MONTH
SELECT 
	CONCAT(ROUND(AVG(TOTAL_SALES)/1000,1),'K') AS AVG_SALES
FROM 
(
	SELECT SUM(unit_price * transaction_qty) AS TOTAL_SALES
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5 -- MAY MONTH
    GROUP BY transaction_date
    ) AS INTERNAL_QUERY;
    
#SALES OF EVERY DAY OF THE MONTH

SELECT 
	DAY(transaction_date) AS DAY_OF_MONTH,
    SUM(unit_price * transaction_qty) AS TOTAL_SALES
    FROM COFFEE_SHOP_SALES
    WHERE MONTH(transaction_date) = 5 
    GROUP BY DAY(transaction_date)
    order by DAY(transaction_date);
    
#COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;

#SALES BY PRODUCT CATEGORY

SELECT 
	product_category,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY PRODUCT_CATEGORY
ORDER BY SUM(unit_price * transaction_qty) DESC;

#SALES BY PRODUCTS (TOP 10)

SELECT 
	product_type,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'COFFEE'
GROUP BY PRODUCT_TYPE
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

#SALES BY DAY | HOUR

SELECT 
SUM(unit_price * transaction_qty) AS TOTAL_SALES,
SUM(transaction_qty) AS TOTAL_QTY_SOLD,
COUNT(*)
FROM COFFEE_SHOP_SALES
WHERE MONTH(transaction_date) = 5 -- MAY
AND dayofweek(transaction_date) = 1 -- SUNDAY
AND hour(transaction_time) = 14; -- HOUR NO 14

#TO GET SALES FOR ALL HOURS FOR MONTH OF MAY

SELECT 
	hour(transaction_time),
    SUM(unit_price * transaction_qty) AS TOTAL_SALES
FROM COFFEE_SHOP_SALES 
WHERE MONTH(transaction_date)=5 -- MAY MONTH
GROUP BY HOUR(transaction_time)
order by HOUR(transaction_time);

#TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
    
select 























