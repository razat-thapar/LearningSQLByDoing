#---------------------------------------------------------------
# Demonstrating Read Committed Isolation level. 
# Read committed reads the latest committed data (i.e., persisted data only )
# PROS: 
# higher performacne than repeatable read level.
# No Dirty Reads 
# CONS: 
# Non-repeatable reads
# Phantom Reads
## lower performance than read uncommitted level
# Use case: 
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------
################################################################
# Scenario 1 : Dirty Read
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
-- execute the update customer first_name to xyz in another session but don't commit it. 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- not able to see xyz but MARY(i.e., it's not doing DIRTY READ) 
-- Rollback the transaction in another session (i.e., session 2 )
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- works ! able to see MARY as first name only(it's reading persisted data. )

ROLLBACK;

################################################################
# Scenario 2: Starvation of another write transaction in case of multiple writes. 
# Session 1 write on same row and Session 2 writes on same row. 
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
-- update an exisiting customer to inactive with id = 3 and commit. 
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works ! able to see Non-Repeatable Read issue as expected. 

-- Rollback the transaction.
ROLLBACK;
