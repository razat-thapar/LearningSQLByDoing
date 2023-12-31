#---------------------------------------------------------------
# Demonstrating Repeatable Read Isolation level. 
# reads the data 
# CASE 1: First Time 
# reads the committed data. 
# CASE 2: Subsequent Times (like 2nd time, 3rd time , etc...)
# Reads the committed data from 1st time only. (maintains a snapshot of first time and reads from there.) 
# PROS: 
# higher performacne than serializable.
# No Dirty Reads
# No Non-Repeatable Reads  
# CONS: 
# Phantom Reads
# Extra space is required to store the snapshot. 
## lower performance than read uncommitted & read committed levels. 
# Use case: Sending emails based on psp <80 and marking sent_email field as true in DB. 
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------
################################################################
# Scenario 1 : Dirty Read
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to repeatable read
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

START TRANSACTION;

-- execute the update customer first_name to xyz in another session but don't commit it. 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- On 1st time , it's not able to see xyz but MARY(i.e., it's not doing DIRTY READ) 
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
-- to set isolation level of a session to REPEATABLE READ 
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

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
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

START TRANSACTION;

-- Read the inactive customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- update an exisiting customer to inactive with id = 3 and commit. in session 2.  
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works ! 
-- ISSUE OF Non-Repeatable Read is fixed . 

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
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

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
-- works ! It's reading the data from snapshot only.  
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

################################################################
# Scenario 5: Phantom Read problem 2 
# Session 1 will just read inactive customers with odd id. 
# Session 2 will insert a new customer with id 601 to active and commit. 
# Session 2 will insert a new customer with id 603 to inactive. and commit. 
# Session 1 will read inactive customers with odd id again. 
# Session 1 will update the customer with id 601 to inactive.
# Session 1 will read inactive customers with odd id again and will get this 601 record. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

START TRANSACTION;

-- Read the inactive customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Session 2 will insert a new customer with id 601,603 to active. 
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works ! It's reading the data from snapshot only.  
-- let's try to update customer with id 601 to inactive. 
UPDATE sakila.customer c 
SET c.active =0
WHERE c.customer_id = 601; 
-- Phantom READ problem. 
-- Ideally, this update shouldn't have worked as no records with id 601 should be present as it's updated by another session. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Here, only 601 record pops up unexpectedly while 603 record didn't show up as expected. 
-- Rollback the transaction.
ROLLBACK;