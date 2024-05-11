-- Danny Ma Data Bank SQL Challenge
-- A. Customer Node Exploration

-- 1. How many unique nodes are there on the Data Bank system?
SELECT count( DISTINCT node_id)
FROM customer_nodes;

-- 2. What is the number of nodes per region?
SELECT r.region_name,
        count( DISTINCT cn.node_id) AS nodes_per_region
FROM customer_nodes cn
JOIN regions r
ON cn.region_id = r.region_id
GROUP BY cn.region_id
ORDER BY cn.region_id;

-- 3. How many customers are allocated to each region?
SELECT r.region_name,
        count( DISTINCT cn.customer_id) AS customer_per_person
FROM customer_nodes cn
JOIN regions r
ON cn.region_id = r.region_id
GROUP BY cn.region_id
ORDER BY cn.region_id;

-- 4. How many days on average are customers reallocated to a different node?
-- we could clean the data, since all dates are between January to April 2020
/*DATA CLEANING
update customer_nodes
set end_date = '9999-12-31'
where end_date = '2020-12-31';
*/
-- first method
SELECT avg(datediff(end_date,
        start_date)) AS Average_days
FROM customer_nodes
WHERE end_date <> '9999-12-31';
-- Second method
SELECT sum(datediff(end_date,start_date))/ count(*) AS Average_days
FROM customer_nodes
WHERE end_date <> '9999-12-31';

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
-- what are the aboves for the avg reallocation days for each region
WITH part_by_region AS (SELECT cn.region_id,
datediff(end_date,start_date) AS diff_date,
ROW_NUMBER() OVER(PARTITION BY cn.region_id ORDER BY  datediff(end_date,start_date)) AS partition_region
FROM customer_nodes cn
JOIN regions r
ON cn.region_id = r.region_id
WHERE end_date <> '9999-12-31'),
        

percentile AS (
	SELECT *,
		   ROUND(PERCENT_RANK() over(PARTITION by region_id ORDER BY  partition_region),2) AS percentile_r
	FROM part_by_region)

SELECT r.region_name,
	   (SELECT round(sum(diff_date)/Count(*))
		FROM percentile
		WHERE percentile_r = 0.5) AS median,
	   (SELECT round(sum(diff_date)/Count(*))
		FROM percentile
		WHERE percentile_r = 0.8) AS eighty_percentile,
	   (SELECT round(sum(diff_date)/Count(*))
		FROM percentile
		WHERE percentile_r = 0.95) AS ninety_five_percentile
FROM percentile p
JOIN regions r
ON p.region_id = r.region_id
GROUP BY p.region_id;

-- B. Customer Transactions

-- 1.What is the unique count and total amount for each transaction type?
SELECT txn_type,
count(*) AS unique_count,
sum(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

-- 2.What is the average total historical deposit counts and amounts for all customers?
SELECT round(avg(unique_count),1) AS avg_unique_count,
	   round(avg(total_amount),1) AS avg_total_amount
FROM(
	   SELECT customer_id,
			  txn_type,
			  count(*) AS unique_count,
			  sum(txn_amount) AS total_amount
	   FROM customer_transactions
	   WHERE txn_type = 'deposit'
	   GROUP BY customer_id) AS customer_deposits;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
SELECT month_num,
	   count(customer_id) AS customer_count
FROM(
	SELECT customer_id,
		   extract(month
    FROM txn_date) AS month_num,
sum(
    CASE WHEN txn_type = 'deposit' 
    THEN 1 ELSE 0 end) AS deposit,
sum(
    CASE WHEN txn_type = 'purchase'
    THEN 1	ELSE 0 end) AS purchase,
sum(
    CASE WHEN txn_type = 'withdrawal'
    THEN 1	ELSE 0 end) AS withdrawal
FROM customer_transactions
GROUP BY customer_id, extract(month FROM txn_date)) AS count_type
WHERE deposit > 1 AND (purchase > 0 OR withdrawal > 0)
GROUP BY month_num
ORDER BY month_num;

-- 4. What is the closing balance for each customer at the end of the month?
WITH transactions AS (
	SELECT customer_id,
		   extract(MONTH FROM txn_date) AS month_num, max(txn_date) AS last_date,
		   sum(
			   CASE WHEN txn_type = 'deposit'
               THEN txn_amount
			   ELSE -txn_amount end) AS closing_balance
	FROM customer_transactions
	GROUP BY extract(MONTH FROM txn_date), customer_id)

SELECT customer_id,
	   month_num,
	   last_date,
       SUM(closing_balance) OVER (partitiON by customer_id ORDER BY  month_num) AS closing_balance
FROM transactions;

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
WITH cb AS (
       SELECT customer_id,
              month_num, last_date,
              SUM(closing_balance) OVER (partition by customer_id order by month_num) AS closing_balance
       FROM(
              SELECT customer_id,
                     EXTRACT(MONTH FROM txn_date) AS month_num,
                     MAX(txn_date) AS last_date,
                     SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) AS closing_balance
              FROM customer_transactions
              GROUP BY EXTRACT(MONTH FROM txn_date), customer_id) AS transactions),

get_prev_month AS (
       SELECT *,
              LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY month_num) AS prev_closing_balance
       FROM cb),

new_tab AS (
       SELECT *,
              (closing_balance-prev_closing_balance)/prev_closing_balance AS percentage
       FROM get_prev_month
       WHERE prev_closing_balance)

SELECT COUNT( DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM customer_transactions)*100 AS percent_customers
FROM new_tab
WHERE percentage > 0.05;

-- C. Data Allocation Challenge

-- running customer balance column that includes the impact each transaction
WITH spend AS (
        SELECT customer_id,
               txn_date,
               txn_type,
               txn_amount,
               CASE WHEN txn_type = 'deposit'
               THEN txn_amount
               ELSE -txn_amount END AS transactions
        FROM customer_transactions)

SELECT customer_id,
       txn_date,
       transactions,
       SUM(transactions) OVER(PARTITION BY customer_id ORDER BY txn_date
       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM spend;
-- where customer_id = 250;

-- customer balance at the end of each month
WITH transactions AS (
       SELECT customer_id,
              EXTRACT(month FROM txn_date) AS month_num,
              MAX(txn_date) AS last_date,
              SUM(CASE WHEN txn_type = 'deposit'
				  THEN txn_amount
                  ELSE -txn_amount END) AS closing_balance
       FROM customer_transactions
       GROUP BY EXTRACT(month FROM txn_date), customer_id)

SELECT customer_id,
       month_num, last_date,
       SUM(closing_balance) OVER (partition by customer_id order by month_num) AS closing_balance
FROM transactions;

-- minimum, average and maximum values of the running balance for each customer
WITH spend AS (
        SELECT customer_id,
               txn_date,
               txn_type,
               txn_amount,
               CASE WHEN txn_type = 'deposit'
               THEN txn_amount
               ELSE -txn_amount END AS transactions
        FROM customer_transactions),

run_bal AS (
        SELECT customer_id,
               txn_date,
               transactions,
               SUM(transactions) OVER(PARTITION BY customer_id ORDER BY txn_date
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
        FROM spend)

SELECT customer_id,
       MIN(running_balance) AS minimum_balance,
       MAX(running_balance) AS maximum_balance,
       AVG(running_balance) AS average_balance
FROM run_bal
GROUP BY customer_id;

-- Using all of the data available - how much data would have been required for each option on a monthly basis?

-- Option 1: data is allocated based off the amount of money at the end of the previous month
WITH spend AS (
        SELECT customer_id,
               txn_date,
               txn_type,
               txn_amount,
               CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END AS transactions
        FROM customer_transactions),

cte1 AS (
        SELECT customer_id,
               txn_date,
               transactions,
               MAX(txn_date) OVER(PARTITION BY customer_id, EXTRACT(MONTH FROM txn_date)) AS last_date,
               SUM(transactions) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance
        FROM spend)

SELECT EXTRACT(MONTH FROM txn_date) AS month,
       SUM(running_balance) AS amount_at_end_of_month
FROM cte1
WHERE running_balance > 0 AND
      txn_date = last_date
GROUP BY EXTRACT(MONTH FROM txn_date)
ORDER BY EXTRACT(MONTH FROM txn_date);

-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
-- Generate a list of dates for each day in the specified period
WITH RECURSIVE DateRange AS (
    SELECT DATE('2020-01-01') AS Date
    UNION ALL
    SELECT Date + INTERVAL 1 DAY
    FROM DateRange
    WHERE Date < '2020-04-30'
),

-- Cross join the list of dates with the distinct list of customers to get all combinations
-- This will generate a day for each month for each customer from the 1st of January to 30th of April, 2020
date_for_cust AS (
    SELECT d.Date,
           c.customer_id
    FROM DateRange d
    CROSS JOIN 
           (SELECT DISTINCT customer_id FROM customer_transactions) c
    LEFT JOIN 
           customer_transactions ct ON ct.txn_date = d.Date AND ct.customer_id = c.customer_id
    ORDER BY 
           c.customer_id, d.Date),
   
-- Group the amount of purchase into negative values for withdrawals and purchase, positive for deposits
txn_group AS (
    SELECT customer_id,
           txn_date,
           txn_type,
           txn_amount,
           CASE WHEN txn_type = 'deposit'
           THEN txn_amount
           ELSE -txn_amount END AS transactions
    FROM customer_transactions),
    
-- Add the transaction amount for each customer for each day of the month
-- (this will also input the transaction amount balance from the last transaction for the days the customer did not make any transactions)
add_txn AS (
    SELECT dfc.date AS gen_date,
           dfc.customer_id AS gen_cust, transactions
    FROM date_for_cust dfc
    LEFT JOIN txn_group tg
    ON dfc.date = tg.txn_date and dfc.customer_id = tg.customer_id),

-- Calculate the running balance for each customer for each day of the month using the generated days of the month column
cal_run_bal AS (
    SELECT gen_date,
           gen_cust,
           transactions,
           SUM(transactions) OVER(PARTITION BY gen_cust ORDER BY gen_date
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
    FROM add_txn),

-- Calculate the average for each customer for each month
cal_avg_run AS (
    SELECT *,
           AVG(running_balance) OVER(PARTITION BY gen_cust ORDER BY gen_date) AS avg_30_balance
    FROM cal_run_bal
    WHERE running_balance IS NOT NULL
    GROUP BY gen_cust, EXTRACT(MONTH FROM gen_date))

-- Sum the average of each customer to get total for each value
SELECT EXTRACT(MONTH FROM gen_date) AS months,
       ROUND(SUM(avg_30_balance),1) AS total
FROM cal_avg_run
WHERE avg_30_balance > 0
GROUP BY months
ORDER BY months;

-- Option 3: data is updated real-time
WITH spend AS (
        SELECT customer_id,
               txn_date,
               txn_type,
               txn_amount,
               CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END AS transactions
        FROM customer_transactions),

run_bal AS (
        SELECT customer_id,
               txn_date,
               transactions,
               EXTRACT(MONTH FROM txn_date) AS month_num,
               SUM(transactions) OVER(PARTITION BY customer_id ORDER BY txn_date
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
        FROM spend)

SELECT month_num,
	   SUM(running_balance) AS total
FROM run_bal
WHERE running_balance > 0
GROUP BY month_num
ORDER BY month_num;

-- D. Extra Challenge
-- Group the amount of purchase into negative values for withdrawals and purchase, positive for deposits
-- Get the next transaction date, so as to know the number of days a customer held a certain amount of balance
WITH cte1 AS (
         SELECT customer_id,
                txn_date, transactions,
                SUM(transactions) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance,
                LEAD(txn_date) OVER(PARTITION BY customer_id ORDER BY txn_date) AS next_txn_date1
         FROM (
                SELECT customer_id,
                       txn_date,
                       txn_type,
                       txn_amount,
                       CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END AS transactions
                FROM customer_transactions) AS spend),

-- For the last transaction a customer made, we calculate the interest till the end of that last month
cte2 AS (
         SELECT customer_id,
                txn_date,
                running_balance,
                CASE WHEN next_txn_date1 IS NULL
                THEN LAST_DAY(txn_date) ELSE next_txn_date1 END AS next_txn_date,
                CASE WHEN running_balance < 0
                THEN 0 ELSE running_balance END AS balance
         FROM cte1),

-- Calculate the Interest using the formula: Principal*(interest/365)*period
/* With the principal being the balance after a transaction
The annual interest is divided by 365 to get the interest for each day of a year
Then multiply by the number of days the customer held thesame balance
(this gives us the sum of interest for the days the balance was thesame for each customer until they made a transaction)*/
cte3 AS (
         SELECT *,
                balance*(0.06/365)*period AS interest
         FROM(
                SELECT *,
                       DATEDIFF(next_txn_date, txn_date) AS period
                FROM cte2) AS final)

-- Sum the interest of all customers for each month
SELECT EXTRACT(MONTH FROM txn_date) AS month_num,
	   SUM(interest) AS total_interest
FROM cte3
GROUP BY EXTRACT(MONTH FROM txn_date)
ORDER BY EXTRACT(MONTH FROM txn_date);