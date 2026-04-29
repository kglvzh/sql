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

-- Выручка по категориям 
SELECT
    category,
    sum(quantity * unit_price * (1 - discount_pct)) AS revenue
FROM sales_var003
GROUP BY category
ORDER BY revenue DESC;

-- Топ-3 клиента по количеству покупок 
SELECT
    customer_id,
    count() AS purchases,
    sum(quantity) AS total_items
FROM sales_var003
GROUP BY customer_id
ORDER BY purchases DESC
LIMIT 3;

-- Средний чек по месяцам 
SELECT
    toYYYYMM(sale_timestamp) AS month,
    avg(quantity * unit_price) AS avg_check
FROM sales_var003
GROUP BY month
ORDER BY month;

-- Фильтрация по маю
SELECT *
FROM sales_var003
WHERE sale_timestamp >= '2024-05-01' AND sale_timestamp < '2024-06-01';

-- 3.1 Создаём таблицу
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

-- 3.2 Вставляем 8 товаров (version = 1)
-- product_id из диапазона [30..49] (по заданию)
INSERT INTO products_var003 VALUES
(30, 'Ноутбук', 'Electronics', 'Dell', 500.00, 2.2, 1, now(), 1),
(31, 'Мышь', 'Electronics', 'Logitech', 20.00, 0.1, 1, now(), 1),
(32, 'Книга Python', 'Books', 'Питер', 15.00, 0.3, 1, now(), 1),
(33, 'Футболка', 'Clothing', 'Nike', 25.00, 0.2, 1, now(), 1),
(34, 'Наушники', 'Electronics', 'Sony', 80.00, 0.3, 1, now(), 1),
(35, 'Стул', 'Furniture', 'IKEA', 120.00, 5.0, 1, now(), 1),
(36, 'Клавиатура', 'Electronics', 'Logitech', 60.00, 0.5, 1, now(), 1),
(37, 'Кружка', 'Home', 'Local', 10.00, 0.2, 1, now(), 1);

-- 3.3 Обновляем 3 товара (version = 2)
INSERT INTO products_var003 VALUES
(30, 'Ноутбук Pro', 'Electronics', 'Dell', 550.00, 2.2, 1, now(), 2),
(34, 'Наушники Pro', 'Electronics', 'Sony', 100.00, 0.3, 1, now(), 2),
(36, 'Клавиатура Mech', 'Electronics', 'Logitech', 90.00, 0.6, 0, now(), 2);

-- 3.4 Смотрим — видны обе версии
SELECT * FROM products_var003 WHERE product_id IN (30, 34, 36);

-- 3.5 Принудительное слияние
OPTIMIZE TABLE products_var003 FINAL;

-- 3.6 Снова смотрим — осталась только версия 2
SELECT * FROM products_var003 WHERE product_id IN (30, 34, 36);

-- 4.1 Создаём таблицу
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

-- 4.2 Вставляем данные за 6 дней для 2 кампаний, по 2 канала
INSERT INTO daily_metrics_var003
SELECT
    toDate('2024-06-01') + number % 6 AS metric_date,
    31 + (number % 2) AS campaign_id,
    ['Email', 'Social'][1 + (number % 2)] AS channel,
    1000 + (number * 50) AS impressions,
    50 + number AS clicks,
    2 + (number % 10) AS conversions,
    5000 + number * 100 AS spend_cents
FROM numbers(48);  -- 6 дней * 2 кампании * 2 канала * 2 = 48 строк

-- 4.3 Вставляем повторные строки (имитация дублей)
INSERT INTO daily_metrics_var003
SELECT
    metric_date, campaign_id, channel,
    impressions + 300, clicks + 30, conversions + 2, spend_cents + 800
FROM daily_metrics_var003
LIMIT 20;

-- 4.4 Слияние
OPTIMIZE TABLE daily_metrics_var003 FINAL;

-- 4.5 CTR по каналам
SELECT
    channel,
    sum(clicks) / sum(impressions) AS CTR
FROM daily_metrics_var003
GROUP BY channel;

-- 5.1 Проверка партиций sales_var003
SELECT
    partition,
    count() AS parts,
    sum(rows) AS total_rows,
    formatReadableSize(sum(bytes_on_disk)) AS size
FROM system.parts
WHERE database = 'db_var003'
  AND table = 'sales_var003'
  AND active
GROUP BY partition
ORDER BY partition;

-- 5.2 JOIN sales + products (топ-5 по выручке)
SELECT
    p.product_name,
    p.category,
    sum(s.quantity * s.unit_price * (1 - s.discount_pct)) AS revenue
FROM sales_var003 AS s
INNER JOIN products_var003 AS p ON s.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY revenue DESC
LIMIT 5;

-- 5.3 Структура всех таблиц
DESCRIBE TABLE sales_var003;
DESCRIBE TABLE products_var003;
DESCRIBE TABLE daily_metrics_var003;

-- 5.4 Таблица с массивом
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

SELECT
    arrayJoin(tags) AS tag,
    count() AS items_count
FROM tags_var003
GROUP BY tag
ORDER BY items_count DESC;

-- 5.5 Контрольная сумма
SELECT 'sales' AS tbl, count() AS rows, sum(quantity) AS check_sum FROM sales_var003
UNION ALL
SELECT 'products', count(), sum(toUInt64(product_id)) FROM products_var003 FINAL
UNION ALL
SELECT 'metrics', count(), sum(clicks) FROM daily_metrics_var003;
