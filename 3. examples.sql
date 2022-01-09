# Из таблицы users извлекаются данные по полю id, все они помещаются в одну строку, значения разделяются запятыми.
SELECT GROUP_CONCAT(DISTINCT CONVERT(id USING  'utf8')  SEPARATOR ', ') as ids FROM users

# Группировка данных по двум и более полям
SELECT * FROM users GROUP BY CONCAT(title, '::', birth)

# Выбор записей, которые повторяются определенное количество раз.
SELECT `fio`, `country` FROM `table` GROUP BY `country` HAVING COUNT(*) = 2;

# Существует таблица, которая содержит два столбца Student и Marks, вам нужно найти всех студентов,
# чьи оценки являются больше, чем средние оценки, т.е. список студентов выше среднего.
SELECT student, marks from table where marks > (SELECT AVG(marks) from table)

# Найти дубликаты записей
SELECT name, COUNT(email) FROM users GROUP BY email HAVING COUNT(email) > 1

# Дана таблица tbl и поля nmbr со следующими значениями:
# 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1
# Написать запрос, чтобы установить 2 вместо 0 и установить 3 вместо 1.
update tbl set nmbr = case when nmbr = 0 then 2 else 3 end;

# записи которые есть там и там
SELECT category_id FROM products INTERSECT SELECT category_id FROM inventory;

#примеры перевода в горизонталь
mysql> select year (start_date) year, count(1) from employee group by year;
+------+----------+
| year | count(1) |
+------+----------+
| 2018 |        1 |
| 2019 |    99999 |
+------+----------+
2 rows in set (0.08 sec)

mysql> select sum(case when extract(year from start_date) = 2018 then 1 else 0  end) year_2018,
              sum(case when extract(year from start_date) = 2019 then 1 else 0 end) year_2019 from employee;
+-----------+-----------+
| year_2018 | year_2019 |
+-----------+-----------+
|         1 |     99999 |
+-----------+-----------+
1 row in set (0.09 sec)


# проверка условий через case
mysql> select c.cust_id, c.fed_id, case when i.cust_id is not null then concat(i.fname, ' ', i.sname)
                                        when b.cust_id is not null then concat(b.fname, ' ', b.sname) else 'Unknown' end name
       from customer c  left outer join individual i on (i.cust_id = c.cust_id)
                        left outer join business b on(b.cust_id = c.cust_id)
       where i.cust_id is not null or b.cust_id is not null;
+---------+--------+-----------------+
| cust_id | fed_id | name            |
+---------+--------+-----------------+
|       3 | XX     | fsdf fasdf      |
|       4 | XX     | fsadf fasfddsf  |
|       1 | XX     | First Nmae vcvc |
|       2 | XX     | fdsf fdfd       |
+---------+--------+-----------------+



#генерация перекрестным джоином набора, плюсование в дату и группировка по количеству
mysql> select days.dt, count(a.acc_id) from account a
        right outer join (select date_add('2019-03-23', interval ( ones.num + tens.num) day) dt
                          from  (select 0 num union all select 1 num) ones
                                    cross join (select 0 num union all select 10 num) tens) days
                         on days.dt = a.open_date group by days.dt;
+------------+-----------------+
| dt         | count(a.acc_id) |
+------------+-----------------+
| 2019-03-23 |               0 |
| 2019-03-24 |          100000 |
| 2019-04-02 |               0 |
| 2019-04-03 |               0 |
+------------+-----------------+


# выбор уникальных пар
mysql> select * from goods g1 inner join goods g2 on g1.id < g2.id and g1.name = g2.name order by g1.id, g2.id;
+----+--------------+----+--------------+
| id | name         | id | name         |
+----+--------------+----+--------------+
|  1 | Яблоки       |  2 | Яблоки       |
|  1 | Яблоки       |  4 | Яблоки       |
|  2 | Яблоки       |  4 | Яблоки       |
|  3 | Груши        |  6 | Груши        |
+----+--------------+----+--------------+
4 rows in set (0.00 sec)
