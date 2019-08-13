-- u

select h.id, hosts 
from 
  ((select h.id, cardinality(array_agg(distinct c.company)) as hosts 
    from company_domains c, 
      (select h.id, unnest(h.hosts) as u 
      from app_hosts h, children_apps c 
      where h.id=c.id) h
    where h.u like % || c.domain || %
    group by h.id) 
  union 
    (select h.id,0 as hosts 
    from app_hosts h, children_apps c 
    where h.id=c.id and h.hosts={}) 
  order by id) as h, app_exist as e 
where e.id=h.id and e.url_exist=true



--v - children apps that no longer exist 
select h.id, hosts 
from 
  ((select h.id, cardinality(array_agg(distinct c.company)) as hosts 
    from company_domains c, 
      (select h.id, unnest(h.hosts) as u 
      from app_hosts h, children_apps c 
      where h.id=c.id) h 
    where h.u like % || c.domain || %
    group by h.id) 
  union 
    (select h.id,0 as hosts 
    from app_hosts h, children_apps c 
    where h.id=c.id and h.hosts={}) 
  order by id) as h, app_exist as e 
where e.id=h.id and e.url_exist=false

--w - all apps number of distinct tracking companies

  select h.id, cardinality(array_agg(distinct c.company)) as hosts 
  from company_domains c, 
    (select h.id, unnest(h.hosts) as u 
   from app_hosts h) h 
  where h.u like % || c.domain || % 
  group by h.id 
union 
  (select h.id,0 as hosts 
  from app_hosts h 
  where h.hosts={})


-- x - children apps number of distinct tracking companies 

  select h.id, cardinality(array_agg(distinct c.company)) as hosts 
  from company_domains c, 
    (select h.id, unnest(h.hosts) as u 
    from app_hosts h, children_apps c 
    where h.id=c.id) h 
  where h.u like % || c.domain || %
  group by h.id 
union 
  (select h.id,0 as hosts 
  from children_apps c, app_hosts h 
  where c.id = h.id and h.hosts={})


-- y - children apps from developers who have no apps left 

select h.id, hosts 
from 
  ((select h.id, cardinality(array_agg(distinct c.company)) as hosts 
    from company_domains c, 
      (select h.id, unnest(h.hosts) as u 
      from app_hosts h, children_apps c 
      where h.id=c.id) h 
    where h.u like % || c.domain || %
    group by h.id) 
  union 
    (select h.id,0 as hosts 
    from app_hosts h, children_apps c 
    where h.id=c.id and h.hosts={}) 
  order by id) as h, 
  (select developer 
  from developer_exist as d 
  where percent_exist = 0) as developers, playstore_apps as p, developers as d 
where h.id=p.id and p.developer=d.id and d.id=developers.developer


-- z - children apps from developers with 1 removed but at least one left

select h.id, hosts 
from 
  ((select h.id, cardinality(array_agg(distinct c.company)) as hosts 
    from company_domains c, 
      (select h.id, unnest(h.hosts) as u 
      from app_hosts h, children_apps c 
      where h.id=c.id) h 
    where h.u like % || c.domain || % 
    group by h.id) 
  union 
    (select h.id,0 as hosts 
    from app_hosts h, children_apps c 
    where h.id=c.id and h.hosts={}) 
  order by id) as h, 
  (select developer 
  from developer_exist as d 
  where percent_exist > 0) as developers, playstore_apps as p, developers as d 
where h.id=p.id and p.developer=d.id and d.id=developers.developer
