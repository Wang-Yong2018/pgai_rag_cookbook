with 
dist as (
    select 
        qid, did, rank_meta_distance, rank_sample_distance 
    from 
        {{ref('v_similarity')}})
,qt as ( 
    select id, content ,did,qid
    from 
       dist 
        left join  public_demo.question on id = qid
    )
,tt as ( 
    select id, schema_name, table_name, column_info, table_sample ,did,qid
    from 
        dist left join {{ref('t_tbl_info')}} on did = id 
)

select
    qid as question_id, content,
    did as table_id,schema_name, table_name, column_info,table_sample
from qt left join tt using (qid,did) 