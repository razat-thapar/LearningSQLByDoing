#---------------------------------------------------------------
# Demonstrating Serializable Isolation level. 
# Range Locks + Shared Locks are present on row(s) 
# CASE 1 : Multiple Reads 
# Here, transaction with read intent will acquire a read lock on range of rows matching search criteria. 
# it will block write transactions on same set of rows until the write lock is released. 
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
# Scenario 1: Dirty Read 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ
 
START TRANSACTION;

-- Read the customer name with id 1 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 
-- execute the update customer first_name to xyz in this session but don't commit it. 
UPDATE sakila.customer c 
SET c.first_name = 'xyz'
WHERE c.customer_id = 1; 
-- THIS IS GETTING BLOCKED BY SERIALIZED TRANSACTION WITH READ INTENT. 
-- Read the customer name with id 1 again. 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='1'; 

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
-- execute the update customer first_name to TransactionSession2 and don't commit it. 
UPDATE sakila.customer c 
SET c.first_name = 'TransactionSession2'
WHERE c.customer_id = 1; 
-- Here, we will experience, this transaction waiting for other transaction(performing write) on same row. 
-- ERROR:  Error Code: 2013. Lost connection to MySQL server during query
-- It seems transaction ended due to starvation.
 
ROLLBACK;

################################################################
# Scenario 3: Non-Repeatable Read problem 
# Session 1 will just read inactive customers with odd id. 
# Session 2 will update an exisiting customer to inactive with id = 3. 
# Session 1 will read inactive customers with odd id again but list will not match. 
################################################################
show variables
Like 'transaction_%';  -- by default REPEATABLE-READ

START TRANSACTION;

-- update an exisiting customer to inactive with id = 3 and COMMIT.  
UPDATE sakila.customer c 
SET c.active =0 
WHERE c.customer_id = 3;
-- THIS TRANSACTION IS GETTING BLOCKED DUE TO RANGE LOCK ON ALL ROWS AS PER SEARCH CONDITION ON OTHER TRANSACTION.  
-- HENCE, IT WILL DIE DUE TO STARVATION. 
COMMIT;
## end the transaction


################################################################
# Scenario 3.1 : UNDERSTANDING RANGE LOCKS BASED ON SEARCH CONDITION OR NOT. 
# Session 1 will just read inactive customers with specific range of id's. 
# Session 2 will update an exisiting customer to inactive with id out of range. 
# Session 2 will end the current transaction and start another transaction. 
# Session 2 will update an exisiting customer to inactive with id in same range. 
# Session 1 will end the transaction. 
################################################################

show variables
Like 'transaction_%';  -- by default REPEATABLE-READ

START TRANSACTION;

-- update an exisiting customer to inactive with id = 3.   
UPDATE sakila.customer c 
SET c.active =0 
WHERE c.customer_id = '3';
-- THIS TRANSACTION IS NOT GETTING BLOCKED. HENCE, NO RANGE LOCK. 
ROLLBACK;
## end the transaction

START TRANSACTION;

-- update an exisiting customer to inactive with id = 6 and COMMIT.  
UPDATE sakila.customer c 
SET c.active =0 
WHERE c.customer_id =6;
-- THIS TRANSACTION IS GETTING BLOCKED DUE TO RANGE LOCK ON ALL ROWS AS PER SEARCH CONDITION ON OTHER TRANSACTION.  
-- HENCE, IT WILL DIE DUE TO STARVATION. 

ROLLBACK;
## end the transaction


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

-- insert a new customer with id 601 to active.
INSERT INTO `sakila`.`customer` (`customer_id`, `store_id`, `first_name`, `last_name`, `email`, `address_id`, `active`) 
VALUES ('601', '2', 'AUSTIN3', 'CINTRON3', 'AUSTIN3.CINTRON3@sakilacustomer.org', '605', '1');
-- TRANSACTION GETTING BLOCKED DUE TO RANGE LOCK ON ALL ROWS BY SERIALIZED TRANSACTION WITH READ INTENT. 
-- HENCE, TRANSACTION ENDED DUE TO STARVATION. 
-- verify 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='601'; 

COMMIT;
## end the transaction

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
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

START TRANSACTION;

-- insert a new customer with id 602 to active.
INSERT INTO `sakila`.`customer` (`customer_id`, `store_id`, `first_name`, `last_name`, `email`, `address_id`, `active`) 
VALUES ('602', '2', 'AUSTIN3', 'CINTRON3', 'AUSTIN3.CINTRON3@sakilacustomer.org', '605', '1');
-- TRANSACTION GETTING BLOCKED DUE TO RANGE LOCK ON ALL ROWS BY SERIALIZED TRANSACTION WITH READ INTENT. 
-- HENCE, TRANSACTION ENDED DUE TO STARVATION. 
-- verify 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='602'; 

COMMIT;
## end the transaction

################################################################
# Scenario 5: Testing whether another serializable transaction can read on same rows that are having write range lock. 
# Session 1 will update the customer with odd id to inactive and don't commit. 
# Session 2 will read the customer with odd id. 
# Session 1 will rollback
# Session 2 will again read the same rows and then rollback. 
################################################################
-- to set isolation level of a session to serializable
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 
START TRANSACTION; 
-- Read the customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.customer_id IN (1,3,5,7,9); 
-- Able to read the same rows having write lock by another transaction. 
-- session 1 will rollback. 
-- Read the customers with odd customer id again. 
SELECT *
FROM sakila.customer c 
WHERE c.customer_id IN (1,3,5,7,9); 

Rollback; 

################################################################
# Scenario 6: Testing whether another serializable transaction can read (intention is to update rows post read i.e., for update) 
# on same rows that are having read range lock. 
# Session 1 will read the customer with odd id. 
# Session 2 will read the customer with odd id for update. 
# Session 2 read will be blocked !
# Session 1 will rollback
# Session 2 will again read the same rows and then rollback. 
################################################################
-- to set isolation level of a session to serializable
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 
START TRANSACTION; 
-- Read the customers with odd customer id. 
SELECT *
FROM sakila.customer c 
WHERE c.customer_id IN (1,3,5,7,9)
FOR UPDATE
; 
-- READ FOR UPDATE is BLOCKED due to read range lock on the rows.   
-- session 1 will rollback. 
-- Read the customers with odd customer id again. 
SELECT *
FROM sakila.customer c 
WHERE c.customer_id IN (1,3,5,7,9); 
-- This time it works. 
Rollback; 