SELECT
    CASE
        WHEN o.order_delivered_customer_date
             < o.order_estimated_delivery_date
            THEN 'Early'
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM olist_orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date
             < o.order_estimated_delivery_date
            THEN 'Early'
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On time'
    END
ORDER BY total_orders DESC;




SELECT
    CASE
        WHEN o.order_delivered_customer_date
             < o.order_estimated_delivery_date
            THEN 'Early'
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY r.review_score
        )::numeric,
        2
    ) AS median_review_score
FROM olist_orders o
JOIN olist_order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date
             < o.order_estimated_delivery_date
            THEN 'Early'
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On time'
    END
ORDER BY delivery_status;



with delivery_data as (
    select 
       o.order_id,
       c.customer_state as state,
       case
            when o.order_delivered_customer_date
                  > o.order_estimated_delivery_date
                then 1 
            else 0 
        end as is_late
    from olist_orders o
    join olist_customers c
        on o.customer_id = c.customer_id
    where o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND O.order_estimated_delivery_date IS NOT NULL
)
select 
      state,
      count(distinct order_id) as total_orders,
      sum(is_late) as late_orders,
      ROUND(
        sum(is_late)*100.0/count(distinct order_id),2
      )as late_delivery_rate_pct
from delivery_data
group by state
having count(distinct order_id)>=100
order by late_orders desc
limit 5;





SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date
                    - o.order_estimated_delivery_date
                )
            ) / 86400.0
        )::numeric,
        2
    ) AS avg_delay_days,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date
                    - o.order_estimated_delivery_date
                )
            ) / 86400.0
        )::numeric,
        2
    ) AS median_delay_days,

    ROUND(
        MAX(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date
                    - o.order_estimated_delivery_date
                )
            ) / 86400.0
        )::numeric,
        2
    ) AS max_delay_days

FROM olist_orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_delivered_customer_date
      > o.order_estimated_delivery_date;





SELECT
    o.order_id,
    c.customer_state AS state,
    ROUND(
        (
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date
                    - o.order_estimated_delivery_date
                )
            ) / 86400.0
        )::numeric,
        2
    ) AS delay_days,
    r.review_score
FROM olist_orders o
JOIN olist_customers c
    ON o.customer_id = c.customer_id
LEFT JOIN olist_order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_delivered_customer_date
      > o.order_estimated_delivery_date
ORDER BY delay_days DESC
LIMIT 10;


SELECT
    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On time or early'
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date + INTERVAL '7 days'
            THEN '1–7 days late'
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date + INTERVAL '30 days'
            THEN '8–30 days late'
        ELSE 'More than 30 days late'
    END AS delay_group,
    COUNT(*) AS total_orders
FROM olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY 1
ORDER BY total_orders DESC;




WITH delivery_groups AS (
    SELECT
        o.order_id,
        CASE
            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date
                THEN 'On time or early'
            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date + INTERVAL '7 days'
                THEN '1–7 days late'
            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date + INTERVAL '30 days'
                THEN '8–30 days late'
            ELSE 'More than 30 days late'
        END AS delay_group
    FROM olist_orders o
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    d.delay_group,
    COUNT(r.review_score) AS reviews_count,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM delivery_groups d
LEFT JOIN olist_order_reviews r
    ON d.order_id = r.order_id
GROUP BY d.delay_group
ORDER BY
    CASE d.delay_group
        WHEN 'On time or early' THEN 1
        WHEN '1–7 days late' THEN 2
        WHEN '8–30 days late' THEN 3
        ELSE 4
    END;





WITH state_delivery AS (
    SELECT
        c.customer_state AS state,
        COUNT(*) AS delivered_orders,
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date
                  > o.order_estimated_delivery_date
        ) AS late_orders,
        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE o.order_delivered_customer_date
                      > o.order_estimated_delivery_date
            ) / COUNT(*),
            2
        ) AS late_rate_pct
    FROM olist_orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
    GROUP BY c.customer_state
),
state_reviews AS (
    SELECT
        c.customer_state AS state,
        COUNT(r.review_score) AS reviews_count,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM olist_orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    JOIN olist_order_reviews r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)
SELECT
    d.state,
    d.delivered_orders,
    d.late_orders,
    d.late_rate_pct,
    r.reviews_count,
    r.avg_review_score
FROM state_delivery d
JOIN state_reviews r
    ON d.state = r.state
WHERE d.delivered_orders >= 100
ORDER BY d.late_rate_pct DESC;