#---------------------------------------------------------------
# Demonstrating Read Uncommitted Isolation level. 
# Read Uncommitted reads the latest data (i.e., data from RAM if available , disk otherwise. )
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------
################################################################
# To get all the MYSQL variables to check default values. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to turn off autocommit. 
SET autocommit='OFF';
START TRANSACTION;
-- Read the customer name with id 1 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- execute the update customer first_name to xyz in another session but don't commit it. 
UPDATE sakila.customer c 
SET c.first_name = 'xyz'
WHERE c.customer_id = 1; 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila
.customer c 
WHERE c.customer_id='1'; 
ROLLBACK; 