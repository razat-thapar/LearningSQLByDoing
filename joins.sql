#---------------------------------------------------------------
# Demonstrating DIFFERENT TYPES OF TABLE JOINS 
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
# LEFT OUTER JOIN / LEFT JOIN 
#---------------------------------------------------------------

#---------------------------------------------------------------
# RIGHT OUTER JOIN / RIGHT JOIN
#---------------------------------------------------------------
#---------------------------------------------------------------
# FULL OUTER JOIN / FULL JOIN
#---------------------------------------------------------------
#---------------------------------------------------------------
# CROSS JOIN
#---------------------------------------------------------------