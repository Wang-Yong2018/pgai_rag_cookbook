select id as name 
from {{ref('t_openai_model')}}
where id = 'gpt-4o-mini'
