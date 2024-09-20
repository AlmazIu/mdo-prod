with t as 
(select cn.id, customer_id, premise_id from cadaster_number cn 
    LEFT JOIN cadaster_cadasterdoc cc ON cn.last_doc_id = cc.id
    WHERE cn.premise_id is not null
       AND (cc.driver = 'apiegrn_search' or (cc.driver <> 'apiegrn_search' and cc.cadaster_object_json IS null))
       AND cn.is_fake = false)	
	select 
	    row_number() OVER(),
	    cn_.customer_id,
	    aa."name" ||'('||aa.subtitle||')' as cust_name, 
	    min(cn_.created_at::date) as min_created_at,
	    'https://moydomonline.ru/admin/cadaster/cadasterstatistic/?q=&customer__pk__exact='||cn_.customer_id||'&premise__pk__exact=' as link,
	    (select count(*) from geo_premise as gp
	    left join cadaster_number as cn on gp.id = cn.premise_id
	    where cn.customer_id=cn_.customer_id) as "Количество домов всего (с КН)",
	    (select count(*) from t 
       where t.customer_id = cn_.customer_id) as "Кол-во нераспаршеных домов", 
       (select count(*) from geo_apartment ga 
       left join t on ga.premise_id = t.premise_id 
       where t.customer_id = cn_.customer_id) as "Кол-во помещений в нераспаршенных домах", 
      (select count(*) from cadaster_number cn2  
       where cn2.customer_id = cn_.customer_id 
         and cn2.premise_id is not null 
         and cn2.id not in (select id from t where t.customer_id=cn_.customer_id)) as "Кол-во распаршеных домов",
	   (select count(*) from geo_apartment ga2
	   left join cadaster_number cn3 on ga2.id = cn3.apartment_id
	   where cn3.customer_id = cn_.customer_id 
	     and cn3.id not in (select t.id from t where t.customer_id=cn_.customer_id)) as "Кол-во помещений в распаршенных домах",
	    (select count(*) from cadaster_processing as cp
	    left join cadaster_number as cn on cp.cadaster_number_id = cn.id 
	    where cp.stage = 'request' and cp.stage_status in('planned','in_progress','in_queue') and cn.customer_id=cn_.customer_id) as "Заказы",
	    (select count(*) from cadaster_processing as cp 
	    left join cadaster_number as cn on cp.cadaster_number_id = cn.id 
	    where cp.stage = 'checking' and cp.stage_status in('planned','in_progress','in_queue') and cn.customer_id=cn_.customer_id) as "Ожидание",
	    (select count(*) from cadaster_processing as cp 
	    left join cadaster_number as cn on cp.cadaster_number_id = cn.id 
	    where cp.stage = 'request' and cp.stage_status in('stopped') and cn.customer_id=cn_.customer_id) as stopped,
	    'https://moydomonline.ru/admin/cadaster/processing/?q=&cadaster_number__customer='||cn_.customer_id||'&cadaster_number__parent=&stage_status__exact=stopped' as "Ссылка",
	    (select count(*) from cadaster_processing as cp 
	    full join cadaster_number as cn on cp.cadaster_number_id = cn.id 
	    where cp.stage in ('request', 'checking') and cp.stage_status in('fail') and cn.customer_id=cn_.customer_id)  as failed,
	    'https://moydomonline.ru/admin/cadaster/processing/?q=&cadaster_number__customer=' ||cn_.customer_id||  '&cadaster_number__parent=&xml_status=canceled&stage__exact=request&stage_status__exact=fail&cadaster_number__cadaster_object_type__exact=apartment&is_update__exact=0' as "Сылка",
	    (select count(*) from cadaster_processing as cp 
	    left join cadaster_number as cn on cp.cadaster_number_id = cn.id 
	    where cp.stage = 'geo_extraction' and cp.stage_status in('success') and cn.customer_id=cn_.customer_id) as completed
	from cadaster_number cn_
	left join appeals_appealsetting aa on cn_.customer_id = aa.id
	group by cn_.customer_id,aa.name, aa.subtitle 
	--having min(cn_.created_at) > (now() - '60 day'::interval)
	order by "Заказы" desc
	
