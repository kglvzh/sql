# Лабораторная работа 4. Оконные функции для анализа данных

Номер вариант 3

## Цель работы
Изучить концепцию оконных функций в SQL и научиться применять их для выполнения сложных аналитических расчетов: ранжирования, вычисления скользящих средних, нарастающих итогов и сравнительного анализа строк без группировки данных.

## Задачи
- Разобрать синтаксис оконных функций: предложение OVER, PARTITION BY, ORDER BY и ROWS/RANGE.
- Научиться использовать функции ранжирования: ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE().
- Освоить функции смещения для доступа к предыдущим и следующим строкам: LAG(), LEAD().
- Применить агрегатные функции в качестве оконных для вычисления накопительных итогов и скользящих статистик.

---

# Задания

## Задание 4.1: Найти топ-3 самых дорогих товара (rank <= 3) в каждой товарной категории (product_type).


Скрипт для выволнения запроса:

```sql
select product_type, model, base_msrp, rank
from (
	select *, rank() over (partition by product_type order by base_msrp desc) as rank
	from products
)
where rank <= 3
order by product_type, rank;
```

Выполнение запроса представлено на скриншоте:

<img width="450" height="671" alt="image" src="https://github.com/user-attachments/assets/c02a98db-03d5-4d61-ab22-8898eda2c81c" />

---

## Задание 4.2: Разбить всех клиентов на 4 группы (NTILE) в зависимости от их широты (latitude) — от севера к югу.


Скрипт для выволнения запроса:

```
select customer_id, latitude,
ntile(4) over (order by latitude desc) as lat_group
from customers
where latitude is not null and state = 'OK'         -- фильтр по штату для региональной сегминтации клиентов
order by latitude desc, customer_id;
```

**Комментарий:**
- **округление** для читаемости денежных значений
- **сортировка** для приоритизации категорий с высоким разбросом цен


Выполнение запроса представлено на скриншоте:

<img width="498" height="481" alt="image" src="https://github.com/user-attachments/assets/13062e58-07ed-48fc-b279-8dce0c417a54" />

---

## Задание 4.3: Рассчитать скользящую сумму продаж (3 дня: вчера, сегодня, завтра) для всей компании.

Скрипт для выволнения запроса:

```
select 
	sales_transaction_date::date as sales_date,      -- для группировки по дням без учёта времени
	sum(sales_amount) as daily_total,
	sum(sum(sales_amount)) over (order by sales_transaction_date::date range between interval '1' preceding and current row) as total     -- учитывает календарные интервалы, а не количество строк в выборке
from sales
where dealership_id is not null and sales_transaction_date between '2015-01-01' and '2015-12-31'
group by sales_transaction_date::date
order by sales_date;
```

Выполнение запроса представлено на скриншоте:

<img width="763" height="674" alt="image" src="https://github.com/user-attachments/assets/80e44b5a-0b2c-4efc-a925-e2c6e3be3870" />

---

## Выводы


Все задания выполнены в соответствии с вариантом.  
Файл [lab_4.sql](lab_4.sql) содержит чистый код выполненных запросов.

```
