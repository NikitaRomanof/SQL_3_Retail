DROP FUNCTION IF EXISTS part6;

CREATE OR REPLACE FUNCTION part6 (numGr int, maxChurnIn numeric,
                                  maxStabilityIn numeric,
                                  maxSKU numeric, marginShare numeric) 
RETURNS TABLE (Customer_ID int,
               SKU_Name varchar,
               Offer_Discount_Depth decimal) AS $$ BEGIN RETURN QUERY
    SELECT tmp.Customer_ID, sku.SKU_Name, CEIL(group_min_discount * 20) * 5 AS Offer_Discount_Depth
    FROM (SELECT customers.customer_id, transaction_store_id, sku_id, group_id,
                 ((marginShare * 0.01 * (sku_retail_price - sku_purchase_price)) / sku_retail_price) Offer_Discount_Depth
          FROM (SELECT sku_id, group_id, transaction_store_id
                FROM (SELECT sku_id, group_id, transaction_store_id,
                             ROW_NUMBER() OVER (PARTITION BY (transaction_store_id, group_id)
                            ORDER BY sku_retail_price - sku_purchase_price) rows_
                      FROM stores
                      JOIN sku USING (sku_id)
                      ORDER BY transaction_store_id, group_id, rows_) tmp2
                WHERE rows_ <= numGr) sku_max_margin
            JOIN customers ON transaction_store_id = customer_primary_store
            JOIN groups USING (customer_id, group_id)
            JOIN (SELECT sku_id, group_id, count_t_sku / count_t_group::decimal sku_share_in_group
                  FROM (SELECT sku_id, COUNT (DISTINCT transaction_id) AS count_t_sku
                        FROM checks
                        GROUP BY sku_id) tmp3
                  JOIN sku USING (sku_id)
                  JOIN (SELECT group_id, COUNT (DISTINCT transaction_id) count_t_group
                        FROM checks
                        JOIN sku USING (sku_id)
                        GROUP BY group_id) tmp4 USING (group_id)) 
                  sku_share USING (sku_id, group_id)
            JOIN stores USING (sku_id, transaction_store_id)
            WHERE sku_share_in_group < maxSKU
            AND group_churn_rate <= maxChurnIn
            AND group_stability_index < maxStabilityIn) tmp
    JOIN sku USING (sku_id)
    JOIN periods ON tmp.customer_id = periods.customer_id
    AND tmp.group_id = periods.group_id
WHERE tmp.Offer_Discount_Depth <= CEIL(group_min_discount * 20) / 20
ORDER BY tmp.customer_id, tmp.group_id;
END;
$$ LANGUAGE 'plpgsql';


SELECT *
FROM part6(2, 10, 2, 2, 25);