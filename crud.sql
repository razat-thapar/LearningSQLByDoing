# PRE-REQUISITES
-- Table Batch( bid,name,start_dt) should exist in myworld database. 
-- bid int AI PK 
-- name varchar(50) 
-- start_dt timestamp

#-----------------------------------------------------------------------
#  DEMONSTRATING CREATE(INSERT) OPERATION
#-----------------------------------------------------------------------

# Creating a new table 
use myworld;
DROP TABLE IF EXISTS myworld.scaler_student;
CREATE TABLE myworld.scaler_student (
    id INT AUTO_INCREMENT,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    dateOfBirth DATE NOT NULL,
    enrollmentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    psp DECIMAL(5, 2) CHECK (psp BETWEEN 0.00 AND 100.00),
    batchId INT,
    isActive BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id),
    FOREIGN KEY(batchId) REFERENCES batch(bid) ON UPDATE SET NULL ON DELETE SET NULL
);
DESC myworld.scaler_student;
COMMIT; 

# Creating/inserting a new row/record into existing table. 
# NOTE: Good practice to mention columns while insert records as some columns might have default values, autogenerated values.

-- Scenario 1: Putting date in wrong format(default is yyyy-mm-dd)
INSERT INTO scaler_student (firstName, LastName, email, dateOfBirth, psp, batchId) 
VALUES ('Razat','Aggarwal','razat.javaprogrammer@gmail.com','09-11-1996',97.4,2);
-- Error Code: 1292. Incorrect date value: '09-11-1996' for column 'dateOfBirth' at row 1

INSERT INTO scaler_student (firstName, LastName, email, dateOfBirth, psp, batchId) 
VALUES ('Razat','Aggarwal','razat.javaprogrammer@gmail.com','1996-11-09',97.40,2);

#------------------------- IMPORTANT QUERY -----
# DEEP COPY table1 to table1_copy
-- creating a new copy table. 
DROP TABLE IF EXISTS myworld.scaler_student_copy;
CREATE TABLE myworld.scaler_student_copy (
    id INT AUTO_INCREMENT,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    dateOfBirth DATE NOT NULL,
    enrollmentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    psp DECIMAL(5, 2) CHECK (psp BETWEEN 0.00 AND 100.00),
    batchId INT,
    isActive BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id),
    FOREIGN KEY(batchId) REFERENCES batch(bid) ON UPDATE SET NULL ON DELETE SET NULL
);
-- performing deep copy
INSERT INTO myworld.scaler_student_copy(`id`, `firstName`, `lastName`, `email`, `dateOfBirth`,`enrollmentDate`, `psp`, `batchId`, `isActive`)
SELECT `id`, `firstName`, `lastName`, `email`, `dateOfBirth`,`enrollmentDate`, `psp`, `batchId`, `isActive` 
FROM myworld.scaler_student;

#-----------------------------------------------------------------------
#  DEMONSTRATING READ(PRINT/SELECT) OPERATION
#-----------------------------------------------------------------------
use sakila;

# Scenario 0: printing data. 
SELECT 'Hello, World!' AS 'columnName';
SELECT 4*3 ; 

# Scenario 1: print all columns from film table. 
#----------------- USE OF * KEYWORD
SELECT *          -- select all columns. 
FROM sakila.film; -- select all rows.

# Scenario 2: Use of Aliases 
# ---------------  AS keyword  is optional. 
SELECT f.*
FROM sakila.film AS f;

SELECT f.*
FROM sakila.film f;

# Scenario 3: Use of back Tick operator `
--  to reuse reserve keywords in mysql as database,table,column names  
SELECT `TABLE`.*
FROM sakila.film `TABLE`;

# Scenario 4: print only title,rating,release_year for all records from film table. 
SELECT f.title,f.rating,f.release_year 
FROM sakila.film f;

# Scenario 5: Print distinct(rating,release_year) records from film table. 
#----------------- USE OF DISTINCT KEYWORD
SELECT DISTINCT f.rating, f.release_year 
FROM sakila.film f;

-- Scenario 6: print rating , distinct(release_year) records from film table. 
SELECT f.rating
-- , DISTINCT f.release_year 
FROM sakila.film f;
-- Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'DISTINCT f.release_year  FROM sakila.film f' at line 1
-- Why it didn't work ? Ambiguous for SQL as different column lengths. 5 types of ratings but only 1 year 2006. 

# Scenario 7: OPERATIONS ON COLUMN ( Treating column as variables) 
SELECT title, ROUND(length/60) AS 'duration(hrs)' 
FROM sakila.film;

# Scenario 8: Filtering records using WHERE CLAUSE 
-- Following operators are used in WHERE CLAUSE to filter records. 
##########################################################################
-- AND (&&), OR (||), NOT (!)
##########################################################################
SELECT * 
FROM sakila.film f
-- WHERE f.length>120 AND f.rating='PG-13';--prints records where both of them are true.
-- WHERE f.length>120 OR f.rating='PG-13'; --prints records where either of them are true.
WHERE NOT f.rating='PG-13'; -- prints only records where rating='PG-13' is false
##########################################################################
-- IN 
##########################################################################
-- Passing multiple values to match. 
SELECT *
FROM sakila.film f 
WHERE f.rating IN('PG','G','NC-17');  
-- We can pass IN operator a subquery as well. 
SELECT * 
FROM sakila.film f 
WHERE f.rating IN( SELECT DISTINCT rating FROM sakila.film WHERE rating LIKE 'P%');
##########################################################################
-- BETWEEN
##########################################################################
SELECT * 
FROM sakila.film f 
-- WHERE f.rating between 'PG' AND 'R'; -- lexicographical range between [PG,R]
WHERE f.rental_duration BETWEEN 5 and 8; 
-- date comparison. 
SELECT * 
FROM sakila.payment 
WHERE payment_date > '2005-07-30' AND payment_date < '2005-08-01 14:14:11';
##########################################################################
-- >,<,>=,<=,<>,!=
##########################################################################
SELECT * 
FROM sakila.film f 
WHERE f.rating >='PG' AND f.rating <='R'; -- lexicographical range between [PG,R]
##########################################################################
-- LIKE 
##########################################################################
SELECT *
FROM sakila.film f
-- WHERE title LIKE '%D'; -- film names ending with D. 
-- WHERE title LIKE 'D%'; -- film names starting with D. 
-- WHERE title LIKE '%O_O%'; -- film names having any char between two 'o'. 
WHERE title NOT LIKE 'G%'; -- film names not starting with G. 
############################### NOTE 1: ################################
-- enforcing case sensitivity in LIKE operator USING LIKE BINARY
SELECT * 
FROM sakila.film 
-- WHERE description LIKE BINARY '%of a P%'; -- gives me records containing case sensitive 'of a P' 
WHERE description LIKE BINARY '%OF A P%';
############################### NOTE 2: ################################
-- matching wildcard characters inside LIKE operator using escape character. 
SELECT * 
FROM sakila.film
-- WHERE title LIKE '%\_%'; -- matches title containing underscore. 
WHERE title LIKE '%\%%'; -- matches title containing percentage.
##########################################################################
-- IS NULL , IS NOT NULL
##########################################################################
-- Checking for empty data in a column. 
SELECT * 
FROM sakila.address a 
WHERE a.address2 IS NULL OR a.address2 ='';

-- printing 0 instead of null values for column  address 2
-- NOTE: it won't check empty character i.e., '' .  
SELECT a.address_id,a.address,IFNULL(a.address2,0)
FROM sakila.address a;
-- printing 1 if null value else 0 if not null for column address2 
SELECT a.address_id, a.address, ISNULL(a.address2)
FROM sakila.address a; 

# Scenario 9: custom sort the records while printing. (ORDER BY CLAUSE)
-- CUSTOM SORT films using 
-- first based on release yr descending
-- second based on rating descending 
-- third based on title ascending
SELECT f.title,f.release_year,f.rating   
FROM sakila.film f 
ORDER BY f.release_year DESC, f.rating DESC,f.title ASC ;

# Scenario 10: printing only few records (first 10) (LIMIT x OFFSET y) 
-- print only first 10 rows
SELECT * 
FROM sakila.film f 
LIMIT 10; 
-- print 10 rows starting 11th row. 
-- LIMIT x OFFSET y  means return so, [y+1,x+y]
SELECT *
FROM sakila.film f 
LIMIT 5 OFFSET 19;  -- [20,24]

#-----------------------------------------------------------------------
#  DEMONSTRATING UPDATE OPERATION
#-----------------------------------------------------------------------
-- to update all film release_year to current year where title contains LOVE. 
UPDATE sakila.film f 
SET f.release_year = year(current_date())
WHERE f.title LIKE '%LOVE%';
-- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
-- toggle off the safe update mode. 
SET SQL_SAFE_UPDATES=0;
COMMIT; 
-- verify the result and then commit. 
SELECT * 
FROM sakila.film f 
WHERE f.title LIKE '%LOVE%';
-- works ! 
COMMIT; 


#-----------------------------------------------------------------------
#  DEMONSTRATING DELETE OPERATION
#-----------------------------------------------------------------------
-- delete all records of student having last id. 
DELETE FROM myworld.scaler_student_copy
WHERE id =1;
ROLLBACK;
-- truncate scaler student copy
TRUNCATE scaler_student_copy;
ROLLBACK;
-- NOTE : Here, even rollback won't give you back the data lost. 
DROP TABLE scaler_student_copy;
ROLLBACK; 
-- NOTE: Here, even rollback won't give you back the table deleted. 
