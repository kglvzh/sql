-- Создание схемы
CREATE SCHEMA IF NOT EXISTS hr;

-- Создание таблиц
CREATE TABLE IF NOT EXISTS hr.departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS hr.position (
    position_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS hr.employees_hr (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE,
    email VARCHAR(100) UNIQUE,
    department_id INTEGER,
    position_id INTEGER,
    salary NUMERIC(10, 2)
);

CREATE TABLE IF NOT EXISTS hr.employment (
    employment_id SERIAL PRIMARY KEY,
    employee_id INTEGER,
    department_id INTEGER,
    position_id INTEGER,
    salary NUMERIC(10, 2)
);

-- Вставка данных
INSERT INTO hr.departments (name, location) VALUES
('IT Отдел', 'Здание А, Этаж 3'),
('HR Отдел', 'Здание Б, Этаж 1'),
('Отдел продаж', 'Здание В, Этаж 2'),
('Маркетинговый отдел', 'Здание А, Этаж 4');

INSERT INTO hr.position (title, description) VALUES
('Разработчик ПО', 'Разрабатывает и поддерживает программные приложения'),
('Менеджер по персоналу', 'Управляет операциями с человеческими ресурсами'),
('Менеджер по продажам', 'Руководит отделом продаж и стратегиями'),
('Специалист по маркетингу', 'Занимается маркетинговыми кампаниями'),
('Старший разработчик', 'Руководит проектами разработки');

INSERT INTO hr.employees_hr (first_name, last_name, hire_date, email, department_id, position_id, salary) VALUES
('Иван', 'Петров', '2023-01-15', 'ivan.petrov@company.com', 1, 1, 75000),
('Анна', 'Сидорова', '2022-03-20', 'anna.sidorova@company.com', 2, 2, 65000),
('Сергей', 'Иванов', '2023-06-10', 'sergey.ivanov@company.com', 1, 5, 95000),
('Елена', 'Козлова', '2021-11-05', 'elena.kozlova@company.com', 3, 3, 70000),
('Дмитрий', 'Новиков', '2023-08-01', 'dmitry.novikov@company.com', 4, 4, 55000);

INSERT INTO hr.employment (employee_id, department_id, position_id, salary) VALUES
(1, 1, 1, 75000),
(2, 2, 2, 65000),
(3, 1, 5, 95000),
(4, 3, 3, 70000),
(5, 4, 4, 55000);
