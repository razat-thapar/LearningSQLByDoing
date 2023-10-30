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
# Use case: 
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
-- execute the update customer first_name to xyz in another session but don't commit it. 
UPDATE sakila.customer c 
SET c.first_name = 'xyz'
WHERE c.customer_id = 1; 
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
-- to set isolation level of a session to read committed. 
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

START TRANSACTION;

-- update an exisiting customer to inactive with id = 3 and COMMIT.  
UPDATE sakila.customer c 
SET c.active =0 
WHERE c.customer_id = 3;

COMMIT;
## end the transaction

#-- revert the changes. 
START TRANSACTION;
-- update an exisiting customer to active with id = 3 and COMMIT.  
UPDATE sakila.customer c 
SET c.active =1 
WHERE c.customer_id = 3;
COMMIT;

################################################################
# Scenario 4: Phantom Read problem 
# Session 1 will just read inactive customers with odd id. 
# Session 2 will insert a new customer with id 601 to active.
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
-- verify 
SELECT * 
FROM sakila.customer c 
WHERE c.customer_id='601'; 

COMMIT;
## end the transaction

#-- revert the changes. 
START TRANSACTION;
-- update an exisiting customer to active with id = 3 and COMMIT.  
DELETE FROM sakila.customer c
WHERE c.customer_id = '601';
COMMIT;