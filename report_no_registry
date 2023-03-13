select sp.order_id as "Заказ", 
       sm.name as "Наименование УК",
       sm.inn as "ИНН",
       sp.created_at as "Дата и время оплаты",
       sp.amount as "Сумма, руб."  
from services_payment sp
left join services_manageorganization sm on sp.manage_organization_id = sm.id
left join finances_registryentry fr on sp.id = fr.payment_id 
where  sp.success is true and sp.status in ('1','2') and fr.id is null and sp.created_at >= now()-'1 month'::interval and sp.created_at <= now()-'3 day'::interval
