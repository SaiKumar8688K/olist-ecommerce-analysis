-- what is the total product revenue ?

SELECT SUM(price) AS total_product_revenue
FROM olist_order_items;

-- 1.which month generates more revenue and why

select  TO_CHAR(o.order_purchase_timestamp,'YYYY-MM') as year_month,
       sum(oi.price) as monthly_revenue
from olist_orders o 
join olist_order_items oi on o.order_id = oi.order_id
group by  TO_CHAR(o.order_purchase_timestamp,'YYYY-MM')
order by monthly_revenue desc;

select TO_CHAR(o.order_purchase_timestamp,'YYYY-MM') as year_month,
       sum(oi.price) as monthly_revenue,
       count(distinct o.order_id) as total_orders,
       sum(oi.price)/count(distinct o.order_id) as average_order_value
from olist_orders o
join olist_order_items oi on o.order_id = oi.order_id
group by TO_CHAR(o.order_purchase_timestamp,'YYYY-MM') 
order by monthly_revenue DESC;

-- Finding:
-- November 2017 generated the highest monthly revenue,
-- mainly because it had more orders than May 2018.
-- May 2018 had a higher average order value.

