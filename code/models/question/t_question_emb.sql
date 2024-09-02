-- embedding data 
 {{ config(materialized='table') }}
with 
emb_model as (
    select 
        name 
    from 
        {{ref('nomic_emb')}}
    )
,sql_question as (
    SELECT
        id,
        content as question
    from public_demo.question as qt
    where type = 'sql'
)
select 
    id as data_source_id,
    'public_demo.question' as data_source,
    name as model_name,
    ollama_embed(name, question) as question_vector
from
   emb_model cross join sql_question 