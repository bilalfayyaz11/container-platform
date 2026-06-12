USE company_db;

CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    manager_id INT,
    budget DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO departments (name, budget) VALUES
('Engineering', 500000.00),
('Marketing', 200000.00),
('Sales', 300000.00),
('HR', 150000.00)
ON DUPLICATE KEY UPDATE budget = VALUES(budget);

INSERT INTO employees (first_name, last_name, email, department, salary, hire_date) VALUES
('John', 'Doe', 'john.doe@company.com', 'Engineering', 75000.00, '2023-01-15'),
('Jane', 'Smith', 'jane.smith@company.com', 'Marketing', 65000.00, '2023-02-20'),
('Mike', 'Johnson', 'mike.johnson@company.com', 'Sales', 70000.00, '2023-03-10'),
('Sarah', 'Wilson', 'sarah.wilson@company.com', 'HR', 60000.00, '2023-04-05')
ON DUPLICATE KEY UPDATE salary = VALUES(salary);

CREATE OR REPLACE VIEW employee_summary AS
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    department,
    salary,
    hire_date
FROM employees
ORDER BY hire_date;
