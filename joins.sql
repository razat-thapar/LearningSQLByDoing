#---------------------------------------------------------------
# Demonstrating DIFFERENT TYPES OF TABLE JOINS 
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------
# What?  
# 1. JOIN is stitching row of table A with row of table B using a join condition based on common values. 
# 2. Horizontal Merging.      
# Why ? 
# Need data from multiple tables. e.g., student , course, batch etc., to get details of each student. 
# How ? 
# Using JOIN keyword with different types as follows: 
use sakila;
#---------------------------------------------------------------
# INNER JOIN / JOIN
#---------------------------------------------------------------
-- Need customer and it's city name. 
SELECT CONCAT(cust.first_name,' ',cust.last_name) as 'customer_full_name' , c.city 
FROM customer cust 
INNER JOIN address a ON a.address_id = cust.address_id
INNER JOIN city c ON c.city_id = a.city_id 
ORDER BY 1 ASC; -- order by 1st column asc. 
#---------------------------------------------------------------
# SELF JOIN i.e., INNER JOIN with same table. 
# WHEN TO USE : 
# Same table for both roles i.e., employee act as both employee and manager. 
# Need to compare two records in the same table. 
#---------------------------------------------------------------
use classicmodels;
-- give me all employees who works for manager have jobtitle starting with sale.
SELECT e.employeeNumber,e.firstName,e.reportsTo,m.employeeNumber,m.firstName,m.jobTitle
FROM employees e
INNER JOIN employees m ON m.employeeNumber = e.reportsTo
WHERE m.jobTitle LIKE 'sale%';
#---------------------------------------------------------------
# MULTIPLE TABLE JOINS (>2 tables) 
#---------------------------------------------------------------
-- give me film name and it's film actors. 

SELECT f.title, CONCAT(a.first_name,' ',a.last_name) as 'actor_name'
FROM sakila.film f
INNER JOIN sakila.film_actor fa ON fa.film_id = f.film_id 
INNER JOIN sakila.actor a ON a.actor_id = fa.actor_id
ORDER BY f.title , actor_name ASC;
;
#---------------------------------------------------------------
# COMPOUND JOIN CONDITION 
#---------------------------------------------------------------
use classicmodels; 
-- need details of all employees reporting to manager with jobtitle starting 'sale'
select e.employeeNumber,CONCAT(e.firstName,' ',e.lastName) as 'employeeName',m.employeeNumber as 'managerNumber',m.jobTitle as 'manager job title'
from classicmodels.employees e
inner join classicmodels.employees m ON e.reportsTo=m.employeeNumber AND m.jobTitle LIKE 'sale%';

#---------------------------------------------------------------
# LEFT OUTER JOIN / LEFT JOIN 
#---------------------------------------------------------------
-- give me all customers and their corresponding sales employee number id and name.
-- print null if no such employees.. 
SELECT c.customerNumber,c.customerName,e.employeeNumber,e.firstName 
FROM classicmodels.customers c 
LEFT OUTER JOIN classicmodels.employees e ON e.employeeNumber=c.salesRepEmployeeNumber
;
#---------------------------------------------------------------
# RIGHT OUTER JOIN / RIGHT JOIN
#---------------------------------------------------------------
-- give me all employees and their customers for whom they are sales employee. 
-- print null if no such customers. 
SELECT c.customerNumber,c.customerName,e.employeeNumber,e.firstName 
FROM classicmodels.customers c 
RIGHT OUTER JOIN classicmodels.employees e ON e.employeeNumber=c.salesRepEmployeeNumber
;
#---------------------------------------------------------------
# FULL OUTER JOIN / FULL JOIN   (Mysql doesn't support this and need to use LEFT OUTER + RIGHT OUTER)
#---------------------------------------------------------------
-- give me all employees and their customers for whom they are sales employee. 
-- print null if no such customers. 
-- && give me all customers and their sales employees 
-- print null if no such employees.
SELECT c.customerNumber,c.customerName,e.employeeNumber,e.firstName 
FROM classicmodels.customers c 
LEFT OUTER JOIN classicmodels.employees e ON e.employeeNumber=c.salesRepEmployeeNumber
UNION ALL
SELECT c.customerNumber,c.customerName,e.employeeNumber,e.firstName 
FROM classicmodels.customers c 
RIGHT OUTER JOIN classicmodels.employees e ON e.employeeNumber=c.salesRepEmployeeNumber
;
#---------------------------------------------------------------
# CROSS JOIN
#---------------------------------------------------------------
-- give me cartisian product of film and language records   
SELECT f.film_id,f.title,l.language_id,l.name 
FROM sakila.film f 
CROSS JOIN sakila.language l; 
#---------------------------------------------------------------
# Implicit JOIN (another way of writing cross join)
#---------------------------------------------------------------
-- give me cartisian product of film and language records   
SELECT f.film_id,f.title,l.language_id,l.name 
FROM sakila.film f ,sakila.language l; 

#---------------------------------------------------------------
# UNION (To combine rows vertically and get distinct rows)
#---------------------------------------------------------------
-- Scenario 1: Give me all distinct firstNames of employees and customers starting with A. 
SELECT e.firstName AS 'name'
FROM classicmodels.employees e
WHERE e.firstName LIKE 'A%'
UNION 
SELECT c.contactFirstName AS 'name'
FROM classicmodels.customers c  
WHERE c.contactFirstName LIKE 'A%'
; -- 12 rows. 

-- Scenario 2: Give me all firstNames of employees and customers starting with A. (repeats allowed) 
SELECT e.firstName AS 'name'
FROM classicmodels.employees e
WHERE e.firstName LIKE 'A%'
UNION ALL 
SELECT c.contactFirstName AS 'name'
FROM classicmodels.customers c  
WHERE c.contactFirstName LIKE 'A%'
; -- 13 rows. 

-- Scenario 3: combining columns of different datatypes.  
-- Give me all records from customers.phone and employees.email
SELECT c.phone AS 'contacts'
FROM classicmodels.customers c
UNION
SELECT e.email AS 'contacts'
FROM classicmodels.employees e 
;

-- Scenario 4: Combining queries returning different count of columns. 
SELECT c.phone AS 'contacts'
FROM classicmodels.customers c
UNION
SELECT e.jobTitle,e.email AS 'contacts'
FROM classicmodels.employees e 
;
-- Error Code: 1222. The used SELECT statements have a different number of columns
