CREATE OR REPLACE VIEW purchase_history AS WITH t AS (
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

SELECT t.customer_id AS Customer_ID,
    t.transaction_id AS Transaction_ID,
    t.transaction_datetime AS Transaction_DateTime,
    t.group_id AS Group_ID,
    SUM(t.Group_Cost) AS Group_Cost,
    SUM(t.Group_Summ) AS Group_Summ,
    SUM(t.Group_Summ_Paid) AS Group_Summ_Paid
FROM t
GROUP BY customer_id,
    transaction_id,
    transaction_datetime,
    group_id
ORDER BY Customer_ID;
