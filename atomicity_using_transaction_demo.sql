-- GOAL: Make customers with id 1 and 2 inactive. 
-- Understand different scenarios of Atomicity in MySQL 
#################################################################################################
## SCENARIO 1 : AUTOCOMMIT is ON & 
##              Closing the current session after making both customer 1 & 2 inactive 
##              without explicit commit
## EXPECTED BEHAVIOUR: Changes should be persisted to DB as each sql statement behaves as atomic transaction by default. 
#################################################################################################
-- verify if autocomit is on
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
SELECT * 
FROM sakila.customer;
-- Task 1:  make a customer with id=1 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 1;
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- Task 2:  make a customer with id=2 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 2; 
-- close the current session. 
-- verify the changes are persisted in DISK (DB) or not ? 
SELECT * 
FROM sakila.customer;
##------------------WORKS as Intended ! 
############### REVERT THE Changes i.e., make the customers 1 and 2 active again. ################
START TRANSACTION; 
UPDATE `sakila`.`customer` SET `active` = '1' WHERE (`customer_id` = '1');
UPDATE `sakila`.`customer` SET `active` = '1' WHERE (`customer_id` = '2'); 
COMMIT;
################  REVERT COMPLETED! ##############################################################
#################################################################################################
## SCENARIO 2 : AUTOCOMMIT is OFF & 
##              Closing the current session after making customer 1 inactive without committing. 
## EXPECTED BEHAVIOUR: Changes should not be persisted to DB and should get erased from RAM after session closure. 
#################################################################################################
-- set autocommit off.
SET autocommit = 0;
-- verify if autocomit is off
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
SELECT * 
FROM sakila.customer;
-- Task 1:  make a customer with id=1 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 1;
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- close the session here before committing. 
-- HERE, you can verify that changes were never committed to Disk and erased from RAM. 
SELECT * 
FROM sakila.customer;
####-----------------------WORKS AS expected!
 
#################################################################################################
## SCENARIO 3 : AUTOCOMMIT is OFF & 
##              Executing a ROLLBACK without a START TRANSACTION 
##              after making customer 1 and 2 inactive. Will it only rollback customer 2 or both?  
## EXPECTED BEHAVIOUR: both customers Changes should not be persisted to DB and should get erased from RAM after session closure. 
#################################################################################################
-- set autocommit off.
SET autocommit = 0;
-- verify if autocomit is off
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
SELECT * 
FROM sakila.customer;
-- Task 1:  make a customer with id=1 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 1;
-- Task 2:  make a customer with id=2 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 2; 
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- undo the changes
ROLLBACK; 
-- verify the changes.
SELECT * 
FROM sakila.customer;
####-----------------------WORKS AS expected!

#################################################################################################
## SCENARIO 4 : AUTOCOMMIT is OFF & 
##              Making 1 update on customers id 1 before START TRANSACTION AND 
##              Making 1 update on customer id 2 as one single Transaction and doing rollback in the end. 
##              Will it only rollback customer 2 or both?  
## EXPECTED BEHAVIOUR: 
##   1. Only Changes within START TRANSACTION and ROLLBACK should not be persisted to DB and should get erased from RAM after session closure.
##   2. Any uncommitted changes before START TRANSACTION; will get implicitly comitted (https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html )
##   3. Auto-commit turns off inside a Transaction. 
#################################################################################################
-- set autocommit off.
SET autocommit = 0;
-- verify if autocomit is off
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
SELECT * 
FROM sakila.customer;
-- Task 1:  make a customer with id=1 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 1;
-- Create a transaction. 
START TRANSACTION;
-- verify if autocomit is off
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
-- Task 2:  make a customer with id=2 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 2; 
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- undo the changes
ROLLBACK; 
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- verify auto-commit is off or not. 
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
-- close the session. 
-- verify the changes.
SELECT * 
FROM sakila.customer;
####-----------------------WORKS AS expected!
############### REVERT THE Changes i.e., make the customers 1 and 2 active again. ################
START TRANSACTION; 
UPDATE `sakila`.`customer` SET `active` = '1' WHERE (`customer_id` = '1');
COMMIT;
################  REVERT COMPLETED! ##############################################################
#################################################################################################
## SCENARIO 5 : AUTOCOMMIT is ON & 
##              Making two updates on customers id 1 & 2 as one single Transaction and doing rollback in the end.  
##              Will it rollback the changes ?  
## EXPECTED BEHAVIOUR: 
##   1. Only Changes within START TRANSACTION and ROLLBACK should not be persisted to DB and should get erased from RAM after session closure.
##   2. Any uncommitted changes before START TRANSACTION; will get implicitly comitted (https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html )
##   3. Auto-commit turns off inside a Transaction. 
#################################################################################################
-- verify if autocomit is on
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
SELECT * 
FROM sakila.customer;
START TRANSACTION;
-- Task 1:  make a customer with id=1 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 1;
-- verify if autocomit is off
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
-- Task 2:  make a customer with id=2 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 2; 
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- undo the changes
ROLLBACK; 
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- verify auto-commit is on or not. 
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
-- close the session. 
-- verify the changes.
SELECT * 
FROM sakila.customer;
####-----------------------WORKS AS expected!

#################################################################################################
## SCENARIO 6 : AUTOCOMMIT is ON & 
##              Making two updates on customers id 1 & 2 as one single Transaction and doing COMMIT in the end.  
##              Will it COMMIT the changes ?  
## EXPECTED BEHAVIOUR: 
##   1. Only Changes within START TRANSACTION and COMMIT should be persisted to DB and should get erased from RAM after session closure.
##   2. Any uncommitted changes before START TRANSACTION; will get implicitly comitted (https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html )
##   3. Auto-commit turns off inside a Transaction. 
#################################################################################################
-- verify if autocomit is on
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
SELECT * 
FROM sakila.customer;
START TRANSACTION;
-- Task 1:  make a customer with id=1 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 1;
-- verify if autocomit is off
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
-- Task 2:  make a customer with id=2 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 2; 
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- save the changes
COMMIT;
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- verify auto-commit is on or not. 
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
-- close the session. 
-- verify the changes.
SELECT * 
FROM sakila.customer;
####-----------------------WORKS AS expected!
############### REVERT THE Changes i.e., make the customers 1 and 2 active again. ################
START TRANSACTION; 
UPDATE `sakila`.`customer` SET `active` = '1' WHERE (`customer_id` = '1');
UPDATE `sakila`.`customer` SET `active` = '1' WHERE (`customer_id` = '2');
COMMIT;
################  REVERT COMPLETED! ##############################################################

#################################################################################################
## SCENARIO 7 : AUTOCOMMIT is ON & 
##              NESTED TRANSACTIONS :  
##              OUTER TRANSACTION { make customer 1 inactive  INNER TRANSACTION {make customer 2 inactive} COMMIT;  ROLLBACK;}   
##              Will it COMMIT only customer 2 changes & rollback customer 1 changes due to rollback on outer ? 
## EXPECTED BEHAVIOUR: 
##   1. Only Changes within START TRANSACTION and COMMIT should be persisted to DB and should get erased from RAM after session closure.
##   2. Any uncommitted changes before START TRANSACTION; will get implicitly comitted (https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html )
##   3. Auto-commit turns off inside a Transaction. 
##   4. Nested Transactions are not allowed. (Mysql don't throw a syntax error but we can't rollback the changes of outer transaction as they are implicitly commited.) 
#################################################################################################
-- verify if autocomit is on
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
SELECT * 
FROM sakila.customer;
START TRANSACTION;
-- Task 1:  make a customer with id=1 inactive.
UPDATE sakila.customer c
SET c.active= 0
WHERE c.customer_id = 1;
	START TRANSACTION;
	-- verify if autocomit is off
	SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
	-- Task 2:  make a customer with id=2 inactive.
	UPDATE sakila.customer c
	SET c.active= 0
	WHERE c.customer_id = 2; 
	-- verify the changes.
	SELECT * 
	FROM sakila.customer;
	-- save the changes
	COMMIT;
-- save the changes. 
ROLLBACK;
-- verify the changes.
SELECT * 
FROM sakila.customer;
-- verify auto-commit is on or not. 
SHOW variables LIKE 'autocommit'; -- session specific variable. (COMMIT, ROLLBACK have no affects)
-- close the session. 
-- verify the changes.
SELECT * 
FROM sakila.customer;
####-----------------------NOT WORKING AS expected (Transactions should not be nested)!
############### REVERT THE Changes i.e., make the customers 1 and 2 active again. ################
START TRANSACTION; 
UPDATE `sakila`.`customer` SET `active` = '1' WHERE (`customer_id` = '1');
UPDATE `sakila`.`customer` SET `active` = '1' WHERE (`customer_id` = '2');
COMMIT;
################  REVERT COMPLETED! ##############################################################