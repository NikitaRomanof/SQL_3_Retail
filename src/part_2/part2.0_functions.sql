-- Функция определения сегмента покупателя для представления клиенты
CREATE OR REPLACE FUNCTION get_сustomer_segment(average varchar, frequency varchar, churn varchar) 
RETURNS integer 
LANGUAGE plpgsql AS $BODY$
DECLARE segment integer;
BEGIN 
    segment = 
        (CASE average
            WHEN 'Low'
                THEN CASE frequency
                    WHEN 'Low'
                        THEN CASE churn
                            WHEN 'Low' THEN  1
                            WHEN 'Medium' THEN 2
                            WHEN 'High' THEN 3
                        END
                    WHEN 'Medium'
                        THEN CASE churn
                            WHEN 'Low' THEN  4
                            WHEN 'Medium' THEN  5
                            WHEN 'High' THEN  6
                        END
                    ELSE
                        CASE churn
                            WHEN 'Low' THEN  7
                            WHEN 'Medium' THEN  8
                            WHEN 'High' THEN  9
                        END
                END
            WHEN 'Medium'
                THEN CASE frequency
                    WHEN 'Low'
                        THEN CASE churn
                            WHEN 'Low' THEN  10
                            WHEN 'Medium' THEN 11
                            WHEN 'High' THEN 12
                        END
                    WHEN 'Medium'
                        THEN CASE churn
                            WHEN 'Low' THEN  13
                            WHEN 'Medium' THEN  14
                            WHEN 'High' THEN  15
                        END
                    ELSE
                        CASE churn
                            WHEN 'Low' THEN  16
                            WHEN 'Medium' THEN  17
                            WHEN 'High' THEN  18
                        END
                END
            WHEN 'High'
                THEN CASE frequency
                    WHEN 'Low'
                        THEN CASE churn
                            WHEN 'Low' THEN  19
                            WHEN 'Medium' THEN 20
                            WHEN 'High' THEN 21
                        END
                    WHEN 'Medium'
                        THEN CASE churn
                            WHEN 'Low' THEN  22
                            WHEN 'Medium' THEN  23
                            WHEN 'High' THEN  24
                        END
                    ELSE
                        CASE churn
                            WHEN 'Low' THEN  25
                            WHEN 'Medium' THEN  26
                            WHEN 'High' THEN  27
                        END
                END
        END);
    RETURN segment;
END;
$BODY$;

CREATE OR REPLACE FUNCTION get_last_transaction(id integer, num integer)
RETURNS integer 
LANGUAGE plpgsql AS $BODY$
DECLARE result integer;
BEGIN 
    result = (SELECT transaction_store_id
        FROM cards
        JOIN transactions
        ON transactions.customer_card_id = cards.customer_card_id
        WHERE customer_id = id
        ORDER BY transactions.transaction_datetime DESC
        LIMIT 1
        OFFSET num);
    RETURN result;
END;
$BODY$;

CREATE OR REPLACE FUNCTION get_main_shop(id integer)
RETURNS integer 
LANGUAGE plpgsql AS $BODY$
DECLARE result integer;
BEGIN 
    result = (
        CASE
            WHEN get_last_transaction(id, 0) = get_last_transaction(id, 1) AND
                get_last_transaction(id, 2) = get_last_transaction(id, 1) AND
                get_last_transaction(id, 2) = get_last_transaction(id, 0)
                THEN get_last_transaction(id, 0)
            ELSE NULL
        END);
    RETURN result;
END;
$BODY$;

-- Функция подсчета интенсивности покупок группы для таблицы период 
DROP FUNCTION IF EXISTS get_group_frequency(last_time timestamp without time zone , first_time timestamp without time zone , group_purchase bigint);

CREATE OR REPLACE FUNCTION get_group_frequency(last_time timestamp without time zone , first_time timestamp without time zone , group_purchase bigint)
RETURNS double precision 
LANGUAGE plpgsql AS $BODY$
DECLARE frequency double precision;
BEGIN 
    frequency = (extract(day from (last_time - first_time)) + 1) / group_purchase;
    RETURN frequency;
END;
$BODY$;

DROP FUNCTION IF EXISTS get_total_transactions(last_time timestamp without time zone , first_time timestamp without time zone, arg integer);

CREATE OR REPLACE FUNCTION get_total_transactions(last_time timestamp without time zone , first_time timestamp without time zone, arg integer)
RETURNS double precision 
LANGUAGE plpgsql AS $BODY$
DECLARE total double precision ;
BEGIN 
    total = (SELECT count(subtable.id) 
            FROM (SELECT cards.customer_id AS id FROM cards
                  JOIN transactions ON cards.customer_card_id = transactions.customer_card_id
                  JOIN checks ON transactions.transaction_id = checks.transaction_id
                  JOIN sku ON sku.sku_id = checks.sku_id
                  JOIN stores ON sku.sku_id = stores.sku_id
                  WHERE transactions.transaction_datetime >= first_time
                      AND transactions.transaction_datetime <= last_time
                  GROUP BY cards.customer_id, sku.group_id,
                           transactions.transaction_datetime,
                           transactions.transaction_id) AS subtable
            WHERE subtable.id = arg);
    RETURN total;
END;
$BODY$;
