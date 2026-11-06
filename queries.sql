-- ============================================================
-- 1. Выручка по категориям (топ-10)
-- Вопрос: какие категории приносят наибольшую выручку?
-- ============================================================
SELECT
	product_category_name_english AS category, 
	ROUND(SUM(price), 2) AS total_revenue,
	COUNT(*) AS units_sold
FROM olist_products_dataset
JOIN olist_order_items_dataset USING(product_id)
JOIN product_category_name_translation USING(product_category_name)
JOIN olist_orders_dataset USING(order_id)
WHERE order_status = 'delivered'
GROUP BY product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================================
-- 2. Средний чек по месяцам
-- Вопрос: как менялась средняя стоимость товаров в заказе по месяцам?
-- ============================================================
SELECT
	TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS month,
	ROUND(SUM(price), 2) AS revenue,
	COUNT(DISTINCT order_id) AS orders,
	ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS avg_items_value
FROM olist_orders_dataset
JOIN olist_order_items_dataset USING(order_id)
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- ============================================================
-- 3. Доля опоздавших доставок
-- Вопрос: какой процент доставленных заказов пришёл позже обещанного срока?
-- ============================================================
SELECT 
	COUNT(*) AS total_delivery,
	COUNT(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 END) 
	AS late_delivery,
	ROUND(100.0 * COUNT(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 END) 
	/ COUNT(*), 2) AS late_percent
FROM olist_orders_dataset
WHERE order_status = 'delivered'
	AND order_delivered_customer_date IS NOT NULL
	AND order_estimated_delivery_date IS NOT NULL;

-- ============================================================
-- 4. Среднее время доставки по штатам (топ-10 самых медленных)
-- Вопрос: в каких штатах заказы доставляются дольше всего?
-- ============================================================
SELECT 
	customer_state,
	ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))
	/ 86400), 1) AS avg_delivery_days,
	COUNT(*) AS orders
FROM olist_orders_dataset
JOIN olist_customers_dataset USING(customer_id)
WHERE order_status = 'delivered'
	AND order_delivered_customer_date IS NOT NULL
	AND order_purchase_timestamp IS NOT NULL
GROUP BY customer_state
ORDER BY avg_delivery_days DESC
LIMIT 10;


		








