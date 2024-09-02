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
        -- qvt.vector <+> dvt.sample_vector as sample_l1_distance,
		qvt.vector <-> dvt.sample_vector as sample_l2_distance,
		qvt.vector <=> dvt.sample_vector as sample_cosine_distance,
		qvt.model_name
	from qvt cross join dvt 
	where 
        1=1 
        and qvt.model_name = dvt.model_name
)
select 
    qid,
    did, 
    ranking.rank_meta_distance,
    ranking.rank_sample_distance,
    -- ROW_NUMBER() OVER (ORDER BY sample_cosine_distance, sample_l2_distance) AS rank_sample_distance,
    -- ROW_NUMBER() OVER (ORDER BY meta_cosine_distance, meta_l2_distance) AS rank_meta_distance,
    round(meta_cosine_distance::numeric,2) as meta_cosine_distance,
    round(sample_cosine_distance::numeric,2) as sample_cosine_distance,

    round(meta_l2_distance::numeric,2) as meta_l2_distance,
    round(sample_l2_distance::numeric,2) as sample_l2_distance,
    model_name
from
    distance t  CROSS JOIN LATERAL(
        SELECT
            ROW_NUMBER() OVER (ORDER BY t.sample_cosine_distance) AS rank_sample_distance,
            ROW_NUMBER() OVER (ORDER BY t.meta_cosine_distance) AS rank_meta_distance
    ) AS ranking
where
    qid =1
    -- and (
    --     rank_sample_distance <= 3 
    --     and rank_meta_distance <=3 -- only get first 5 records
    -- )

    
order by qid, rank_meta_distance,rank_sample_distance
