#---------------------------------------------------------------
# Demonstrating Read Uncommitted Isolation level. 
# Read Uncommitted reads the latest data (i.e., data from RAM if available , disk otherwise. )
# PROS: 
# # highest performance but lowest consistency.
# CONS: 
# Dirty Read
# Non-Repeatable Read
# Phantom Read 
# Use case: updating and reading the live count of users watching a cricket match on hotstar.
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------

################################################################
# Scenario 1 : Dirty Read
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

################################################################
# Scenario 2: Starvation of another write transaction in case of concurrent writes. 
################################################################
show variables
Like '%transaction%'; 
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

-- Read the customer name with id 1 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- update the customer name to 'RazatTransaction2' for id 1 
UPDATE sakila.customer c 
SET c.first_name='RazatTransaction2'
WHERE c.customer_id=1;
-- This transaction will get blocked until the transaction 1 ends. 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1';
 
ROLLBACK; 