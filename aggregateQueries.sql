#---------------------------------------------------------------
# Demonstrating Aggregate Queries ( need cumulative Data) 
# 1. Filtering using HAVING 
# 2. Different aggregate functions like MAX(),MIN(),AVG(),COUNT(),SUM(),etc...
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------

################################################################
#  Aggregate Functions  (returns a single value for multiple rows)
################################################################
# 1. COUNT()  
-- returns count of non-null values. 
-- Scenario 1: Count students with batches assigned (i.e., non-null b_id)
SELECT COUNT(s.id) AS 'total students',COUNT(s.batchId) AS 'Batch students'
FROM myworld.scaler_student s;  
-- Scenario 2: Count Students based on all columns. 
SELECT COUNT(*)
FROM myworld.scaler_student s; 
-- scenario 3: Count students based on 2 columns. 
SELECT COUNT(CONCAT(firstName + lastName))
FROM myworld.scaler_student s; 
-- ERROR ! mutliple columns won't work , instead concatenate them into single value and then apply count()
################################################################
#  GROUP BY  CLAUSE
################################################################
-- Give me count of students, max psp for each batch. 
SELECT s.batchId, COUNT(*) , MAX(s.psp) 
FROM myworld.scaler_student s 
GROUP BY s.batchId
;
-- Give me count of customers residing in same city and have common sales employee whose customer number is odd. 
SELECT c.city,c.salesRepEmployeeNumber,COUNT(*) 
FROM classicmodels.customers c 
WHERE c.customerNumber%2=1
GROUP BY c.city,c.salesRepEmployeeNumber
;

################################################################
#  HAVING Clause (to filter groups )  
################################################################
-- give me count of customers residing in USA,france,germany for every sales employee who have average credit limit of 25000 or more.
SELECT c.salesRepEmployeeNumber,COUNT(*)
FROM classicmodels.customers c 
WHERE c.country IN('USA','FRANCE','GERMANY')
GROUP BY c.salesRepEmployeeNumber
HAVING AVG(c.creditLimit) >=25000
ORDER BY COUNT(*) DESC;