# Лабораторная работа 2: Использование соединений (JOIN), подзапросов и функций преобразования данных

**Номер варианта 3**

## Цель работы
Научиться объединять данные из нескольких таблиц с помощью операторов JOIN и UNION. Освоить применение подзапросов (Subqueries) для сложной фильтрации. Изучить функции очистки и подготовки данных: CASE WHEN, COALESCE, DISTINCT.


## Задание 2.1: Отчет о продажах с информацией о клиентах и товарах
Выведите список продаж: имя клиента, модель товара, цена продажи, дата.

Скрипт для вцыполнения запроса

```sql
select c.first_name, c.last_name, p.model, s.sales_amount, s.sales_transaction_date
from sales s
join customers c on s.customer_id = c.customer_id
join products p on s.product_id = p.product_id
where s.sales_transaction_date between '2019-01-01' and '2019-02-01'
order by sales_transaction_date desc;
```

**Результат выполнения:**

<img width="545" height="400" alt="image" src="https://github.com/user-attachments/assets/edaefc8f-770b-4c24-bf8f-ac5687380c50" />


## Задание 2.2: Товары дороже средней цены
Найдите товары (products), цена которых выше средней цены всех товаров (подзапрос).

Скрипт для вцыполнения запроса

```sql
select model, year, product_type, base_msrp
from products
where base_msrp > (select round(avg(base_msrp)::numeric, 2) from products)  -- округление для улучшения читаемости отчета
order by base_msrp desc;
```

**Результат выполнения:**

<img width="301" height="148" alt="image" src="https://github.com/user-attachments/assets/8c340c03-b3ef-4e5f-a72a-bcb01547259a" />


## Задание 2.3: Сезонность продаж
Создайте столбец season на основе месяца продажи (sales_transaction_date): Winter, Spring, Summer, Autumn.

Скрипт для вцыполнения запроса

```sql
select 
    *,
    case 
        when extract(month from sales_transaction_date) in (12, 1, 2) then 'winter'
        when extract(month from sales_transaction_date) in (3, 4, 5) then 'spring'
        when extract(month from sales_transaction_date) in (6, 7, 8) then 'summer'
        when extract(month from sales_transaction_date) in (9, 10, 11) then 'autumn'
    end as season
from sales;
```

**Результат выполнения:**

<img width="613" height="366" alt="image" src="https://github.com/user-attachments/assets/7b37a365-928d-4301-b914-6950df9087a2" />


---

# Вывод
В ходе работы получены практические навыки объединения данных из нескольких таблиц с помощью JOIN, что позволяет создавать комплексные отчёты, обогащая информацию о транзакциях деталями клиентов и продуктов. Освоено применение подзапросов для динамической фильтрации (например, сравнение с общей средней ценой) и использование CASE WHEN для классификации данных (выделение сезонности), что критически важно для подготовки данных к анализу и построения аналитических витрин.

Полный SQL скрипт для выполнения запросов представлен в файле [lab_02.sql.](lab_02.sql).
