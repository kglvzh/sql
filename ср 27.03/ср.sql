import psycopg2
from psycopg2 import Error

connection = None
cursor = None

try:
    connection = psycopg2.connect(
        user="mgpu_ico_st_03",
        password="oVU3Ioe9",  # введите ваш пароль
        host="95.131.149.21",
        port="5432",
        database="bi_sql_data_student"  
    )
    cursor = connection.cursor()
    print("Информация о сервере PostgreSQL")
    print(connection.get_dsn_parameters(), "\n")
    cursor.execute("SELECT version();")
    record = cursor.fetchone()
    print("Вы подключены к - ", record, "\n")
except (Exception, Error) as error:
    print("Ошибка при подключении к PostgreSQL:", error)
finally:
    if connection:
        if cursor:
            cursor.close()
        connection.close()
        print("Соединение с PostgreSQL закрыто")