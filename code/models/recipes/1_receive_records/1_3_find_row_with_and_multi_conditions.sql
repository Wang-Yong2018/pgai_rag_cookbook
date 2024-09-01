 select *
from emp
where (
    deptno = 10
    or comm is not null
    or sal <= 2000 
) and deptno = 20