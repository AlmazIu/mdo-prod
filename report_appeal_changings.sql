select customer_id,  
       link,  
       cust_name, 
       coalesce("пом всего",0) as "пом всего",
       coalesce(round((100*("Заявок в текущем месяце" - "за 3 мес." / del)::float / ("за 3 мес." / del::float))::numeric,2),0::int)  as "Изменения, %",
       coalesce("Заявок в текущем месяце" - "за 3 мес." / del,0::int) as "Изменения",       
       coalesce("Заявок в текущем месяце",0::int) as "Заявок в отчетном месяце",
       coalesce("за 3 мес."/del,0::int) as "К-во заявок в среднем",       
       coalesce(round((100*("Заявок в текущем месяце робот" - "за 3 мес. робот"/delrob)::float / ("за 3 мес. робот" / delrob::float))::numeric,2),0::int)  as "Изменения робот, %",       
       coalesce("Заявок в текущем месяце робот" - "за 3 мес. робот" / delrob,0::int) as "Изменения робот",
       coalesce("Заявок в текущем месяце робот",0::int) as "Заявок в отчетном месяце робот",
       coalesce("за 3 мес. робот"/delrob,0::int) as "К-во заявок в среднем робот",
       coalesce(round((100*("Заявок в текущем месяце не робот" - "за 3 мес. не робот"/delemp)::float / ("за 3 мес. не робот" / delrob::float))::numeric,2),0::int)  as "Изменения не робот, %",
       coalesce("Заявок в текущем месяце не робот" - "за 3 мес. не робот" / delemp,0::int) as "Изменения не робот",
       coalesce("Заявок в текущем месяце не робот",0::int) as "Заявок в отчетном месяце не робот",
       coalesce("за 3 мес. не робот"/delemp,0::int) as "К-во заявок в среднем не робот",
       act as "Активация",
       deact as "Деактивация",
       coalesce("за 3 мес.",0) as "Всего за 3 мес",        
       coalesce("за 3 мес. робот",0) as "Всего за 3 мес робот",              
       coalesce("за 3 мес. не робот",0) as "Всего за 3 мес не робот"
       from ( 
      select aa_.customer_id, 
      'https://moydomonline.ru/admin/appeals/appealsetting/?id='||aa_.customer_id||'#' as link, 
      aa3."name" || ' (' || aa3.subtitle || ')' as cust_name,
      aa3.activated_at as act,
      aa3.deactivated_at as deact,
          (select count(*) 
          from geo_apartment ga  
          left join geo_customerpremise gc on ga.premise_id = gc.premise_id  
          where gc.appeal_setting_id = aa_.customer_id  
          ) as "пом всего",   
          (select count(*) 
          from appeals_appeal aa  
          left join appeals_appealsetting aas on aa.customer_id = aas.id  --тоже лишняя 
          where aas.id = aa_.customer_id -- aa.customer_id = aa_.customer_id 
          and aa.created_at > (date_trunc('month',now()) - '4 month'::interval)  
          and aa.created_at < (date_trunc('month',now()) - '1 month'::interval)  
          group by aas.id) as "за 3 мес.",  
         (select count(*)  
         from appeals_appeal aa  
         left join appeals_appealsetting aas on aa.customer_id = aas.id -- и тут 
         where aas.id = aa_.customer_id -- aa.customer_id = aa_.customer_id 
         and aa.created_at > (date_trunc('month',now()) - '1 month'::interval) and  aa.created_at <date_trunc('month',now()) 
         group by aas.id) as "Заявок в текущем месяце", 
         (select CASE   
         WHEN mm < (date_trunc('month',now()) - '3 month'::interval) THEN 3  
         WHEN mm < (date_trunc('month',now()) - '2 month'::interval) /*and mm > date_trunc('month',now()- '1 month'::interval)*/ THEN 2  
         ELSE 1  
         end  
         from 
             (select min(aa.created_at) as mm 
             from appeals_appeal aa  
             where aa.customer_id = aa_.customer_id  
             group by aa.customer_id) as dd) as del,
         (select count(*) 
          from appeals_appeal aa  
          left join appeals_appealsetting aas on aa.customer_id = aas.id  --тоже лишняя 
          where aas.id = aa_.customer_id -- aa.customer_id = aa_.customer_id 
          and aa.created_at > (date_trunc('month',now()) - '4 month'::interval)  
          and aa.created_at < (date_trunc('month',now()) - '1 month'::interval)
          and aa.created_by_id = 22000
          group by aas.id) as "за 3 мес. робот",  
         (select count(*)  
         from appeals_appeal aa  
         left join appeals_appealsetting aas on aa.customer_id = aas.id -- и тут 
         where aas.id = aa_.customer_id -- aa.customer_id = aa_.customer_id 
         and aa.created_at > (date_trunc('month',now()) - '1 month'::interval) and  aa.created_at <date_trunc('month',now()) 
         and aa.created_by_id = 22000
         group by aas.id) as "Заявок в текущем месяце робот", 
         (select CASE   
         WHEN mm < (date_trunc('month',now()) - '3 month'::interval) THEN 3  
         WHEN mm < (date_trunc('month',now()) - '2 month'::interval) /*and mm > date_trunc('month',now()- '1 month'::interval)*/ THEN 2  
         ELSE 1  
         end  
         from 
             (select min(aa.created_at) as mm 
             from appeals_appeal aa  
             where aa.customer_id = aa_.customer_id  
             group by aa.customer_id) as dd) as delrob,
         (select count(*) 
          from appeals_appeal aa  
          left join appeals_appealsetting aas on aa.customer_id = aas.id  --тоже лишняя 
          where aas.id = aa_.customer_id -- aa.customer_id = aa_.customer_id 
          and aa.created_at > (date_trunc('month',now()) - '4 month'::interval)  
          and aa.created_at < (date_trunc('month',now()) - '1 month'::interval)
          and (aa.created_by_id <> 22000 or aa.created_by_id is null)
          group by aas.id) as "за 3 мес. не робот",  
         (select count(*)  
         from appeals_appeal aa  
         left join appeals_appealsetting aas on aa.customer_id = aas.id -- и тут 
         where aas.id = aa_.customer_id -- aa.customer_id = aa_.customer_id 
         and aa.created_at > (date_trunc('month',now()) - '1 month'::interval) and  aa.created_at <date_trunc('month',now()) 
         and (aa.created_by_id <> 22000 or aa.created_by_id is null)
         group by aas.id) as "Заявок в текущем месяце не робот", 
         (select CASE   
         WHEN mm < (date_trunc('month',now()) - '3 month'::interval) THEN 3  
         WHEN mm < (date_trunc('month',now()) - '2 month'::interval) /*and mm > date_trunc('month',now()- '1 month'::interval)*/ THEN 2  
         ELSE 1  
         end  
         from 
             (select min(aa.created_at) as mm 
             from appeals_appeal aa  
             where aa.customer_id = aa_.customer_id  
             group by aa.customer_id) as dd) as delemp
  from appeals_appeal aa_  
  left join appeals_appealsetting aa3 on aa_.customer_id = aa3.id
  group by aa_.customer_id, aa3."name",aa3.subtitle,aa3.activated_at,aa3.deactivated_at) as tab1 
where act is not null and (deact > date_trunc('month',now() - '1 month'::interval) or deact is null)
order by round((100*("Заявок в текущем месяце" - "за 3 мес." / del)::float / ("за 3 мес." / del::float))::numeric,2) asc
