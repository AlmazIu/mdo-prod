select * 
from (select fr2.id as "ID Реестра",
       sp2.order_id, 
       sm.name as "Наименование УК",
       sm.inn as "ИНН",
       fr.operation_datetime as "Дата и время операции",
       fr.full_amount as "Сумма, руб.",
       fr.charge as "Комиссия, руб.",
       round(fr.charge/fr.full_amount*100,2) as "Комиссия, %",
       fr2.bank_id
from finances_registryentry as fr
left join services_personalaccount sp on fr.personal_account_id = sp.id 
left join services_manageorganization sm on sp.manage_organization_id = sm.id 
left join finances_registry fr2 on fr2.id = fr.registry_id 
left join services_payment sp2 on fr.payment_id = sp2.id
where fr2.bank_id=1
     ) as t
 where t."Комиссия, %" > 1 and t."Дата и время операции" > (now() - '30 day'::interval)
 order by "Дата и время операции" desc
