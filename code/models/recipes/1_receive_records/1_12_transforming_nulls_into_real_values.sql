select
    case
        when comm is not null then comm
        else 0
    end as comm_casewhen,
    coalesce(comm,0) as comm_coalesce

from
    emp