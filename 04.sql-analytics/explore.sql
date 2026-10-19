-- Load the bronze datasets into tables
CREATE OR REPLACE TABLE users AS
FROM read_csv(getvariable('bucket') || '/bronze/users.csv', strict_mode = false);
CREATE OR REPLACE TABLE orders AS
FROM read_csv(getvariable('bucket') || '/bronze/orders.csv', strict_mode = false);

SELECT (SELECT count(*) FROM users) AS users, (SELECT count(*) FROM orders) AS orders;
SELECT min(date) AS first_order, max(date) AS last_order FROM orders;

-- Data quality checks (expect 0, 0 and no row)
SELECT count(*) AS orphan_orders FROM orders o ANTI JOIN users u ON o.user_uuid = u.uuid;
SELECT count(*) AS inactive_users FROM users u ANTI JOIN orders o ON o.user_uuid = u.uuid;
SELECT uuid, count(*) AS occurrences FROM orders GROUP BY uuid HAVING count(*) > 1;

-- Aggregations
SELECT product, count(*) AS orders, sum(quantity) AS quantity,
       round(100 * sum(quantity) / sum(sum(quantity)) OVER (), 1) AS share_pct
FROM orders GROUP BY product ORDER BY quantity DESC;

SELECT date_trunc('month', date) AS month, count(*) AS orders, sum(quantity) AS quantity
FROM orders GROUP BY month ORDER BY month;

-- Joins
SELECT u.username, u.name, count(*) AS orders, sum(o.quantity) AS quantity
FROM orders o JOIN users u ON o.user_uuid = u.uuid
GROUP BY ALL ORDER BY quantity DESC LIMIT 5;

SELECT (date_diff('year', u.birthdate, DATE '2020-01-01') // 20) * 20 AS age_group,
       count(DISTINCT u.uuid) AS users, count(*) AS orders, round(avg(o.quantity), 2) AS avg_quantity
FROM orders o JOIN users u ON o.user_uuid = u.uuid
GROUP BY age_group ORDER BY age_group;

-- Window functions
WITH daily AS (
  SELECT date::DATE AS day, sum(quantity) AS quantity FROM orders GROUP BY day
)
SELECT day, quantity, sum(quantity) OVER (ORDER BY day) AS cumulative,
       round(avg(quantity) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS avg_7d
FROM daily ORDER BY day LIMIT 10;

SELECT strftime(date, '%Y-%m') AS month, product, sum(quantity) AS quantity
FROM orders GROUP BY month, product
QUALIFY rank() OVER (PARTITION BY month ORDER BY sum(quantity) DESC) = 1
ORDER BY month;

-- Pivot
PIVOT (SELECT strftime(date, '%Y-%m') AS month, product, quantity FROM orders)
ON product USING sum(quantity) ORDER BY month;
