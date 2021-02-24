# Использование переменной для возврата нового значения
UPDATE tl SET lastUpdated =NOW() WHERE id =1 AND @now := NOW();
SELECТ @now;

# Возвращает количество обновленных строки, а клиентский протокол вернет обзее количество. Тем самым мы получим, сколько
# было обновлено, а сколько вставлено
INSERT INTO tl(cl, с2) VALUES(4, 4), (2, 1), (3, 1) ON DUPLICATE КЕY UPDATE cl = VALUES(cl) + ( 0 * ( @х := @х +1 ) );

# При использовании условией по переменным, использовать их непосредственно в условии
SET @rownum := 0; mysql> SELECT actor_id, @rownum AS rownum FROМ sakila.actor WНERE (@rownum := @rownum + 1) <= 1;

# Выбирем значение из второй таблице только для тех записей, если значение не найдено в первой
SELECT GREATEST(@found := -1, id) AS id, 'users' AS which_tbl FROM users WHERE id =1
UNION ALL
SELECT id, 'users_archived'
FROM users_archived WHERE id =1 AND @found IS NULL UNION ALL
SELECT 1, 'reset' FROM DUAL WHERE ( @found := NULL ) IS NOT NULL;