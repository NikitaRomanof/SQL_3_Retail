-- DROP VIEW periods;

CREATE OR REPLACE VIEW periods AS WITH t AS  (
    SELECT DISTINCT cards.customer_id,
        sku.group_id,
        transactions.transaction_datetime,
        transactions.transaction_id,
        SUM(stores.sku_purchase_price * checks.sku_amount) AS Group_Cost,
        SUM(checks.sku_summ) AS Group_Summ,
        SUM(checks.sku_summ_paid) AS Group_Summ_Paid
    FROM transactions
        JOIN cards ON cards.customer_card_id = transactions.customer_card_id
        JOIN checks ON transactions.transaction_id = checks.transaction_id
        JOIN sku ON sku.SKU_id = checks.SKU_id
        JOIN stores ON sku.sku_id = checks.SKU_id
    GROUP BY cards.customer_id,
        sku.group_id,
        transactions.transaction_datetime,
        transactions.transaction_id)

SELECT cards.customer_id AS Customer_ID,
       sku.group_id AS Group_ID,
       MIN(t.transaction_datetime) AS First_Group_Purchase_Date,
       MAX(t.transaction_datetime) AS Last_Group_Purchase_Date,
       COUNT(sku.group_id) / 4 AS Group_Purchase,
       get_group_frequency(MAX(t.transaction_datetime), MIN(t.transaction_datetime), COUNT(checks.transaction_id)) AS Group_Frequency,
       MIN(checks.sku_discount / checks.sku_summ) AS Group_Min_Discount

FROM checks
    JOIN sku ON checks.sku_id = sku.sku_id
    JOIN transactions ON checks.transaction_id = transactions.transaction_id
    JOIN cards ON transactions.customer_card_id = cards.customer_card_id
    JOIN t ON t.customer_id = cards.customer_id
    GROUP BY cards.customer_id, sku.group_id
ORDER BY 1,2
