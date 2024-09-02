 {{ config(materialized='table') }}
  SELECT * FROM ollama_list_models()
