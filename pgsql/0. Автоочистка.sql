-- создадим представление, показывающее, какие таблицы в данный момент нуждаются в очистке.
CREATE FUNCTION get_value(param text, reloptions text[], relkind "char")
    RETURNS float
AS $$
SELECT coalesce(
           -- если параметр хранения задан, то берем его
               (SELECT option_value
                FROM   pg_options_to_table(reloptions)
                WHERE  option_name = CASE
                                         -- для toast-таблиц имя параметра отличается
                                         WHEN relkind = 't' THEN 'toast.' ELSE ''
                                         END || param
               ),
           -- иначе берем значение конфигурационного параметра
               current_setting(param)
           )::float;
$$ LANGUAGE sql;


CREATE VIEW need_vacuum AS
SELECT st.schemaname || '.' || st.relname tablename,
       st.n_dead_tup dead_tup,
       get_value('autovacuum_vacuum_threshold', c.reloptions, c.relkind) +
       get_value('autovacuum_vacuum_scale_factor', c.reloptions, c.relkind) * c.reltuples
                                          max_dead_tup,
       st.last_autovacuum
FROM   pg_stat_all_tables st,
       pg_class c
WHERE  c.oid = st.relid
  AND    c.relkind IN ('r','m','t');


CREATE VIEW need_analyze AS
SELECT st.schemaname || '.' || st.relname tablename,
       st.n_mod_since_analyze mod_tup,
       get_value('autovacuum_analyze_threshold', c.reloptions, c.relkind) +
       get_value('autovacuum_analyze_scale_factor', c.reloptions, c.relkind) * c.reltuples
                                          max_mod_tup,
       st.last_autoanalyze
FROM   pg_stat_all_tables st,
       pg_class c
WHERE  c.oid = st.relid
  AND    c.relkind IN ('r','m');


-- Для экспериментов установим такие значение параметров:

ALTER SYSTEM SET autovacuum_naptime = ‘1s’; -- чтобы долго не ждать
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.03;  -- 3%
ALTER SYSTEM SET autovacuum_vacuum_threshold = 0;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.02; -- 2%
ALTER SYSTEM SET autovacuum_analyze_threshold = 0;

CREATE TABLE autovac(
                        id serial,
                        s char(100)
) WITH (autovacuum_enabled = off);
INSERT INTO autovac SELECT g.id,'A' FROM generate_series(1,1000) g(id);

SELECT * FROM need_vacuum WHERE tablename = 'public.autovac';