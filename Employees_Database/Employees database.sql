-- Create a visualization that provides a breakdown between the male and 
-- female employees working in the company each year, starting from 1990. 

SELECT 
    YEAR(de.from_date) AS calendar_year,
    ee.gender AS gender,
    COUNT(ee.emp_no) as num_of_employees
FROM
    t_employees ee
        JOIN
    t_dept_emp de ON ee.emp_no = de.emp_no
GROUP BY calendar_year, gender
having calendar_year >= 1990;

-- Compare the number of male managers to the number of female managers 
-- from different departments for each year, starting from 1990.

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
GROUP BY dm.emp_no , calendar_year , d.dept_name;

-- Compare the average salary of female versus male employees in the entire company 
-- until year 2002, and add a filter allowing you to see that per each department.

SELECT 
    ee.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 0) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM
    t_employees ee
        JOIN
    t_salaries s ON ee.emp_no = s.emp_no
        JOIN
    t_dept_emp de ON s.emp_no = de.emp_no
        JOIN
    t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_no , ee.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;

-- Create an SQL stored procedure that will allow you to obtain the average male and 
-- female salary per department within a certain salary range. Let this range be defined
-- by two values the user can insert when calling the procedure.

DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT 
    e.gender, d.dept_name, round(AVG(s.salary),0) as avg_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END$$

DELIMITER ;

CALL filter_salary(50000, 90000);


