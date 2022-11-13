-- VACUUM MVCC-6. Очистка
-- Внутристраничная очистка выполняется быстро, но освобождает только часть места. Она работает в пределах одной табличной страницы и не затрагивает индексы.
-- Основная, «обычная» очистка выполняется командой VACUUM и ее мы будем называть просто очисткой (а про автоочистку мы будем говорить отдельно).
CREATE TABLE vac(
  id serial,
  s char(100)
) WITH (autovacuum_enabled = off);
CREATE INDEX vac_s ON vac(s);
INSERT INTO vac(s) VALUES ('A');
UPDATE vac SET s = 'B';
UPDATE vac SET s = 'C';




-------------------- MVCC-5. Внутристраничная очистка и HOT
-- Размер этих разделов легко узнать с помощью «исследовательского» расширения pageinspect:
CREATE EXTENSION pageinspect;

-- Подробнаястатистика по странице данных
CREATE FUNCTION heap_page(relname text, pageno integer)
RETURNS TABLE(ctid tid, state text, xmin text, xmax text, hhu text, hot text, t_ctid tid)
AS $$
SELECT (pageno,lp)::text::tid AS ctid,
       CASE lp_flags
         WHEN 0 THEN 'unused'
         WHEN 1 THEN 'normal'
         WHEN 2 THEN 'redirect to '||lp_off
         WHEN 3 THEN 'dead'
       END AS state,
       t_xmin || CASE
         WHEN (t_infomask & 256) > 0 THEN ' (c)'
         WHEN (t_infomask & 512) > 0 THEN ' (a)'
         ELSE ''
       END AS xmin,
       t_xmax || CASE
         WHEN (t_infomask & 1024) > 0 THEN ' (c)'
         WHEN (t_infomask & 2048) > 0 THEN ' (a)'
         ELSE ''
       END AS xmax,
       CASE WHEN (t_infomask2 & 16384) > 0 THEN 't' END AS hhu,
       CASE WHEN (t_infomask2 & 32768) > 0 THEN 't' END AS hot,
       t_ctid
FROM heap_page_items(get_raw_page(relname,pageno))
ORDER BY lp;
$$ LANGUAGE SQL;

-- Функция для заглядывания внутрь индексной страницы
CREATE FUNCTION index_page(relname text, pageno integer)
RETURNS TABLE(itemoffset smallint, ctid tid)
AS $$
SELECT itemoffset,
       ctid
FROM bt_page_items(relname,pageno);
$$ LANGUAGE SQL;

-- Проверим, как работает внутристраничная очистка. Для этого вставим одну строку и несколько раз изменим ее:
CREATE TABLE hot(id integer, s char(2000)) WITH (fillfactor = 75);
CREATE INDEX hot_id ON hot(id);
CREATE INDEX hot_s ON hot(s);

INSERT INTO hot VALUES (1, 'A');
UPDATE hot SET s = 'B';
UPDATE hot SET s = 'C';
UPDATE hot SET s = 'D';

SELECT * FROM heap_page('hot',0);
+-----+------+--------+--------+----+----+------+
|ctid |state |xmin    |xmax    |hhu |hot |t_ctid|
+-----+------+--------+--------+----+----+------+
|(0,1)|normal|6350 (c)|6351 (c)|NULL|NULL|(0,2) |
|(0,2)|normal|6351 (c)|6352 (c)|NULL|NULL|(0,3) |
|(0,3)|normal|6352 (c)|6353    |NULL|NULL|(0,4) |
|(0,4)|normal|6353    |0 (a)   |NULL|NULL|(0,4) |
+-----+------+--------+--------+----+----+------+

SELECT lower, upper, pagesize FROM page_header(get_raw_page('hot',0));
+-----+-----+--------+
|lower|upper|pagesize|
+-----+-----+--------+
|40   |64   |8192    |
+-----+-----+--------+


-- Итак, при следующем обращении к странице должна произойти внутристраничная очистка. Проверим это.
UPDATE hot SET s = 'E';

SELECT * FROM heap_page('hot',0);
+-----+------+--------+-----+----+----+------+
|ctid |state |xmin    |xmax |hhu |hot |t_ctid|
+-----+------+--------+-----+----+----+------+
|(0,1)|dead  |NULL    |NULL |NULL|NULL|NULL  |
|(0,2)|dead  |NULL    |NULL |NULL|NULL|NULL  |
|(0,3)|dead  |NULL    |NULL |NULL|NULL|NULL  |
|(0,4)|normal|6353 (c)|6354 |NULL|NULL|(0,5) |
|(0,5)|normal|6354    |0 (a)|NULL|NULL|(0,5) |
+-----+------+--------+-----+----+----+------+

-- Указатели на удаленные версии строк освободить нельзя, поскольку на них существует ссылки из индексной страницы. Посмотрим в первую страницу индекса hot_s (потому что нулевая занята метаинформацией):
SELECT * FROM index_page('hot_s',1);
+----------+-----+
|itemoffset|ctid |
+----------+-----+
|1         |(0,1)|
|2         |(0,2)|
|3         |(0,3)|
|4         |(0,4)|
|5         |(0,5)|
+----------+-----+

SELECT * FROM index_page('hot_id',1);
+----------+-----+
|itemoffset|ctid |
+----------+-----+
|1         |(0,1)|
|2         |(0,2)|
|3         |(0,3)|
|4         |(0,4)|
|5         |(0,5)|
+----------+-----+

------------------------MVCC-6. Очистка
-- Сейчас в таблице три версии строки, и на каждую ведет ссылка из индекса:
SELECT * FROM heap_page('vac',0);
+-----+------+--------+--------+----+----+------+
|ctid |state |xmin    |xmax    |hhu |hot |t_ctid|
+-----+------+--------+--------+----+----+------+
|(0,1)|normal|6328 (c)|6329 (c)|NULL|NULL|(0,2) |
|(0,2)|normal|6329 (c)|6330    |NULL|NULL|(0,3) |
|(0,3)|normal|6330    |0 (a)   |NULL|NULL|(0,3) |
+-----+------+--------+--------+----+----+------+

SELECT * FROM index_page('vac_s',1);
+----------+-----+
|itemoffset|ctid |
+----------+-----+
|1         |(0,1)|
|2         |(0,2)|
|3         |(0,3)|
+----------+-----+

-- После очистки «мертвые» версии пропадают и остается только одна, актуальная. И в индексе тоже остается одна ссылка:
VACUUM vac;
SELECT * FROM heap_page('vac',0);
+-----+------+--------+-----+----+----+------+
|ctid |state |xmin    |xmax |hhu |hot |t_ctid|
+-----+------+--------+-----+----+----+------+
|(0,1)|unused|NULL    |NULL |NULL|NULL|NULL  |
|(0,2)|unused|NULL    |NULL |NULL|NULL|NULL  |
|(0,3)|normal|6330 (c)|0 (a)|NULL|NULL|(0,3) |
+-----+------+--------+-----+----+----+------+

SELECT * FROM index_page('vac_s',1);
+----------+-----+
|itemoffset|ctid |
+----------+-----+
|1         |(0,3)|
+----------+-----+
-- Обратите внимание, что два первых указателя получили статус unused, а не dead, как было бы при внутристраничной очистке.


-- Как оценить плотность информации? Для этого удобно воспользоваться специальным расширением:
CREATE EXTENSION pgstattuple;

INSERT INTO vac(s) SELECT 'A' FROM generate_series(1,500000);

SELECT * FROM pgstattuple('vac') \gx
SELECT * FROM pgstatindex('vac_s') \gx
--  какой размер занимание таблица и индекс
SELECT pg_size_pretty(pg_table_size('vac')) table_size,
  pg_size_pretty(pg_indexes_size('vac')) index_size;

DELETE FROM vac WHERE random() < 0.9;

-- обычная чиска, какой размер
VACUUM vac;
SELECT pg_size_pretty(pg_table_size('vac')) table_size,
  pg_size_pretty(pg_indexes_size('vac')) index_size;

-- | table\_size | index\_size |
-- | :--- | :--- |
-- | 67 MB | 3424 kB |


VACUUM FULL vac;
SELECT pg_size_pretty(pg_table_size('vac')) table_size,
  pg_size_pretty(pg_indexes_size('vac')) index_size;
-- | table\_size | index\_size |
-- | :--- | :--- |
-- | 6920 kB | 416 kB |



