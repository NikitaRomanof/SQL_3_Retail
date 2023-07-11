DROP FUNCTION IF EXISTS part5;
CREATE OR REPLACE FUNCTION part5(firstDate date,
                                secondDate date,
								addCountTr integer,
                                maxChurnIndex int,
                                maxShareTr int,
                                marginShare int)
    RETURNS TABLE(
        Customer_ID int,
        Start_Date timestamp,
        End_Date timestamp,
        Required_Transactions_Count int,
        Group_Name varchar(255),
        Offer_Discount_Depth float
    ) AS $$
        with tmp as (
            select  *, customers.customer_id As id_,
                (extract(epoch from secondDate::timestamp - firstDate::timestamp)::float / 86400.0 / customers.customer_frequency)::int + addCountTr as Required_Transactions_Count,
                (5 + ((group_min_discount * 100) - ((group_min_discount * 100) % 5))) as discount_depth,
                max(group_affinity_index) over(partition by customers.customer_id) AS max_index
            from personal_data
            join customers on customers.customer_id = personal_data.customer_id
            join groups on groups.customer_id = personal_data.customer_id
            join groups_sku on groups_sku.group_id = groups.group_id
            where groups.group_churn_rate < maxChurnIndex and groups.group_discount_share < maxShareTr
	    )
	    select id_, firstDate, secondDate,Required_Transactions_Count, group_name, discount_depth 
        from tmp
	    where group_affinity_index = max_index and
	    (discount_depth * 0.01 * group_margin) < (marginShare * 0.01 * group_margin)
	$$ LANGUAGE SQL;
	
	select *
from part5(
    '01-01-2020',
    '14-09-2022',
    10,
    20,
    30,
    40);