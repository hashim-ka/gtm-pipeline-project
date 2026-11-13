-- Customer value tiers
-- Source: Google's public synthetic dataset bigquery-public-data.thelook_ecommerce
-- Saved as the view gtm_models.customer_value_tiers
-- Excludes cancelled and returned items, then tiers customers by total spend.

CREATE OR REPLACE VIEW `gtm_models.customer_value_tiers` AS
WITH customer_spend AS (
  SELECT
    u.id                          AS user_id,
    u.first_name,
    u.last_name,
    u.country,
    COUNT(DISTINCT oi.order_id)   AS total_orders,
    ROUND(SUM(oi.sale_price), 2)  AS total_spend
  FROM `bigquery-public-data.thelook_ecommerce.users` AS u
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    ON oi.user_id = u.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
  GROUP BY u.id, u.first_name, u.last_name, u.country
)
SELECT
  *,
  CASE
    WHEN total_spend >= 300 THEN 'High'
    WHEN total_spend >= 100 THEN 'Medium'
    ELSE 'Low'
  END AS value_tier
FROM customer_spend;

-- Tier distribution check
-- SELECT value_tier, COUNT(*) AS customers
-- FROM `gtm_models.customer_value_tiers`
-- GROUP BY value_tier
-- ORDER BY customers DESC;
-- Result: Low 38,504 | Medium 22,343 | High 5,427 (66,274 total)
