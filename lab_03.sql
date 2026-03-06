-- Лабораторная работа 3, вариант 3
-- 3.1 Найти стандартное отклонение (STDDEV) цены продуктов.
select 
product_type,
round(STDDEV(base_msrp)::numeric, 2) as "среднее отклонение цены"  -- округление для улучшения читаемости отчета
from products
group by product_type
order by "среднее отклонение цены" desc;                           -- для приоритизации категорий с высоким разбросом цен

-- 3.2 Посчитать количество уникальных клиентов в каждом штате.
select 
state,
count(distinct customer_id) as unique_cust
from customers
where state is not null                         -- для повышения точности аналитики
group by state
order by state;

-- 3.3 Вывести типы продуктов, максимальная цена которых меньше 1000.
select 
product_type,
max(base_msrp) as max_price
from products
group by product_type
having max(base_msrp) < 1000;