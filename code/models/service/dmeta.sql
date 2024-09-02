  select name 
    from ollama_list_models() 
    where name  = 'shaw/dmeta-embedding-zh:latest'