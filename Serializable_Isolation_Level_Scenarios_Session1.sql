#---------------------------------------------------------------
# Demonstrating Serializable Isolation level. 
# Range Locks + Shared Locks are present on row(s) 
# CASE 1 : Multiple Reads 
# Here, transaction with read intent will acquire a read lock on range of rows matching search criteria. 
# it will block write transactions on same set of rows until the read lock is released. 
# it will allow read transactions on same set of rows. 
# CASE 2: Multiple Writes 
# Here, transaction with write intent acquire a write lock on range of rows matching search criteria. 
# it will block read/write transactions on same set of rows until the write lock is released. 
# PROS: 
# Highest Consistency is achieved. 
# No Dirty Reads
# No Non-Repeatable Reads  
# No phantom reads 
# CONS: 
# lowest performance. 
# Probability of deadlocks increases here due to increase in row locks. 
# Use case: Bank Transaction/ Booking apps
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------
################################################################
# Scenario 1 : Dirty Read
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 

START TRANSACTION;
-- read the customer name with id 1. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- execute the update customer first_name to xyz in another session but don't commit it. 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- it's not able to see xyz but MARY(i.e., it's not doing DIRTY READ) WHILE OTHER TRANSACTION WITH WRITE INTENT IS BLOCKED. 
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
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 

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
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 

START TRANSACTION;

-- Read the inactive customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- update an exisiting customer to inactive with id = 3 and commit. in session 2.
-- THE OTHER TRANSACTONS WITH WRITE INTENT ON ALL ROWS AS PER SEARCH CONDITION WERE BLOCKED BY RANGE LOCKS HELD BY CURRENT TRANSACTION.   
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works ! 
-- ISSUE OF Non-Repeatable Read is fixed . 

-- Rollback the transaction.
ROLLBACK;

################################################################
# Scenario 3.1 : UNDERSTANDING RANGE LOCKS BASED ON SEARCH CONDITION OR NOT. 
# Session 1 will just read customers with specific range of id's. 5,6,7,8
# Session 2 will update an exisiting customer to inactive with id out of range. say 3. 
# Session 2 will end the current transaction and start another transaction. 
# Session 2 will update an exisiting customer to inactive with id in same range. SAY IN (5,6,7,8)
# Session 1 will end the transaction. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 

START TRANSACTION;

-- Read the customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.customer_id IN (5,6,7,8); 
-- update an exisiting customer to inactive with id = 3 and commit. in session 2.
-- OTHER TRANSACTION WITH WRITE INTENT WERE NOT BLOCKED.  
-- update an exisiting customer to inactive with id IN (5,6,7,8) and commit. in session 2.
-- TRANSACTIONS WAITING FOR CURRENT TRANSACTION TO RELEASE THE RANGE LOCK ON ROWS. 
-- Rollback the transaction.
ROLLBACK;

################################################################
# Scenario 4: Phantom Read problem 
# Session 1 will just read inactive customers with odd id. (matching search criteria. ) 
# Session 2 will insert a new customer with id 601 to active and commit. 
# Session 1 will read inactive customers with odd id again. 
# Session 1 will update the customer with id 601 to inactive.
# Session 1 will read inactive customers with odd id again and will get this 601 record. 
################################################################

show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 

START TRANSACTION;

-- Read the inactive customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Session 2 will insert a new customer with id 601 to active. 
-- TRANSACTION WITH WRITE INTENT GETTING BLOCKED BY THE CURRENT TRANSACTION.
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works ! It's reading the same data only due to range lock. 
-- let's try to update customer with id 601 to inactive. 
UPDATE sakila.customer c 
SET c.active =0
WHERE c.customer_id = 601; 
-- no phantom read problem. zero rows were updated as 601 was never inserted. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Rollback the transaction.
ROLLBACK;

################################################################
# Scenario 4.1: Phantom read problem with inserting a new row with even id (i.e., not matching search criteria)
# Session 1 will just read inactive customers with odd id. 
# Session 2 will insert a new customer with id 602 to active and commit. 
# Session 1 will read inactive customers with odd id again. 
# Session 1 will update the customer with id 602 to inactive.
# Session 1 will read inactive customers with odd id again and will get this 601 record. 
################################################################

show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 

START TRANSACTION;

-- Read the inactive customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Session 2 will insert a new customer with id 602 to active. 
-- TRANSACTION WITH WRITE INTENT GETTING BLOCKED BY THE CURRENT TRANSACTION.
-- Read the list again.  
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- works ! It's reading the same data only due to range lock. 
-- let's try to update customer with id 602 to inactive. 
UPDATE sakila.customer c 
SET c.active =0
WHERE c.customer_id = 602; 
-- no phantom read problem. zero rows were updated as 602 was never inserted. 
SELECT *
FROM sakila.customer c 
WHERE c.active=0 AND c.customer_id%2=1; 
-- Rollback the transaction.
ROLLBACK;


