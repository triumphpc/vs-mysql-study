CREATE TABLE users_2
(
    first_name varchar(100),
    last_name  varchar(100),
    full_name  varchar(255) AS (CONCAT(first_name, ' ', last_name))
);

mysql> describe users_2;
+------------+--------------+------+-----+---------+-------------------+
| Field      | Type         | Null | Key | Default | Extra             |
+------------+--------------+------+-----+---------+-------------------+
| first_name | varchar(100) | YES  |     | NULL    |                   |
| last_name  | varchar(100) | YES  |     | NULL    |                   |
| full_name  | varchar(255) | YES  |     | NULL    | VIRTUAL GENERATED |
+------------+--------------+------+-----+---------+-------------------+
3 rows in set (0.04 sec)