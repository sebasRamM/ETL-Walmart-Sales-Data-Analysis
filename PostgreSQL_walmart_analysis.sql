SELECT * FROM walmart;

-- Count payment method
SELECT 
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method;

-- Count of total stores
SELECT 
	COUNT(DISTINCT branch)
FROM walmart;

-- Exploratory Data Analysis
-- 1. Find different payment method and number of transactions, number of quantity sold
SELECT 
	payment_method,
	COUNT(*) AS number_of_transictions,
	SUM(quantity) AS quantity_sold
FROM walmart
GROUP BY payment_method;

-- 2. Identify the highest-rated category in each branch, displaying the branch, category, avg rating
WITH cte AS(
	SELECT
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
	FROM walmart
	GROUP BY branch, category
)
SELECT * 
FROM cte
WHERE ranking = 1;

-- 3. Identify the busiest day for each branch based on the number of transactions
WITH cte2 AS(
	SELECT
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day,
		COUNT(*) AS number_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM walmart
	GROUP BY branch, day
	ORDER BY branch, ranking
)
SELECT *
FROM cte2
WHERE ranking = 1;

-- 4. Calculate the total quantity of items sold per payment method. List payment_method
SELECT 
	payment_method,
	SUM(quantity) AS quantity_sold
FROM walmart
GROUP BY payment_method;

/* 5. Determine the average, minimum and maximum rating of products for each city. List the city,average_rating
min_rating and max_rating*/
SELECT
	city,
	category,
	AVG(rating) AS average_rating,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category;

/* 6. Calculate the total profit for each category by 
considering total_profit as (unit_price * quantity * profit_margin)*/
SELECT
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category;

-- 7. Determine the most common payment method for each branch. Display branch and the preferred_payment_method
WITH cte3 AS(
	SELECT
		branch,
		payment_method,
		COUNT(*) AS total_trand,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(payment_method) DESC) AS ranking
	FROM walmart
	GROUP BY branch, payment_method
)
SELECT *
FROM cte3
WHERE ranking = 1;

-- 8. Categorize sales into 3 groups MORNING, AFTERNOON, EVENING. Fond out which of the shift and number of invoices
SELECT
	branch,
	CASE
	WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'MORNING'
	WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 13 AND 17 THEN 'AFTERNOON'
	ELSE 'EVENING'
	END AS shift,
	COUNT(*) AS number_of_invoice
FROM walmart
GROUP BY branch, shift
ORDER BY branch, number_of_invoice DESC;

/* 9. Identify 5 branch with highest decrease ratio in revenue compare to last year 
(current year 2023 and last year 2022) */
WITH revenue_2022 AS(
	SELECT
		branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY branch
),

revenue_2023 AS(
	SELECT
		branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY branch
)

SELECT
	ly.branch,
	ly.revenue AS last_year_revenue,
	cy.revenue AS current_year_revenue,
	ROUND((ly.revenue - cy.revenue)::numeric/ly.revenue::numeric * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 ly
JOIN revenue_2023 cy
ON ly.branch = cy.branch
WHERE ly.revenue > cy.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

















