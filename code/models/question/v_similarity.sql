with 
qvt as (
    select 
        data_source_id as id,
        data_source,
        model_name,
        question_vector as vector
    from 
        {{ref('t_question_emb')}}
 )
 ,dvt as (
    select 
        data_source_id as id ,
        data_source,
        model_name,
        meta_vector,
        description_vector,
        sample_vector 
    from 
        {{ref('t_tbl_emb')}}
 )
,distance as (
	select 
        qvt.id as qid,
		dvt.id as did,
        -- qvt.vector <+> dvt.meta_vector as meta_l1_distance,
        
		qvt.vector <-> dvt.meta_vector as meta_l2_distance,
		qvt.vector <=> dvt.meta_vector as meta_cosine_distance,
		qvt.vector <-> dvt.description_vector as desc_l2_distance,
		qvt.vector <=> dvt.description_vector as desc_cosine_distance,
        -- qvt.vector <+> dvt.sample_vector as sample_l1_distance,
		qvt.vector <-> dvt.sample_vector as sample_l2_distance,
		qvt.vector <=> dvt.sample_vector as sample_cosine_distance,
		qvt.model_name
	from qvt cross join dvt 
	where 
        1=1 
        and qvt.model_name = dvt.model_name
),
ranked as (
select 
    qid,
    did, 
    ROW_NUMBER() OVER (partition by qid ORDER BY sample_cosine_distance) AS sample_distance_rank,
    ROW_NUMBER() OVER (partition by qid ORDER BY desc_cosine_distance) AS desc_distance_rank,
    ROW_NUMBER() OVER (partition by qid ORDER BY meta_cosine_distance) AS meta_distance_rank,
    round(meta_cosine_distance::numeric,3) as meta_cosine_distance,
    round(desc_cosine_distance::numeric,3) as desc_cosine_distance,
    round(sample_cosine_distance::numeric,3) as sample_cosine_distance,
    round(meta_l2_distance::numeric,3) as meta_l2_distance,
    round(desc_l2_distance::numeric,3) as desc_l2_distance,
    round(sample_l2_distance::numeric,3) as sample_l2_distance,
    model_name
from
    distance t  
)
select 
    qid, did, 
    meta_distance_rank, desc_distance_rank, sample_distance_rank,
    meta_cosine_distance, desc_cosine_distance, sample_cosine_distance
from ranked
where meta_distance_rank <=3
order by qid, meta_distance_rank,desc_distance_rank