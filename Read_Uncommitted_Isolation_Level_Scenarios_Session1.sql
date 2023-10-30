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
# Scenario 1: Dirty Read 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read uncommitted. 
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
-- to verify the isolation level. 
show variables
Like 'transaction_%';
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
-- able to see xyz (i.e., it's doing DIRTY READ) 
-- Rollback the transaction in another session (i.e., machine 2 )
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- works ! able to see MARY as first name again. (it's reading persisted data.  )
ROLLBACK;

################################################################
# Scenario 2 : Starvation of another write transaction in case of concurrent writes. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read uncommitted. 
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
-- to verify the isolation level. 
show variables
Like 'transaction_%';
START TRANSACTION;
-- Read the customer name with id 1 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- update the customer name to 'RazatTransaction1' for id 1 
UPDATE sakila.customer c 
SET c.first_name='RazatTransaction1'
WHERE c.customer_id=1;
-- execute the update on customer name to 'RazatTransaction2' for id 1 in another session with Read Uncommitted level. 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- able to see xyz (i.e., it's doing DIRTY READ) 
-- Rollback the transaction in another session (i.e., machine 2 )
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- works ! able to see MARY as first name again. (it's reading persisted data.  )
ROLLBACK;