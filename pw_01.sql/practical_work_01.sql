-- Рассчитайте среднее время (интервал), которое проходит между регистрацией клиента (date_added в customers) и его первой покупкой (sales_transaction_date в sales).
with first_purchases as (
    select customer_id, min(sales_transaction_date) as first_buy
    from sales
    group by customer_id
)
select avg(first_buy - c.date_added) as avg_reaction_time
from customers c
join first_purchases fp on c.customer_id = fp.customer_id;

-- Для модели 'Model Chi' найдите среднюю широту и долготу покупателей (центроид продаж).
select 
    p.model,
    avg(c.latitude) as avg_latitude,
    avg(c.longitude) as avg_longitude,
    count(distinct c.customer_id) as customer_count
from customers c
join sales s on c.customer_id = s.customer_id
join products p on s.product_id = p.product_id
where p.model = 'Model Chi'
group by p.model;

-- Найдите все отзывы, содержащие слова с корнем 'issue', 'terrible', 'scam' (используйте to_tsvector и plainto_tsquery или ILIKE).
select 
    row_number() over (order by ctid) as num,
    rating,
    feedback
from customer_survey
where to_tsvector('english', feedback) @@ to_tsquery('english', 'issue | terrible | scam')
order by num;
