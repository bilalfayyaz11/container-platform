USE company_db;

SELECT COUNT(*) AS employee_count
FROM employees;

SELECT department,
       COUNT(*) AS employees,
       AVG(salary) AS average_salary
FROM employees
GROUP BY department;

SELECT *
FROM employees
ORDER BY salary DESC;

SHOW TABLES;

SHOW DATABASES;
