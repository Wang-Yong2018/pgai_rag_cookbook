-- embedding data 
 {{ config(materialized='table') }}
with 
emb_model as (
    select 
        name 
    from 
        {{ref('nomic_emb')}}
    )
,tbl_info as (
    SELECT
        id,
        schema_name,
        table_name,
        column_info,
        table_sample,
        schema_name ||'.'||table_name || column_info as data_meta,
        schema_name ||'.'||table_name || column_info || table_sample as data_sample,
        data_description
    from {{ref('t_tbl_info')}}
)
select 
    id as data_source_id,
    schema_name || table_name as data_source,
    name as model_name,
    ollama_embed(name, data_meta ) as meta_vector ,
    ollama_embed(name, data_sample) as sample_vector,
    ollama_embed(name, data_description ) as description_vector 
from
   emb_model cross join tbl_info