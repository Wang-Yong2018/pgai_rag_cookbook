 {{ config(materialized='table') }}
select * 
from openai_list_models()
