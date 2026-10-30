SELECT
    c.customer_state AS state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(
        (SUM(oi.price) / COUNT(DISTINCT o.order_id))::numeric,
        2
    ) AS average_order_value
FROM olist_orders o
JOIN olist_customers c
    ON o.customer_id = c.customer_id
JOIN olist_order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'canceled'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


select
    p.product_category_name as category,
    count(DISTINCT o.order_id)as total_orders,
    ROUND(sum(oi.price):: numeric,2) as total_revenue,
    ROUND(
        sum(oi.price) * 100.0 /
        sum(sum(oi.price)) over(),2
    ) as revenue_share_pct
    from olist_orders o
    join olist_customers c 
            on o.customer_id = c.customer_id
    join olist_order_items oi
            on oi.order_id = o.order_id
    join olist_products p 
            on oi.product_id = p.product_id
    where c.customer_state = 'SP'
        and o.order_status <> 'canceled'
    group by p.product_category_name
    order by total_revenue desc
    limit 5;


    SELECT
    c.customer_state AS state,
    p.product_category_name AS category,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(
        SUM(oi.price) * 100.0 /
        SUM(SUM(oi.price)) OVER (
            PARTITION BY c.customer_state
        ),
        2
    ) AS state_revenue_share_pct
FROM olist_orders o
JOIN olist_customers c
    ON o.customer_id = c.customer_id
JOIN olist_order_items oi
    ON o.order_id = oi.order_id
JOIN olist_products p
    ON oi.product_id = p.product_id
WHERE c.customer_state IN ('SP', 'PB')
  AND o.order_status <> 'canceled'
GROUP BY c.customer_state, p.product_category_name
ORDER BY c.customer_state, total_revenue DESC;


SELECT
    c.customer_state AS state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(
        (SUM(oi.price) / COUNT(DISTINCT o.order_id))::numeric,
        2
    ) AS average_order_value
FROM olist_orders o
JOIN olist_customers c
    ON o.customer_id = c.customer_id
JOIN olist_order_items oi
    ON o.order_id = oi.order_id
WHERE c.customer_state IN ('SP', 'PB')
  AND o.order_status <> 'canceled'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;