-- DROP VIEW groups;

CREATE OR REPLACE VIEW  groups AS WITH t AS (SELECT cards.customer_id AS customer_id, 
                           sku.group_id AS group_id, 
                           transactions.transaction_datetime AS transaction_datetime,
                           transactions.transaction_id AS transaction_id,
                           checks.sku_discount AS sku_discount,
                           checks.sku_summ AS sku_summ,
                           checks.sku_id AS sku_id,
                           checks.sku_amount * stores.sku_purchase_price AS coast,
                           checks.sku_summ_paid AS sku_summ_paid
            FROM cards
            JOIN transactions ON cards.customer_card_id = transactions.customer_card_id
            JOIN checks ON transactions.transaction_id = checks.transaction_id
            JOIN sku ON sku.sku_id = checks.sku_id
            JOIN stores ON sku.sku_id = stores.sku_id
            ORDER BY 1, 2), 
periods_data AS (SELECT t.customer_id, t.group_id,
                        MIN(t.transaction_datetime) AS First_Group_Purchase_Date,
                        MAX(t.transaction_datetime) AS Last_Group_Purchase_Date,
                        COUNT(t.transaction_id) AS Group_Purchase,
                        get_group_frequency(MAX(t.transaction_datetime), 
                                            MIN(t.transaction_datetime), 
                                            COUNT(t.transaction_id)) AS Group_Frequency ,
                        cast(MIN(t.sku_discount / t.sku_summ) AS DOUBLE precision) AS Group_Min_Discount
                 FROM t
                 GROUP BY t.customer_id, t.group_id),
history_data AS (SELECT t.customer_id AS customer_id, 
             t.transaction_id AS transaction_id,
             t.transaction_datetime AS transaction_datetime,
             t.group_id AS group_id, 
             SUM(t.coast) AS Group_Cost,
             SUM(t.sku_summ) AS Group_Summ,
             SUM(t.sku_summ_paid)  AS Group_Summ_Paid
       FROM t
       GROUP BY t.customer_id, t.group_id,  t.transaction_id, t.transaction_datetime),
rows_data AS (
    SELECT t.customer_id, t.group_id, t.transaction_datetime, 
    ABS(extract(day from (LEAD(t.transaction_datetime) OVER (PARTITION BY t.customer_id, t.group_id) - 
    t.transaction_datetime)) - periods_data.group_frequency) / periods_data.group_frequency AS Group_Stability_Index 
    FROM t
    JOIN periods_data ON periods_data.customer_id = t.customer_id AND periods_data.group_id = t.group_id
    GROUP BY t.transaction_datetime, t.customer_id, t.group_id, periods_data.group_frequency
    ORDER BY 1,2),
margin_type AS (
    SELECT 'default' AS types, 100 AS counts
),
discount_transactions AS (
    SELECT t.customer_id, t.group_id, COUNT(t.sku_discount) AS ct
    FROM t
    WHERE t.sku_discount > 0
    GROUP BY t.customer_id, t.group_id
    ORDER BY 1, 2
)

SELECT t.customer_id AS Customer_ID, 
       t.group_id AS Group_ID,
       periods_data.Group_Purchase / get_total_transactions(periods_data.Last_Group_Purchase_Date, 
           periods_data.First_Group_Purchase_Date, t.customer_id) AS Group_Affinity_Index,
       ABS(extract(day from (now() - max(t.transaction_datetime))) - periods_data.Group_Frequency) / 
       periods_data.Group_Frequency AS Group_Churn_Rate,
       (SELECT AVG(rows_data.Group_Stability_Index)
           FROM rows_data
           WHERE rows_data.Group_Stability_Index IS NOT NULL AND rows_data.customer_id = t.customer_id
           AND rows_data.group_id = t.group_id
           GROUP BY rows_data.customer_id, rows_data.group_id) AS Group_Stability_Index,
       SUM(history_data.Group_Summ_Paid - history_data.Group_Cost) / 2 AS Group_Margin,
       discount_transactions.ct / (COUNT(t.transaction_id) / 4)::NUMERIC AS Group_Discount_Share,
       MIN(t.sku_discount / t.sku_summ) AS Group_Min_Discount,
       SUM(t.sku_summ_paid) / SUM(t.sku_summ) AS Group_Average_Discount

FROM t
JOIN periods_data ON periods_data.customer_id = t.customer_id AND periods_data.group_id = t.group_id
JOIN history_data ON history_data.customer_id = t.customer_id AND history_data.group_id = t.group_id
JOIN rows_data ON rows_data.customer_id = t.customer_id AND rows_data.group_id = t.group_id
JOIN discount_transactions ON discount_transactions.customer_id = t.customer_id AND discount_transactions.group_id = t.group_id
WHERE rows_data.Group_Stability_Index IS NOT NULL
AND periods_data.group_id = t.group_id
GROUP BY t.customer_id, t.group_id, 
    periods_data.group_purchase,
    periods_data.last_group_purchase_date, 
    periods_data.first_group_purchase_date,
    periods_data.group_frequency,
    discount_transactions.ct
