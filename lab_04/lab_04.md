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

Модернизация запроса: введенo дополнительное условие, так как без ниго в выгрузке 100000 записей, а с ним - 89066


Скрипт для выволнения запроса:

```sql
select 
  first_name,
  last_name,
  state,
  row_number() over (partition by state order by first_name) as rank
from customers 
where state is not null 
order by 
   state, rank

Выполнение запроса представлено на скриншоте:

<img width="450" height="671" alt="image" src="https://github.com/user-attachments/assets/c02a98db-03d5-4d61-ab22-8898eda2c81c" />

---

## Задание 4.2: Разделить все продукты на 10 ценовых категорий (NTILE) на основе base_msrp.


Модернизация запроса: дабвлен DISTINCT, для пропуска повторений 


Скрипт для выволнения запроса:


select distinct -- добавлен тк некоторые модели повторялись
   product_id,
  product_type,
  base_msrp,
  ntile(10) over (order by base_msrp) as category
from products
order by category asc, base_msrp asc  -- по ценовой категории, а внутри этих групп по цене


Выполнение запроса представлено на скриншоте:

<img width="498" height="481" alt="image" src="https://github.com/user-attachments/assets/13062e58-07ed-48fc-b279-8dce0c417a54" />

---

## Задание 4.3: Рассчитать минимум и максимум продаж (sales_amount) в скользящем окне (5 последних транзакций) для каждого дилера.

Модернизация запроса: без дополнительных условия в выгрузке 33296 строк, а с условиями - 20

Скрипт для выволнения запроса:

select 
  dealership_id,
  sales_transaction_date,
  min(sales_amount) over (partition by dealership_id order by sales_transaction_date 
rows between 4 preceding and current row ) as min_sales,
  max(sales_amount) over (partition by dealership_id order by sales_transaction_date 
rows between 4 preceding and current row ) as max_sales
from sales
where dealership_id is not null
order by sales_transaction_date, min_sales
limit 20

Выполнение запроса представлено на скриншоте:

<img width="763" height="674" alt="image" src="https://github.com/user-attachments/assets/80e44b5a-0b2c-4efc-a925-e2c6e3be3870" />

---

## Выводы
Научилась:
- Применять оконные функции с использованием синтаксиса OVER(), PARTITION BY и ORDER BY
- Использовать функции ранжирования ROW_NUMBER(), RANK(), DENSE_RANK() для нумерации строк внутри групп
- Вычислять скользящие минимумы и максимумы с помощью оконных агрегатных функций
- Настраивать границы окна через ROWS BETWEEN для работы с заданным количеством последних транзакций

Рассмотрела:
- Особенности работы оконных функций при фильтрации данных по датам
- Разницу между ROWS BETWEEN 4 PRECEDING AND CURRENT ROW (5 строк) и другими вариантами окон
- Применение агрегатных функций (MIN, MAX) в качестве оконных для анализа продаж по дилерам
- Практический пример расчета минимальных и максимальных продаж в скользящем окне из 5 последних транзакций для каждого дилера

Все задания выполнены в соответствии с вариантом.  
Файл [lab_4.sql](lab_4.sql) содержит чистый код выполненных запросов.

```
