-- 1. Сколько крупных транзакций в диапазоне 1000 - 100000
SELECT COUNT(*) as large_transactions
FROM sales 
WHERE sales_amount BETWEEN 1000 AND 100000;

-- 2. Анализ БЕЗ индекса
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM sales 
WHERE sales_amount BETWEEN 1000 AND 100000;

-- 3. Создаем B-Tree индекс
CREATE INDEX idx_sales_amount ON sales (sales_amount);

-- 4. Анализ С индексом
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM sales 
WHERE sales_amount BETWEEN 1000 AND 100000;

-- 5. Сравнение производительности
\timing on

-- Sequential Scan (без индекса)
SET enable_seqscan = ON;
SET enable_indexscan = OFF;
SELECT COUNT(*) FROM sales WHERE sales_amount BETWEEN 1000 AND 100000;

-- Index Scan (с индексом)
SET enable_seqscan = OFF;
SET enable_indexscan = ON;
SELECT COUNT(*) FROM sales WHERE sales_amount BETWEEN 1000 AND 100000;

RESET enable_seqscan;
RESET enable_indexscan;
\timing off

-- 6. Дополнительная аналитика по крупным транзакциям
SELECT 
    MIN(sales_amount) as min_amount,
    MAX(sales_amount) as max_amount,
    AVG(sales_amount) as avg_amount,
    COUNT(*) as total_count,
    COUNT(DISTINCT sales_amount) as unique_amounts
FROM sales 
WHERE sales_amount BETWEEN 1000 AND 100000;