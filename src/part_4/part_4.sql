-- DROP FUNCTION IF EXISTS average_check_part4;

CREATE OR REPLACE FUNCTION average_check_part4(
    mode_type integer,
    first_date date, 
    second_date date,
    count_tran integer,
    coeff_increase numeric,
    max_churn_rate numeric,
    discount_share_max integer,
    share_margin numeric
    ) RETURNS TABLE (
        customer_id_ int,
		required_check_measure numeric,
		group_name varchar,
		offer_discount_depth numeric
    ) AS $$
		with part_first AS(
		WITH tmp AS (
			select pd.customer_id as id,
    		tr.transaction_summ,
    		tr.transaction_datetime
			from personal_data pd
			join cards on cards.customer_id = pd.customer_id 
			join transactions tr on tr.customer_card_id = cards.customer_card_id
			order by pd.customer_id, transaction_datetime desc
		),
		tmp2 as (
		select t.id, t.transaction_summ, t.transaction_datetime,
			case 
				when mode_type = 1 then
					AVG(t.transaction_summ) over(partition by t.id)
				when mode_type = 2 then
					AVG(t.transaction_summ) over(partition by t.id rows between UNBOUNDED PRECEDING and count_tran - 1 following)
			end
			as summ,
			
			case 
				when mode_type = 1 then
					row_number() over (partition by  t.id) 
				when mode_type = 2 then
					row_number() over (partition by  t.id rows between UNBOUNDED PRECEDING and count_tran - 1 following)
			end
			as num
			from tmp t
				where
				(mode_type = 1 AND t.transaction_datetime between first_date and second_date)
				or
				(mode_type = 2)
			)
			
		select id as Customer_ID, (summ * coeff_increase) as summ
		from tmp2
		where num = 1
		)
		select part_first.Customer_ID, part_first.summ, 
			   part_second.group_name, part_second.discount_depth as Offer_Discount_Depth from part_first
		join (
			with part_second AS (
				with discount_grop as (
					with tmp_groups as (
						select pd.customer_id, gs.group_name, gr.group_id, group_affinity_index, group_margin, 
							   gr.group_min_discount, group_churn_rate, group_discount_share,
							   CASE
							   WHEN group_churn_rate < max_churn_rate THEN true
							   ELSE false
							   END AS status_chan_rate,
							   CASE
				               WHEN group_discount_share < discount_share_max THEN true
				               ELSE false
			                   END AS status_group_discount_share
						from groups gr
						join personal_data pd  on pd.customer_id = gr.customer_id 
						join groups_sku gs on gs.group_id = gr.group_id
						order by pd.customer_id
					)
					select * from tmp_groups
					where status_chan_rate = true and status_group_discount_share = true
				)
				select customer_id, group_name, group_affinity_index,
					   (5 + ((group_min_discount * 100) - ((group_min_discount * 100) % 5))) as discount_depth,
 					   max(group_affinity_index) over(partition by customer_id) AS max_index,
					   group_margin
				from discount_grop
				order by customer_id, group_affinity_index desc
			)
			select customer_id, group_name, discount_depth from part_second
			where group_affinity_index = max_index and (discount_depth * 0.01 * group_margin) < (group_margin * share_margin * 0.01)
		) part_second on part_first.Customer_ID = part_second.customer_id
   
$$ LANGUAGE SQL;

SELECT *
from average_check_part4(2, '2010-01-01', '2022-12-31', 2, 1.0, 50.0, 2, 70.0);