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

################################################################
# Scenario 3: Non-Repeatable Read problem 
# Session 1 will just read inactive customers with odd id. 
# Session 2 will update an exisiting customer to inactive with id = 3. 
# Session 1 will read inactive customers with odd id again but list will not match. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

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

################################################################
# Scenario 4: Phantom Read problem 
# Session 1 will just read inactive customers with odd id. 
# Session 2 will insert a new customer with id 601 to active and commit. 
# Session 1 will read inactive customers with odd id again. 
# Session 1 will update the customer with id 601 to inactive.
# Session 1 will read inactive customers with odd id again and will get this 601 record. 
################################################################

show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

START TRANSACTION;

-- Read the inactive customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Session 2 will insert a new customer with id 601 to active. 
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works as expected! 
-- let's try to update customer with id 601 to inactive. 
UPDATE sakila.customer c 
SET c.active =0
WHERE c.customer_id = 601; 
-- Phantom READ problem. 
-- Ideally, this update shouldn't have worked as no records with id 601 should be present as it's updated by another session. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Rollback the transaction.
ROLLBACK;