#     из таблицы users извлекаются данные по полю id, все они помещаются в одну строку, значения разделяются запятыми.
SELECT GROUP_CONCAT(DISTINCT CONVERT(id USING  'utf8')  SEPARATOR ', ') as ids FROM users

# Группировка данных по двум и более полям
 SELECT * FROM users GROUP BY CONCAT(title, '::', birth)

# Выбор записей, которые повторяются определенное количество раз.
SELECT `fio`, `country` FROM `table` GROUP BY `country` HAVING COUNT(*) = 2;

# Существует таблица, которая содержит два столбца Student и Marks, вам нужно найти всех студентов, чьи оценки являются больше, чем средние оценки, т.е. список студентов выше среднего.
SELECT student, marks from table where marks > (SELECT AVG(marks) from table)

# Найти дубликаты записей
SELECT name, COUNT(email) FROM users GROUP BY email HAVING COUNT(email) > 1

# Дана таблица tbl и поля nmbr со следующими значениями:
# 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1
# Написать запрос, чтобы установить 2 вместо 0 и установить 3 вместо 1.
update tbl set nmbr = case when nmbr = 0 then 2 else 3 end;

# записи которые есть там и там
SELECT category_id FROM products INTERSECT SELECT category_id FROM inventory;