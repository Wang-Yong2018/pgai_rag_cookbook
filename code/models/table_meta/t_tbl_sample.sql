
with 
t1 as (select * from public_demo.dept limit 5)
,t2 as (select * from public_demo.emp limit 5)
,t3 as (select * from public_demo.t1 limit 5)
,t4 as (select * from public_demo.t10 limit 5)
,t5 as (select * from public_demo.titanic limit 5)
select 'dept' as table_name, json_agg(t.*) as table_sample from t1 as t
union all
select 'emp' as table_name, json_agg(t.*) as table_sample from t2 as t
union all
select 't1' as table_name, json_agg(t.*) as table_sample from t3 as t
union all
select 't10' as table_name, json_agg(t.*) as table_sample from t4 as t 
union all
select 'titanic' as table_name, json_agg(t.*) as table_sample from t5 as t