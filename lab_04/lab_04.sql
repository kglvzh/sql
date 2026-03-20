-- Найти топ-3 самых дорогих товара (rank <= 3) в каждой товарной категории (product_type).
select product_type, model, base_msrp, rank
from (
	select *, rank() over (partition by product_type order by base_msrp desc) as rank
	from products
)
where rank <= 3
order by product_type, rank;

-- Разбить всех клиентов на 4 группы (NTILE) в зависимости от их широты (latitude) — от севера к югу.
select customer_id, latitude,
ntile(4) over (order by latitude desc) as lat_group
from customers
where latitude is not null and state = 'OK'         -- фильтр по штату для региональной сегминтации клиентов
order by latitude desc, customer_id;

-- Рассчитать скользящую сумму продаж (3 дня: вчера, сегодня, завтра) для всей компании.
select 
	sales_transaction_date::date as sales_date,      -- для группировки по дням без учёта времени
	sum(sales_amount) as daily_total,
	sum(sum(sales_amount)) over (order by sales_transaction_date::date range between interval '1' preceding and current row) as total  
	-- учитывает календарные интервалы, а не количество строк в выборке
from sales
where dealership_id is not null and sales_transaction_date between '2015-01-01' and '2015-12-31'
group by sales_transaction_date::date
order by sales_date;
