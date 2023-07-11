CREATE OR REPLACE VIEW customers AS WITH Customer_Average_Check AS ( 
    SELECT cards.customer_id AS id, AVG(checks.sku_summ)
    FROM cards
    JOIN transactions
    ON transactions.customer_card_id = cards.customer_card_id
    JOIN checks
    ON checks.transaction_id = transactions.transaction_id
    GROUP BY id),

    Check_Segment AS (
        SELECT Customer_Average_Check.id AS id,
                CASE
                    WHEN ROW_NUMBER() OVER(
                        ORDER BY Customer_Average_Check.AVG DESC) < (SELECT COUNT(*) * 0.1 FROM Customer_Average_Check)
                            THEN 'High'
                    WHEN ROW_NUMBER() OVER(
                        ORDER BY Customer_Average_Check.AVG DESC) < (SELECT COUNT(*) * 0.35 FROM Customer_Average_Check)
                            THEN 'Medium'
                    ELSE 'Low'
                END AS segment_AVG
        FROM Customer_Average_Check

    ), customers_count AS (
        SELECT COUNT(cards.customer_id)
        FROM cards

    ), Customer_Frequency AS (
        SELECT cards.customer_id AS id, extract(days FROM (MAX(transaction_datetime) - MIN(transaction_datetime))) 
            / COUNT(cards.customer_id) AS frequency, MAX(transaction_datetime) AS max_time
        FROM transactions
        JOIN cards
        ON transactions.customer_card_id = cards.customer_card_id
        GROUP BY cards.customer_id), 

    Customer_Frequency_Segment AS (
        SELECT Customer_Frequency.id AS id,
        CASE
            WHEN ROW_NUMBER() OVER(
                ORDER BY Customer_Frequency.frequency DESC) < (SELECT COUNT(*) * 0.1 FROM Customer_Frequency)
                    THEN 'High'
            WHEN ROW_NUMBER() OVER(
                ORDER BY Customer_Frequency.frequency DESC) < (SELECT COUNT(*) * 0.35 FROM Customer_Frequency)
                    THEN 'Medium'
            ELSE 'Low'
        END AS segment_freq
        FROM Customer_Frequency), 

    Customer_Churn_Rate AS (
        SELECT Customer_Frequency.id AS id, (extract(days FROM (current_date - Customer_Frequency.max_time)) 
            / Customer_Frequency.frequency) AS rate
        FROM Customer_Frequency),

    Customer_Churn_Segment AS (
        SELECT Customer_Churn_Rate.id AS id,
        CASE
            WHEN ROW_NUMBER() OVER(
                ORDER BY Customer_Churn_Rate.rate DESC) BETWEEN 0 AND 2
                    THEN 'High'
            WHEN ROW_NUMBER() OVER(
                ORDER BY Customer_Churn_Rate.rate DESC) BETWEEN 2 AND 5
                    THEN 'Medium'
            ELSE 'Low'
        END AS churn_segment
        FROM Customer_Churn_Rate),
    
    shops_transactions AS (
        SELECT transaction_store_id, COUNT(transaction_store_id)
        FROM cards
        JOIN transactions
        ON transactions.customer_card_id = cards.customer_card_id
        GROUP BY transaction_store_id),

    shops_share AS (
        SELECT cards.customer_id AS id, transactions.transaction_store_id, 
            ((SELECT shops_transactions.COUNT FROM shops_transactions WHERE shops_transactions.transaction_store_id = transactions.transaction_store_id) /
            COUNT(transaction_store_id)) AS transactions_share 
        FROM cards
        JOIN transactions
        ON transactions.customer_card_id = cards.customer_card_id
        GROUP BY transactions.transaction_store_id, cards.customer_id),

    main_shop AS (
        SELECT customer_id AS id, (CASE
        WHEN get_main_shop(customer_id) > 0
            THEN get_main_shop(customer_id)
        ELSE (SELECT transaction_store_id FROM shops_share WHERE shops_share.id = customer_id ORDER BY transactions_share DESC LIMIT 1)
        END) AS shop
        FROM cards
        JOIN transactions
        ON transactions.customer_card_id = cards.customer_card_id 
        GROUP BY customer_id)

    SELECT Customer_Average_Check.id AS Customer_ID,
           Customer_Average_Check.AVG AS Customer_Average_Check, 
           Check_Segment.segment_AVG AS Customer_Average_Check_Segment, 
           Customer_Frequency.frequency AS Customer_Frequency, 
           Customer_Frequency_Segment.segment_freq AS Customer_Frequency_Segment, 
           extract(days FROM (current_date - Customer_Frequency.max_time)) AS Customer_Inactive_Period,
           Customer_Churn_Rate.rate AS Customer_Churn_Rate,
           Customer_Churn_Segment.churn_segment AS Customer_Churn_Segment,
           get_сustomer_segment(Check_Segment.segment_AVG, Customer_Frequency_Segment.segment_freq, Customer_Churn_Segment.churn_segment) AS Customer_Segment,
           main_shop.shop AS Customer_Primary_Store
           
    FROM Customer_Average_Check
    JOIN Check_Segment ON Check_Segment.id = Customer_Average_Check.id
    JOIN Customer_Frequency ON Customer_Frequency.id = Customer_Average_Check.id
    JOIN Customer_Frequency_Segment ON Customer_Frequency_Segment.id = Customer_Average_Check.id
    JOIN Customer_Churn_Rate ON Customer_Churn_Rate.id = Customer_Average_Check.id
    JOIN Customer_Churn_Segment ON Customer_Churn_Segment.id = Customer_Average_Check.id
    JOIN main_shop ON main_shop.id = Customer_Average_Check.id
    ORDER BY Customer_Average_Check.id;
