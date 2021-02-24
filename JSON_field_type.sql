CREATE TABLE employee
(
    employee_detail JSON,
    employee_id     varchar(255) GENERATED ALWAYS AS
                        (employee_detail ->> '$.employee_id'),
    INDEX idx_employee_id (employee_id)
);

INSERT INTO employee (employee_detail)
values ('{
  "employee_id": "emp_0000001",
  "employee_first_name": "john",
  "employee_last_name": "carry",
  "employee_total_experience_in_years": "6.5",
  "employee_join_date": "2013-03-01",
  "employee_email_address": "john_carry@email.com"
}'),
       ('{
         "employee_id": "emp_0000002",
         "employee_first_name": "bill",
         "employee_last_name": "watson",
         "employee_total_experience_in_years": "9.5",
         "employee_join_date": "2010-05-01",
         "employee_email_address": "bill_watson@email.com"
       }'),
       ('{
         "employee_id": "emp_0000003",
         "employee_first_name": "sara",
         "employee_last_name": "perry",
         "employee_total_experience_in_years": "14.5",
         "employee_join_date": "2006-07-01",
         "employee_email_address": "sara_perry@email.com"
       }');

select * from employee;
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
| employee_detail                                                                                                                                                                                                                   | employee_id |
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
| {"employee_id": "emp_0000001", "employee_join_date": "2013-03-01", "employee_last_name": "carry", "employee_first_name": "john", "employee_email_address": "john_carry@email.com", "employee_total_experience_in_years": "6.5"}   | emp_0000001 |
| {"employee_id": "emp_0000002", "employee_join_date": "2010-05-01", "employee_last_name": "watson", "employee_first_name": "bill", "employee_email_address": "bill_watson@email.com", "employee_total_experience_in_years": "9.5"} | emp_0000002 |
| {"employee_id": "emp_0000003", "employee_join_date": "2006-07-01", "employee_last_name": "perry", "employee_first_name": "sara", "employee_email_address": "sara_perry@email.com", "employee_total_experience_in_years": "14.5"}  | emp_0000003 |
| {"employee_id": "emp_0000001", "employee_join_date": "2013-03-01", "employee_last_name": "carry", "employee_first_name": "john", "employee_email_address": "john_carry@email.com", "employee_total_experience_in_years": "6.5"}   | emp_0000001 |
| {"employee_id": "emp_0000002", "employee_join_date": "2010-05-01", "employee_last_name": "watson", "employee_first_name": "bill", "employee_email_address": "bill_watson@email.com", "employee_total_experience_in_years": "9.5"} | emp_0000002 |
| {"employee_id": "emp_0000003", "employee_join_date": "2006-07-01", "employee_last_name": "perry", "employee_first_name": "sara", "employee_email_address": "sara_perry@email.com", "employee_total_experience_in_years": "14.5"}  | emp_0000003 |
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
6 rows in set (0.00 sec)



SELECT employee_detail ->> '$.employee_join_date' as joining_date
FROM employee
WHERE employee_id = 'emp_0000002';
+--------------+
| joining_date |
+--------------+
| 2010-05-01   |
| 2010-05-01   |
+--------------+
2 rows in set (0.00 sec)

DESCRIBE
SELECT employee_detail ->> '$.employee_join_date' as joining_date
FROM employee
WHERE employee_id = 'emp_0000002';
+----+-------------+----------+------------+------+-----------------+-----------------+---------+-------+------+----------+-------+
| id | select_type | table    | partitions | type | possible_keys   | key             | key_len | ref   | rows | filtered | Extra |
+----+-------------+----------+------------+------+-----------------+-----------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | employee | NULL       | ref  | idx_employee_id | idx_employee_id | 258     | const |    2 |   100.00 | NULL  |
+----+-------------+----------+------------+------+-----