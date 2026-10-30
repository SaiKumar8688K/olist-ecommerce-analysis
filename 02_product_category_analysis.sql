

--Q2 which product categories generate the most revenue

select p.product_category_name,
       sum(oi.price) as total_revenue,
       count(*) as total_items_sold,
       AVG(oi.price) as average_item_price
from olist_order_items oi 
join olist_products p on oi.product_id = p.product_id
group by p.product_category_name
order by total_revenue desc;


select p.product_id,
       count(*) as items_sold,
       sum(oi.price) as total_revenue,
       avg(oi.price) as average_item_price
from olist_order_items oi 
join olist_products p ON oi.product_id = p.product_id
where p.product_category_name = 'cama_mesa_banho'
group by p.product_id
order by total_revenue DESC;

select p.product_id,
       count(*) as items_sold,
       sum(oi.price) as total_revenue,
       avg(oi.price) as average_item_price
from olist_order_items oi 
join olist_products p ON oi.product_id = p.product_id
group by p.product_id
order by total_revenue DESC
limit 10;


WITH product_revenue AS (
    SELECT product_id, SUM(price) AS total_revenue
    FROM olist_order_items
    GROUP BY product_id
),
top_10 AS (
    SELECT product_id, total_revenue
    FROM product_revenue
    ORDER BY total_revenue DESC
    LIMIT 10
)
SELECT
    ROUND((SELECT SUM(total_revenue) FROM top_10), 2) AS top_10_revenue,
    ROUND(
        (SELECT SUM(total_revenue) FROM top_10) * 100.0 /
        (SELECT SUM(total_revenue) FROM product_revenue),
        2
    ) AS top_10_revenue_share_pct;


    SELECT
    COALESCE(p.product_category_name, 'Unknown') AS product_category_name,
    SUM(oi.price) AS total_revenue,
    ROUND(
        SUM(oi.price) * 100.0 / 13591643.70,
        2
    ) AS revenue_share_pct
FROM olist_order_items oi
LEFT JOIN olist_products p
    ON oi.product_id = p.product_id
GROUP BY COALESCE(p.product_category_name, 'Unknown')
ORDER BY total_revenue DESC;


select  TO_CHAR(o.order_purchase_timestamp,'YYYY-MM') as year_month,
       sum(oi.price) as monthly_revenue
from olist_orders o 
join olist_order_items oi on o.order_id = oi.order_id
join olist_products p on p.product_id = oi.product_id
where product_category_name = 'beleza_saude'
group by  TO_CHAR(o.order_purchase_timestamp,'YYYY-MM')
order by monthly_revenue DESC;


SELECT
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS year_month,
    SUM(oi.price) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM olist_orders o
JOIN olist_order_items oi
    ON o.order_id = oi.order_id
JOIN olist_products p
    ON p.product_id = oi.product_id
WHERE p.product_category_name = 'beleza_saude'
  AND o.order_purchase_timestamp >= '2017-08-01'
  AND o.order_purchase_timestamp < '2018-09-01'
  AND TO_CHAR(o.order_purchase_timestamp, 'MM') = '08'
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
ORDER BY year_month;

SELECT
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS year_month,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM olist_orders o
JOIN olist_order_items oi
    ON o.order_id = oi.order_id
WHERE oi.product_id = 'bb50f2e236e5eea0100680137654686c'
  AND (
      (o.order_purchase_timestamp >= '2017-08-01'
       AND o.order_purchase_timestamp < '2017-09-01')
      OR
      (o.order_purchase_timestamp >= '2018-08-01'
       AND o.order_purchase_timestamp < '2018-09-01')
  )
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
ORDER BY year_month;




WITH target_orders AS (
    -- Find orders containing our target product
    SELECT DISTINCT
        o.order_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM olist_orders o
    JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    WHERE oi.product_id = 'bb50f2e236e5eea0100680137654686c'
      AND (
          (o.order_purchase_timestamp >= '2017-08-01'
           AND o.order_purchase_timestamp < '2017-09-01')
          OR
          (o.order_purchase_timestamp >= '2018-08-01'
           AND o.order_purchase_timestamp < '2018-09-01')
      )
),
paired_products AS (
    -- Find other products in those same orders
    SELECT
        t.order_month,
        oi.product_id,
        t.order_id
    FROM target_orders t
    JOIN olist_order_items oi
        ON t.order_id = oi.order_id
    WHERE oi.product_id <> 'bb50f2e236e5eea0100680137654686c'
)
SELECT
    TO_CHAR(order_month, 'YYYY-MM') AS year_month,
    product_id,
    COUNT(DISTINCT order_id) AS orders_purchased_together
FROM paired_products
GROUP BY order_month, product_id
ORDER BY order_month, orders_purchased_together DESC;


SELECT
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items,
    COUNT(DISTINCT oi.product_id) AS distinct_products
FROM olist_order_items oi
WHERE oi.order_id IN (
    SELECT DISTINCT order_id
    FROM olist_order_items
    WHERE product_id = 'bb50f2e236e5eea0100680137654686c'
)
AND oi.order_id IN (
    SELECT order_id
    FROM olist_orders
    WHERE order_purchase_timestamp >= '2018-08-01'
      AND order_purchase_timestamp < '2018-09-01'
);