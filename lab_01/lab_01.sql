-- Лабораторная работа 1, вариант 3
-- 1.1 Продавцы (salespeople) нанятые в 2018. Сортировка: Фамилия (А-Я)
select
	first_name, -- необходимо для идентификации сотрудника
	last_name,  -- необходимщ для идентификации сотрудника
	gender,     -- для анализа демографического состава команды
	hire_date   -- подтверждение, что сотрудник нанят в 2018 году
from salespeople
where hire_date between '2018-01-01' and '2018-12-31'
order by last_name asc;

-- 1.2 Письма (emails): открыты, но не кликнуты.
select 
	email_subject,   -- для анализа контента
	sent_date,       -- для анализа временных паттернов
	opened_date      -- для оценки времени отклика аудитории
from emails
where opened = 't' and clicked = 'f' and sent_date between '2011-01-01' and '2011-01-09'  -- сужение выборки для более детального анализа
order by email_id;

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