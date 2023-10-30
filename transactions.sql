#---------------------------------------------------------------
# Demonstrating Transactions
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------
################################################################
# To get all the MYSQL variables to check default values. 
################################################################
show variables
Like '%commit%'; 
-- to trun off autocommit. 
SET autocommit='OFF';
commit; -- persist on disk. 

################################################################
# Transaction.
################################################################
################################################################
# ACHIEVING ATOMICITY using START TRANSACTION  {some statements} ROLLBACK/COMMIT 
################################################################
-- to begin the transaction and do implicit commit on any uncommited changes before it. 
-- It also makes the autocommit turn off.  
START transaction; 
COMMIT; -- to end the transaction by committing all the changes. 
ROLLBACK; -- to end the transaction by undoing the changes in the transaction. 
-- NOTE: Read the atomicity_using_transaction_demo.sql script to understand different scenarios. 
################################################################
# ACHIEVING ISOLATION  
################################################################
-- READ UNCOMMITED
#1. Allows a transaction to read even uncommitted data from other transactions at the same time. 
#2. Reads the latest data -(committed data from database if not present in RAM or  uncomitted data from RAM if present)
#3. It is giving us fastest read/write operations time. Since, we are reading the latest data(most of the time from RAM). 
#4. CONS: Inconsistency in results (DIRTY READ)
#USE CASE : updating the count of users in live hotstar match. 

-- READ COMMITTED 
