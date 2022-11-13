# Horizontal partitioning with range

CREATE TABLE access_log
(
    log_id        INT       NOT NULL,
    type          VARCHAR(100),
    access_url    VARCHAR(100),
    access_date   TIMESTAMP NOT NULL,
    response_time INT       NOT NULL,
    access_by     INT       NOT NULL
)
    PARTITION BY RANGE (UNIX_TIMESTAMP(access_date)) (
        PARTITION p0 VALUES LESS THAN (UNIX_TIMESTAMP('2017-05-01 00:00:00')),
        PARTITION p1 VALUES LESS THAN (UNIX_TIMESTAMP('2017-09-01 00:00:00')),
        PARTITION p2 VALUES LESS THAN (UNIX_TIMESTAMP('2018-01-01 00:00:00')),
        PARTITION p3 VALUES LESS THAN (UNIX_TIMESTAMP('2018-05-01 00:00:00')),
        PARTITION p4 VALUES LESS THAN (UNIX_TIMESTAMP('2018-09-01 00:00:00')),
        PARTITION p5 VALUES LESS THAN (UNIX_TIMESTAMP('2019-01-01 00:00:00'))
        );



SELECT PARTITION_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'access_log';


# Horizontal partitioning with hash
CREATE TABLE access_log_2
(
    log_id        INT       NOT NULL,
    type          VARCHAR(100),
    access_url    VARCHAR(100),
    access_date   TIMESTAMP NOT NULL,
    response_time INT       NOT NULL,
    access_by     INT       NOT NULL,
    website_id    INT
)
    PARTITION BY HASH (website_id)
        PARTITIONS 4;


# Range column partitioning
CREATE TABLE rc1
(
    a INT,
    b INT
)
    PARTITION BY RANGE COLUMNS (a, b) (
        PARTITION p0 VALUES LESS THAN (5, 12),
        PARTITION p3 VALUES LESS THAN (MAXVALUE, MAXVALUE)
        );


