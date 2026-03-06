-- Лабораторная работа 1, вариант 3
-- 1.1 Продавцы (salespeople) нанятые в 2018. Сортировка: Фамилия (А-Я)
select
	first_name, -- необходимо для идентификации сотрудника
	last_name,  -- необходимщ для идентификации сотрудника
	gender,     -- для анализа демографического состава команды
	hire_date   -- подтверждение, что сотрудник нанят в 2018 году
from salespeople
where hire_date between '2018-01-01' and '2018-12-31'
order by last_name asc;

-- 1.2 Письма (emails): открыты, но не кликнуты.
select 
	email_subject,   -- для анализа контента
	sent_date,       -- для анализа временных паттернов
	opened_date      -- для оценки времени отклика аудитории
from emails
where opened = 't' and clicked = 'f' and sent_date between '2011-01-01' and '2011-01-09'  -- сужение выборки для более детального анализа
order by email_id;
