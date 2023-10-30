#---------------------------------------------------------------
# Demonstrating Read Committed Isolation level. 
# Read committed reads the latest committed data (i.e., persisted data only )
# PROS: 
# higher performacne than repeatable read level.
# No Dirty Reads 
# CONS: 
# Non-repeatable reads
## lower performance than read uncommitted level
# Use case: 
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------
################################################################
# Scenario 2: Session 1 write on same row and Session 2 writes on same row. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; 

START TRANSACTION;

-- Read the customer name with id 1 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- execute the update customer first_name to TransactionSession1 and don't commit it. 
UPDATE sakila.customer c 
SET c.first_name = 'TransactionSession1'
WHERE c.customer_id = 1; 
-- execute the update customer first_name for same row in another session parallely. 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- able to see TransactionSession1 (as expected) but it have a write lock so another transaction dies due to starvation.  
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- works ! able to see TransactionSession1 as first name (as expected)

-- Rollback the transaction.
ROLLBACK;



