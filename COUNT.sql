# Подсчитывает от обратного, берет меньше строк
SELECT (SELECT COUNT(*) FROМ world.city) - COUNT(*) FROМ world.city WНERE ID <= 5;

# Вариант подсчета в случае разных значений полей
SELECT COUNT(color = 'blue' OR NULL) AS blue, COUNT(color = ' red' OR NULL) AS red FROМ items;
SELECT SUM(IF(color = 'blue', 1, 0)) AS blue,SUM(IF(color = 'red', 1, 0)) AS red FROМ items;

# Одновременный вывод номера строки
SET @rownum := 0;
SELECT actor_id, @rownum := @rownum + 1 AS rownum FROМ sakila.actor LIMIT 3;

# Подсчет количества и ранка
SET @curr_cnt := 0, @prev_cnt := 0, @rank := 0;
SELECT actor_id,
       @curr_cnt := cnt AS cnt,
       @rank := IF(@prev_cnt <> @curr_cnt, @rank + 1, @rank) AS rank, @prev_cnt := @curr_cnt AS dummy
FROМ (
SELECT actor_id, COUNT(*) AS cnt FROМ sakila.film_actor
GROUP ВУ actor_id
ORDER ВУ c n t DESC
LIMIТ 10
as der;

#+----------+-----+------+-------+
# 1 actor_id 1 cnt 1 rank 1 dummy 1
# +----------+-----+------+-------+
# 107 42 1 42
# 102 41 2 41
# 198 40 3 40
# 181 39 4 39
# 23 37 5 37
# 81 36 106 35
# 60 35 13 35
# 158 35 6 36
# 7 35 7 35
# 7 35 7 35
# +----------+-----+------+-------+



