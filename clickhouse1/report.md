# Отчет по лабораторной работе: ClickHouse

**Вариант:** 3  
**База данных:** db_3 
**Выполнила:** Гловели Джемма

---

## Задание 1. 

*1.1 Создание таблицы `sales_var003`*

```sql
-- Создание таблицы продаж
CREATE TABLE sales_var003 (
    sale_id        UInt64,
    sale_timestamp DateTime64(3),
    product_id     UInt32,
    category       LowCardinality(String),
    customer_id    UInt64,
    region         LowCardinality(String),
    quantity       UInt16,
    unit_price     Decimal64(2),
    discount_pct   Float32,
    is_online      UInt8,
    ip_address     IPv4
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(sale_timestamp)
ORDER BY (sale_timestamp, customer_id, product_id);
```

*1.2 Ввод данных*

```sql
INSERT INTO sales_var003 (sale_id, sale_timestamp, product_id, category, customer_id, region, quantity, unit_price, discount_pct, is_online, ip_address)
SELECT
    3001 + number AS sale_id,
    toDateTime64('2024-05-01 00:00:00', 3) + (number * 7200) AS sale_timestamp,
    30 + (number % 20) AS product_id,
    ['Electronics','Clothing','Books','Food'][1 + (number % 4)] AS category,
    300 + (number % 100) AS customer_id,
    ['North','South','East','West'][1 + (number % 4)] AS region,
    1 + (number % 8) AS quantity,
    13.00 + (number % 50) AS unit_price,
    0.05 * (number % 10) AS discount_pct,
    number % 2 AS is_online,
    '192.168.0.1' AS ip_address
FROM numbers(120)
WHERE toYYYYMM(toDateTime64('2024-05-01 00:00:00', 3) + (number * 7200)) IN (202405, 202406, 202407);
```

---

## Задание 2. Четыре аналитических запроса

*2.1. Общая выручка по категориям*

```sql
SELECT
    category,
    sum(quantity * unit_price * (1 - discount_pct)) AS revenue
FROM sales_var003
GROUP BY category
ORDER BY revenue DESC;
```

Результат:

<img width="298" height="113" alt="image" src="https://github.com/user-attachments/assets/54376517-9fed-443d-896f-f5c7e9ec51c1" />

---

*2.2. Топ-3 клиента по количеству покупок*

```sql
SELECT
    customer_id,
    count() AS purchases,
    sum(quantity) AS total_items
FROM sales_var003
GROUP BY customer_id
ORDER BY purchases DESC
LIMIT 3;
```

Результат:

<img width="375" height="101" alt="image" src="https://github.com/user-attachments/assets/20a520ab-0c7f-4ce3-88a8-6fa77775ef4d" />

---

*2.3. Средний чек по месяцам*

```sql
SELECT
    toYYYYMM(sale_timestamp) AS month,
    avg(quantity * unit_price) AS avg_check
FROM sales_var003
GROUP BY month
ORDER BY month;
```

Результат:

<img width="284" height="68" alt="image" src="https://github.com/user-attachments/assets/92569523-cbf1-47a8-92e5-f2dfd4a66b0e" />

---

*2.4. Фильтрация по партиции (на примере мая 2024)*

```sql
-- Выбираем данные только за май 2024 года
SELECT *
FROM sales_var003
WHERE sale_timestamp >= '2024-05-01' AND sale_timestamp < '2024-06-01';
```

Результат:

<img width="892" height="127" alt="image" src="https://github.com/user-attachments/assets/fed9fce1-888b-4d96-a9fa-318ac7c11474" />

---

## Задание 3. ReplacingMergeTree — справочник товаров products_var003

*3.1 Создание таблицы `products_var003`*

```sql
-- Создание таблицы продаж
CREATE TABLE products_var003 (
    product_id    UInt32,
    product_name  String,
    category      LowCardinality(String),
    supplier      String,
    base_price    Decimal64(2),
    weight_kg     Float32,
    is_available  UInt8,
    updated_at    DateTime,
    version       UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY (product_id);
```

*3.2 Ввод данных*

```sql
INSERT INTO products_var003 VALUES
(30, 'Ноутбук', 'Electronics', 'Dell', 500.00, 2.2, 1, now(), 1),
(31, 'Мышь', 'Electronics', 'Logitech', 20.00, 0.1, 1, now(), 1),
(32, 'Книга Python', 'Books', 'Питер', 15.00, 0.3, 1, now(), 1),
(33, 'Футболка', 'Clothing', 'Nike', 25.00, 0.2, 1, now(), 1),
(34, 'Наушники', 'Electronics', 'Sony', 80.00, 0.3, 1, now(), 1),
(35, 'Стул', 'Furniture', 'IKEA', 120.00, 5.0, 1, now(), 1),
(36, 'Клавиатура', 'Electronics', 'Logitech', 60.00, 0.5, 1, now(), 1),
(37, 'Кружка', 'Home', 'Local', 10.00, 0.2, 1, now(), 1);
```

*3.3 Обновление данных*

```sql
INSERT INTO products_var003 VALUES
(30, 'Ноутбук Pro', 'Electronics', 'Dell', 550.00, 2.2, 1, now(), 2),
(34, 'Наушники Pro', 'Electronics', 'Sony', 100.00, 0.3, 1, now(), 2),
(36, 'Клавиатура Mech', 'Electronics', 'Logitech', 90.00, 0.6, 0, now(), 2);
```

Результат до принудительного слияния:

```sql
SELECT * FROM products_var003 WHERE product_id IN (30, 34, 36);
```

<img width="1755" height="248" alt="Снимок экрана 2026-04-29 104226" src="https://github.com/user-attachments/assets/ad2a5527-05d2-45b3-ad56-fb157905759a" />

---

Результат после принудительного слияния:

```sql
OPTIMIZE TABLE products_var003 FINAL;
SELECT * FROM products_var003 WHERE product_id IN (30, 34, 36);
```

<img width="1786" height="177" alt="Снимок экрана 2026-04-29 104253" src="https://github.com/user-attachments/assets/4919af4c-2bd3-49a4-b433-d5a3a8ee5dd5" />

---

## Задание 4. SummingMergeTree — агрегация метрик daily_metrics_var003

*4.1 Создание таблицы `daily_metrics_var003`*

```sql
-- Создание таблицы продаж
CREATE TABLE daily_metrics_var003 (
    metric_date    Date,
    campaign_id    UInt32,
    channel        LowCardinality(String),
    impressions    UInt64,
    clicks         UInt64,
    conversions    UInt32,
    spend_cents    UInt64
)
ENGINE = SummingMergeTree()
ORDER BY (metric_date, campaign_id, channel);
```

*4.2 Ввод данных*

```sql
INSERT INTO daily_metrics_var003
SELECT
    toDate('2024-06-01') + number % 6 AS metric_date,
    31 + (number % 2) AS campaign_id,
    ['Email', 'Social'][1 + (number % 2)] AS channel,
    1000 + (number * 50) AS impressions,
    50 + number AS clicks,
    2 + (number % 10) AS conversions,
    5000 + number * 100 AS spend_cents
FROM numbers(48);
```

*4.3 Вставка дублей и оптимизация*

```sql
INSERT INTO daily_metrics_var003
SELECT
    metric_date, campaign_id, channel,
    impressions + 300, clicks + 30, conversions + 2, spend_cents + 800
FROM daily_metrics_var003
LIMIT 20;
OPTIMIZE TABLE daily_metrics_var003 FINAL;
```

*4.4 Запрос: CTR (clicks / impressions) по каналам:*

```sql
SELECT
    channel,
    sum(clicks) / sum(impressions) AS CTR
FROM daily_metrics_var003
GROUP BY channel;
```

Результат:

<img width="263" height="65" alt="image" src="https://github.com/user-attachments/assets/085ba17c-84f6-4c42-916f-20e551d2b61b" />

---

## Задание 5. Комплексный анализ и самопроверка

*5.1. Проверка партиций таблицы sales_var003*

```sql
SELECT
    partition,
    count() AS parts,
    sum(rows) AS total_rows,
    formatReadableSize(sum(bytes_on_disk)) AS size
FROM system.parts
WHERE database = 'db_3'
  AND table = 'sales_var003'
  AND active
GROUP BY partition
ORDER BY partition;
```

---

*5.2. JOIN между sales_var003 и products_var003*

```sql
SELECT
    p.product_name,
    p.category,
    sum(s.quantity * s.unit_price * (1 - s.discount_pct)) AS revenue
FROM sales_var003 AS s
INNER JOIN products_var003 AS p ON s.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY revenue DESC
LIMIT 5;
```

Результат:

<img width="396" height="106" alt="image" src="https://github.com/user-attachments/assets/577071cc-f382-4e7f-84f3-9236101b3a6f" />

---

*5.3. Структура (типы данных) всех трех таблиц*

```sql
DESCRIBE TABLE sales_var003;
```

<img width="250" height="228" alt="image" src="https://github.com/user-attachments/assets/2679b842-1d3d-4b5e-8685-3a756641beec" />


```sql
DESCRIBE TABLE products_var003;
```

<img width="244" height="187" alt="image" src="https://github.com/user-attachments/assets/f9293856-9a62-4340-8d9b-608cf9d11fb1" />


```sql
DESCRIBE TABLE daily_metrics_var003;
```

<img width="242" height="160" alt="image" src="https://github.com/user-attachments/assets/2248ff59-e202-4ad1-b595-b9c03879a636" />

---

*5.4. Запрос с массивом (Array(String))*

```sql
-- Создание временной таблицы с массивом
CREATE TABLE tags_var003 (
    item_id  UInt32,
    item_name String,
    tags     Array(String)
) ENGINE = MergeTree()
ORDER BY item_id;

INSERT INTO tags_var003 VALUES
(1, 'Item A', ['sale', 'popular', 'new']),
(2, 'Item B', ['premium', 'limited']),
(3, 'Item C', ['sale', 'clearance']);

-- Запрос с разворотом массива
SELECT
    arrayJoin(tags) AS tag,
    count() AS items_count
FROM tags_var003
GROUP BY tag
ORDER BY items_count DESC;
```

Результат:

<img width="260" height="144" alt="image" src="https://github.com/user-attachments/assets/109c6ffc-1a47-4424-ad63-e2dae114db3a" />

---

*5.5. Контрольная сумма*

```sql
SELECT 'sales' AS tbl, count() AS rows, sum(quantity) AS check_sum FROM sales_var003
UNION ALL
SELECT 'products', count(), sum(toUInt64(product_id)) FROM products_var003 FINAL
UNION ALL
SELECT 'metrics', count(), sum(clicks) FROM daily_metrics_var003;
```

Результат:

<img width="373" height="99" alt="image" src="https://github.com/user-attachments/assets/13e90853-f0b4-4fa2-a02a-ff5ccbeb35c7" />

---

## Вывод

В ходе выполнения лабораторной работы были успешно освоены практические навыки работы с колоночной СУБД ClickHouse: выполнено подключение к облачному серверу `envlab.ru`, создана база данных и таблица `sales_var003` с использованием движка `MergeTree` и партиционированием по месяцам, вставлено более 100 строк тестовых данных. На примере четырёх аналитических запросов продемонстрирована эффективность колоночного хранения и работы партиций. С помощью движков `ReplacingMergeTree` и `SummingMergeTree` реализованы механизмы дедупликации данных и автоматической агрегации метрик, а также показана необходимость использования `OPTIMIZE TABLE FINAL` или ключевого слова `FINAL` для получения актуального состояния данных. Комплексный анализ с использованием `JOIN`, проверкой партиций, работой с массивами (`arrayJoin`) и контрольной суммой подтвердил корректность выполнения всех заданий в соответствии с вариантом 3.

Полный sql-скрипт предоставлен [здесь](pr01_var3.sql)
