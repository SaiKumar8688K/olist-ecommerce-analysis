CREATE DATABASE olist_ecommerce_project;


select datname FROM pg_database
where datname = 'olist_ecommerce_project';


select current_database();

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

select count(*) from olist_orders

select sum(price) as total_product_revenue
from olist_order_items;

SELECT 'orders' AS table_name, COUNT(*) AS row_count
FROM olist_orders

UNION ALL

SELECT 'customers', COUNT(*) FROM olist_customers

UNION ALL

SELECT 'order_items', COUNT(*) FROM olist_order_items

UNION ALL

SELECT 'order_payments', COUNT(*) FROM olist_order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*) FROM olist_order_reviews

UNION ALL

SELECT 'products', COUNT(*) FROM olist_products

UNION ALL

SELECT 'sellers', COUNT(*) FROM olist_sellers