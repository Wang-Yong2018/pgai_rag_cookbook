with 
dist as (
    select 
        qid, did, meta_distance_rank, sample_distance_rank,meta_cosine_distance, sample_cosine_distance
    from 
        {{ref('v_similarity')}})
,qt as ( 
    select id, content ,did,qid
    from 
       dist 
        left join  public_demo.question on id = qid
    )
,tt as ( 
    select id, schema_name, table_name, column_info, table_sample ,did,qid,meta_distance_rank, sample_distance_rank ,meta_cosine_distance, sample_cosine_distance
    from 
        dist left join {{ref('t_tbl_info')}} on did = id 
)

select
    qid as question_id, content,
    did as table_id,sample_distance_rank,meta_cosine_distance, sample_cosine_distance
    schema_name, table_name,meta_distance_rank, 
    column_info,table_sample
from qt left join tt using (qid,did) 
order by qid ,meta_distance_rank, did