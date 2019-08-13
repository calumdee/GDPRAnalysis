--pca - Permissions Children's Apps All

with pdg as 
  (select p.id,cardinality(array_agg(p.perm)) as perm 
  from permission l, 
    (select c.id, unnest(p.permissions) as perm 
    from children_apps c, app_perms p 
    where c.id=p.id) p 
  where p.perm like % || l.permission || % and l.level='Dangerous' 
  group by p.id) 
select * 
from 
  ((select c.id,0 as perm 
    from children_apps c 
    where not exists 
      (select 1 from pdg where pdg.id=c.id)) 
  union 
    (select * from pdg)) dp


--pca - Permissions Children's Apps that still Exist

with pdg as 
  (select p.id,cardinality(array_agg(p.perm)) as perm 
  from permission l, 
    (select c.id, unnest(p.permissions) as perm 
    from children_apps c, app_perms p 
    where c.id=p.id) p 
  where p.perm like % || l.permission || % and l.level='Dangerous' 
  group by p.id) 
select * 
from app_exist e,
  ((select c.id,0 as perm 
    from children_apps c 
    where not exists 
      (select 1 from pdg where pdg.id=c.id)) 
  union 
    (select * from pdg)) dp  
where e.id=dp.id and e.url_exist = true'


--dta - Dangerous Trackers All children's apps

with pdg as 
  (select h.id,cardinality(array_agg(distinct cd.company)) as tracker 
  from permission l,company_domains cd,company_perm cp,
    (select c.id, unnest(p.permissions) as perm 
    from children_apps c, app_perms p 
    where c.id=p.id) p, 
    (select h.id, unnest(h.hosts) as u 
    from app_hosts h, children_apps c 
    where h.id=c.id) h 
  where p.perm like % || l.permission || % and l.level='Dangerous' and h.u like % || cd.domain || % and h.id=p.id and p.perm=cp.perm and cp.company = cd.company 
  group by h.id) 
select * 
from 
  ((select c.id,0 as perm 
    from children_apps c 
    where not exists 
      (select 1 from pdg where pdg.id=c.id)) 
  union 
    (select * from pdg)) dp
    
    
--dte - Dangerous Trackers in apss that still Exist

with pdg as 
  (select h.id,cardinality(array_agg(distinct cd.company)) as tracker 
  from permission l,company_domains cd,company_perm cp,
    (select c.id, unnest(p.permissions) as perm 
    from children_apps c, app_perms p 
    where c.id=p.id) p, 
    (select h.id, unnest(h.hosts) as u 
    from app_hosts h, children_apps c 
    where h.id=c.id) h 
  where p.perm like % || l.permission || % and l.level='Dangerous'  and h.u like % || cd.domain || % and h.id=p.id and p.perm=cp.perm and cp.company = cd.company 
  group by h.id) 
select * 
from app_exist e,
  ((select c.id,0 as perm 
    from children_apps c 
    where not exists 
      (select 1 from pdg where pdg.id=c.id)) 
  union 
    (select * from pdg)) dp 
where e.id=dp.id and e.url_exist = true'

