-- Exercise 1: average orders per user, average quantity per order
SELECT round(count(*)::DOUBLE / count(DISTINCT user_uuid), 2) AS avg_orders_per_user,
       round(avg(quantity), 2) AS avg_quantity_per_order
FROM orders;

-- Exercise 2: first and last order per user, days between
SELECT u.username, min(o.date) AS first_order, max(o.date) AS last_order,
       date_diff('day', min(o.date), max(o.date)) AS days_between
FROM orders o JOIN users u ON o.user_uuid = u.uuid
GROUP BY ALL ORDER BY u.username;

-- Exercise 3: hour of the day with the highest quantity sold
SELECT hour(date) AS hour, sum(quantity) AS quantity
FROM orders GROUP BY hour ORDER BY quantity DESC LIMIT 1;

-- Exercise 4: month-over-month variation per product (%)
WITH m AS (
  SELECT strftime(date, '%Y-%m') AS month, product, sum(quantity) AS quantity
  FROM orders GROUP BY month, product
)
SELECT month, product, quantity,
       round(100 * (quantity - lag(quantity) OVER w) / lag(quantity) OVER w, 1) AS variation_pct
FROM m WINDOW w AS (PARTITION BY product ORDER BY month)
ORDER BY product, month;

-- Exercise 5: users who ordered every product at least once
SELECT u.username, u.name
FROM orders o JOIN users u ON o.user_uuid = u.uuid
GROUP BY ALL
HAVING count(DISTINCT o.product) = (SELECT count(DISTINCT product) FROM orders);
