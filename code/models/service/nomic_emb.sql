select name 
from 
    {{ref('t_ollama_model')}}
where 
    name = 'nomic-embed-text:latest'
