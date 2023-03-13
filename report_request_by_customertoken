select  name, count(*) as "всего", 
  (select count(*) 
  from cadaster_cadasterdoc as cc 
  inner join cadaster_cadastertoken as cc2 on cc.cadaster_token_id = cc2.id 
  where cc.cadaster_token_id in ('26','27','28','8','25','20','14') 
  and cc.created_at  > (now() - '1 month'::interval) and cc2.name=ct.name) as "В прошлом месяце",
    (select count(*) 
  from cadaster_cadasterdoc as cc 
  inner join cadaster_cadastertoken as cc2 on cc.cadaster_token_id = cc2.id 
  where cc.cadaster_token_id in ('26','27','28','8','25','20','14') 
  and cc.created_at  < (now()) and cc.created_at > date_trunc('month',now()) and
  cc2.name=ct.name) as "В текущем месяце"
from cadaster_cadasterdoc as cc 
inner join cadaster_cadastertoken as ct on cc.cadaster_token_id = ct.id 
where cc.cadaster_token_id in ('26','27','28','8','25','20','14') 
group by ct.name
