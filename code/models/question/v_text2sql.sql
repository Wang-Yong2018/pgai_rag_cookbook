with 
dist as (
    select 
        qid, did, 
        meta_distance_rank, desc_distance_rank, sample_distance_rank,
        meta_cosine_distance, desc_cosine_distance, sample_cosine_distance
    from 
        {{ref('v_similarity')}})
,qt as ( 
    select id, content ,did,qid
    from 
       dist 
        left join  public_demo.question on id = qid
    )
,tt as ( 
    select 
        id, schema_name, table_name, 
        column_info, table_sample ,
        did,qid,
        meta_distance_rank, desc_distance_rank, sample_distance_rank,
        meta_cosine_distance, desc_cosine_distance, sample_cosine_distance
    from 
        dist left join {{ref('t_tbl_info')}} on did = id 
)

select
    qid as question_id, 
    did as table_id,
    meta_distance_rank, desc_distance_rank, --sample_distance_rank,
    meta_cosine_distance, desc_cosine_distance, -- sample_cosine_distance
    content,
    schema_name, table_name, 
    column_info,table_sample
from qt left join tt using (qid,did) 
order by qid ,desc_distance_rank,meta_distance_rank 