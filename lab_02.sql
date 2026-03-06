-- Лабораторная работа 2, вариант 3
-- 2.1 Выведите список продаж: имя клиента, модель товара, цена продажи, дата.
select c.first_name, c.last_name, p.model, s.sales_amount, s.sales_transaction_date
from sales s
join customers c on s.customer_id = c.customer_id
join products p on s.product_id = p.product_id
where s.sales_transaction_date between '2019-01-01' and '2019-02-01'
order by sales_transaction_date desc;

-- 2.2 Найдите товары (products), цена которых выше средней цены всех товаров (подзапрос).
select model, year, product_type, base_msrp
from products
where base_msrp > (select round(avg(base_msrp)::numeric, 2) from products)  -- округление для улучшения читаемости отчета
order by base_msrp desc;

-- 2.3 Создайте столбец season на основе месяца продажи (sales_transaction_date): Winter, Spring, Summer, Autumn.
select 
    *,
    case 
        when extract(month from sales_transaction_date) in (12, 1, 2) then 'winter'
        when extract(month from sales_transaction_date) in (3, 4, 5) then 'spring'
        when extract(month from sales_transaction_date) in (6, 7, 8) then 'summer'
        when extract(month from sales_transaction_date) in (9, 10, 11) then 'autumn'
    end as season
from sales;