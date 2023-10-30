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
# Scenario 3: Non-Repeatable Read problem 
# Session 1 will just read inactive customers with odd id. 
# Session 2 will update an exisiting customer to inactive with id = 3. 
# Session 1 will read inactive customers with odd id again but list will not match. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; 

START TRANSACTION;

-- Read the inactive customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- update an exisiting customer to inactive with id = 3. 
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works ! able to see Non-Repeatable Read issue as expected. 

-- Rollback the transaction.
ROLLBACK;



