 {{ config(materialized='table') }}
WITH table_info AS (
    SELECT
        c.oid AS table_id,
        n.nspname AS schema_name,
        c.relname AS table_name
    FROM
        pg_class c
    JOIN
        pg_namespace n ON c.relnamespace = n.oid
    WHERE
        c.relkind = 'r' -- Only regular tables
        and n.nspname in ('public_demo')
),
column_info AS (
    SELECT
        a.attnum,
        a.attname AS column_name,
        t.typname AS data_type,
        t.oid AS type_oid,
        c.table_id
    FROM
        pg_attribute a
    JOIN
        pg_type t ON a.atttypid = t.oid
    JOIN
        table_info c ON a.attrelid = c.table_id
    WHERE
        a.attnum > 0 -- Exclude system columns
        AND NOT a.attisdropped -- Exclude dropped columns
)
,
column_json AS (
    SELECT
        table_id,
        jsonb_agg(jsonb_build_object(
            'column_name', column_name,
            'data_type', data_type
        )) AS column_info
    FROM
        column_info
    GROUP BY
        table_id
)
,model as (
	select id as name 
	from 
		t_openai_model tom  
	where id = 'gpt-4o-mini'
)
,sample_records AS (
   select 
    table_name, table_sample,
    openai_chat_complete(model.name,
			jsonb_build_array(
				jsonb_build_object('role', 'user', 'content', 
    'as a data analyst, pls help generate less than 50 words short description for below data information: \n-----\n'||
    'table name: ' ||table_name ||
    '\n----\n'||table_sample))) as chat_completion 
   from 
    model cross join {{ref('t_tbl_sample')}}
)
SELECT
    t.table_id AS id,
    t.schema_name,
    chat_completion['choices'][0]['message']['content']::text as data_description,
    t.table_name,
    c.column_info,
    s.table_sample
FROM
    table_info t
JOIN
    column_json c ON t.table_id = c.table_id
JOIN
    sample_records s ON t.table_name = s.table_name
