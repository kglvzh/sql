# Практическая работа 1. Геопространственный анализ данных. Аналитика с использованием сложных типов данных.

Номер вариант 3

## Цель работы
Научиться применять продвинутые возможности PostgreSQL для анализа данных, выходящих за рамки стандартных чисел и строк. Освоить работу с временными рядами, геопространственными данными, массивами, JSON/JSONB структурами и полнотекстовым поиском.

## Задачи
1. Анализ временных рядов. Использование функций DATE_TRUNC, EXTRACT, INTERVAL для агрегации продаж по периодам.
2. Геопространственный анализ. Установка расширений cube и earthdistance, расчет расстояний между клиентами и дилерскими центрами, поиск ближайших объектов.
3. Работа со сложными структурами. Формирование и разбор массивов (ARRAY), генерация и запрос данных в формате JSON/JSONB.
4. Текстовая аналитика. Токенизация текста, очистка от знаков препинания, частотный анализ слов в отзывах клиентов.

---

# Задания

## Задание 1.1: скорость реакции.
Условие: рассчитайте среднее время (интервал), которое проходит между регистрацией клиента (date_added в customers) и его первой покупкой (sales_transaction_date в sales).

Скрипт для выполнения запроса:

```sql
with first_purchases as (
    select customer_id, min(sales_transaction_date) as first_buy
    from sales
    group by customer_id
)
select avg(first_buy - c.date_added) as avg_reaction_time
from customers c
join first_purchases fp on c.customer_id = fp.customer_id;
```

Результат выполнения:

<img width="187" height="56" alt="image" src="https://github.com/user-attachments/assets/80e19ca6-a837-4d83-85d9-2b9a36a5a2f4" />



**Пояснение:**
- фильтр по штату для региональной сегментации клиентов
- сортировка для наглядности распределения по широте

---

## Задание 1.2: География модели.
Условие: для модели 'Model Chi' найдите среднюю широту и долготу покупателей (центроид продаж).


Скрипт для выполнения запроса:

```sql
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
```

Результат выполнения:

<img width="446" height="56" alt="image" src="https://github.com/user-attachments/assets/387c8123-d7c0-4aac-8e7f-3497ceb5b746" />



**Пояснение:**
- фильтр по штату для региональной сегментации клиентов
- сортировка для наглядности распределения по широте

---

## Задание 1.3: Поиск негатива.
Условие: найдите все отзывы, содержащие слова с корнем 'bad', 'fail', 'poor' (используйте to_tsvector и plainto_tsquery или ILIKE) *изменено на* найдите все отзывы, содержащие слова с корнем 'issue', 'terrible', 'scam' (используйте to_tsvector и plainto_tsquery или ILIKE) 


Скрипт для выполнения запроса:

```sql
select 
    row_number() over (order by ctid) as num,
    rating,
    feedback
from customer_survey
where to_tsvector('english', feedback) @@ to_tsquery('english', 'issue | terrible | scam')
order by num;
```

Результат выполнения:

<img width="608" height="149" alt="image" src="https://github.com/user-attachments/assets/de5ef713-012a-4333-aa6c-1fc3b6c51f8c" />



**Пояснение:**
В реальных данных (таблица customer_survey) отзывы не содержали слов bad, fail, poor ни в каком виде. При попытке использовать оригинальные слова запрос возвращал пустой результат. Диагностика показала, что негативные отзывы в данной выборке используют другую лексику: issue (проблема), terrible (ужасный), scam (мошенничество). Эти слова семантически являются негативными и соответствуют цели задания — поиску негативных отзывов.

---

# Вывод
