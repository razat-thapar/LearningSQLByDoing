#####################################################################################
# Demonstrating Deadlocks in different ISOLATION LEVELS. 
# Pre-requisite : sakila DB 
#####################################################################################

#####################################################################################
# SCENARIO 1 : READ UNCOMMITTED ISOLATION LEVEL> 
# SESSION 1 transaction will perform update on customer id 1. 
# SESSION 2 transaction will perform update on customer id 2. 
# Session 1 transaction will perform update on customer id 2. 
# Session 2 transaction will perform update on customer id 1. 
# Session 1 rollback . 
# Session 2 rollback. 
#####################################################################################
show variables 
like '%isolation%';
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
START TRANSACTION; 
-- update customer id 1 in session 1. 
-- update customer id 2. 
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 2; 
-- update customer id 2 in session 1. 
-- update customer id 1.  
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 1; 
-- This will be blocked as session 1 transaction have acquired a write lock on id 1. 
-- DEADLOCK will occur , transaction in session 1 will be interrupted and stopped. 
ROLLBACK; 

#####################################################################################
# SCENARIO 2 : READ COMMITTED ISOLATION LEVEL> 
# SESSION 1 transaction will perform update on customer id 1. 
# SESSION 2 transaction will perform update on customer id 2. 
# Session 1 transaction will perform update on customer id 2. 
# Session 2 transaction will perform update on customer id 1. 
# Session 1 rollback . 
# Session 2 rollback. 
#####################################################################################
show variables 
like '%isolation%';
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; 
START TRANSACTION; 
-- update customer id 1 in session 1. 
-- update customer id 2. 
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 2; 
-- update customer id 2 in session 1. 
-- update customer id 1.  
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 1; 
-- This will be blocked as session 1 transaction have acquired a write lock on id 1. 
-- DEADLOCK will occur , transaction in session 1 will be interrupted and stopped. 
ROLLBACK; 

#####################################################################################
# SCENARIO 3 : REPEATABLE READ ISOLATION LEVEL> 
# SESSION 1 transaction will perform update on customer id 1. 
# SESSION 2 transaction will perform update on customer id 2. 
# Session 1 transaction will perform update on customer id 2. 
# Session 2 transaction will perform update on customer id 1. 
# Session 1 rollback . 
# Session 2 rollback. 
#####################################################################################
show variables 
like '%isolation%';
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 
START TRANSACTION; 
-- update customer id 1 in session 1. 
-- update customer id 2. 
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 2; 
-- update customer id 2 in session 1. 
-- update customer id 1.  
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 1; 
-- This will be blocked as session 1 transaction have acquired a write lock on id 1. 
-- DEADLOCK will occur , transaction in session 1 will be interrupted and stopped. 
ROLLBACK; 


#####################################################################################
# SCENARIO 4 : SERIALIZABLE ISOLATION LEVEL> 
# SESSION 1 transaction will perform update on customer id 1. 
# SESSION 2 transaction will perform update on customer id 2. 
# Session 1 transaction will perform update on customer id 2. 
# Session 2 transaction will perform update on customer id 1. 
# Session 1 rollback . 
# Session 2 rollback. 
#####################################################################################
show variables 
like '%isolation%';
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; 
START TRANSACTION; 
-- update customer id 1 in session 1. 
-- update customer id 2. 
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 2; 
-- update customer id 2 in session 1. 
-- update customer id 1.  
UPDATE sakila.customer c 
SET c.active = 0 
WHERE c.customer_id = 1; 
-- This will be blocked as session 1 transaction have acquired a write lock on id 1. 
-- DEADLOCK will occur , transaction in session 1 will be interrupted and stopped. 
ROLLBACK; 

#####################################################################################
# CONCLUSION : DEADLOCK occured in all 4 Isolation levels while MYSQL DB engine was 
# able to detect and fix it instantly. 
#####################################################################################