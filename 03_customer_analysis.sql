SELECT
    COUNT(*) AS total_customer_records,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM olist_customers;


select 
    c.customer_unique_id,
    count(DISTINCT o.order_id) as total_orders
from olist_customers c
join olist_orders o
     on c.customer_id = o.customer_id
Group by c.customer_unique_id

order by total_orders DESC;



WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(oi.price), 0) AS total_revenue
    FROM olist_customers c
    JOIN olist_orders o
        ON c.customer_id = o.customer_id
    LEFT JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
customer_groups AS (
    SELECT
        customer_unique_id,
        total_orders,
        total_revenue,
        CASE
            WHEN total_orders = 1 THEN 'One-time'
            ELSE 'Repeat'
        END AS customer_type
    FROM customer_metrics
)
SELECT
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue,
    ROUND(AVG(total_revenue)::numeric, 2)
        AS avg_revenue_per_customer,
    ROUND(AVG(total_orders)::numeric, 2)
        AS avg_orders_per_customer
FROM customer_groups
GROUP BY customer_type
ORDER BY customer_type;




WITH customer_order_dates AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp, o.order_id
        ) AS purchase_number
    FROM olist_customers c
    JOIN olist_orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status <> 'canceled'
),
first_two_purchases AS (
    SELECT
        customer_unique_id,
        MAX(order_purchase_timestamp)
            FILTER (WHERE purchase_number = 1) AS first_purchase,
        MAX(order_purchase_timestamp)
            FILTER (WHERE purchase_number = 2) AS second_purchase
    FROM customer_order_dates
    WHERE purchase_number <= 2
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*) FILTER (
        WHERE second_purchase IS NOT NULL
    ) AS customers_with_repeat_purchases,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (second_purchase - first_purchase))
            / 86400.0
        ) FILTER (WHERE second_purchase IS NOT NULL)::numeric,
        1
    ) AS avg_days_between_first_two_purchases,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (second_purchase - first_purchase))
                     / 86400.0
        ) FILTER (WHERE second_purchase IS NOT NULL)::numeric,
        1
    ) AS median_days_between_first_two_purchases
FROM first_two_purchases;




WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers c
    JOIN olist_orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status <> 'canceled'
    GROUP BY c.customer_unique_id
),
customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_revenue
    FROM olist_customers c
    JOIN olist_orders o
        ON c.customer_id = o.customer_id
    JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'canceled'
    GROUP BY c.customer_unique_id
),
customer_segments AS (
    SELECT
        co.customer_unique_id,
        co.total_orders,
        COALESCE(cr.total_revenue, 0) AS total_revenue,
        CASE
            WHEN co.total_orders = 1 THEN '1 order'
            WHEN co.total_orders = 2 THEN '2 orders'
            ELSE '3+ orders'
        END AS purchase_group
    FROM customer_orders co
    LEFT JOIN customer_revenue cr
        ON co.customer_unique_id = cr.customer_unique_id
)
SELECT
    purchase_group,
    COUNT(*) AS customers,
    ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue,
    ROUND(AVG(total_revenue)::numeric, 2) AS avg_revenue_per_customer
FROM customer_segments
GROUP BY purchase_group
ORDER BY
    CASE purchase_group
        WHEN '1 order' THEN 1
        WHEN '2 orders' THEN 2
        ELSE 3
    END;
