-- 1.1 Сколько крупных транзакций в диапазоне 1000 - 100000
SELECT COUNT(*) as large_transactions
FROM sales 
WHERE sales_amount BETWEEN 1000 AND 100000;

-- 2.1 Анализ БЕЗ индекса
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM sales 
WHERE sales_amount BETWEEN 1000 AND 100000;

-- 3.1 Создаем B-Tree индекс
CREATE INDEX idx_sales_amount ON sales (sales_amount);

-- 4.1 Анализ С индексом
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM sales 
WHERE sales_amount BETWEEN 1000 AND 100000;

-- Удаление индекса idx_sales_amount
DROP INDEX IF EXISTS idx_sales_amount;

-- 2.1 Количество товаров 2015 года
SELECT COUNT(*) FROM products WHERE year = 2015;

-- 2.2 Анализ БЕЗ индекса
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM products WHERE year = 2015;

-- 2.3 Создаем B-Tree индекс
CREATE INDEX idx_products_year ON products (year);

-- 2.4 Анализ С индекса
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM products WHERE year = 2015;

-- Удаление индекса idx_products_year
DROP INDEX IF EXISTS idx_products_year;
