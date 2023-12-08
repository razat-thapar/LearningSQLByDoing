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