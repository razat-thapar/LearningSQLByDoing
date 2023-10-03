-- to demonstrate working of foreign key with default behaviour. 
-- default
-- cascade
-- set null
-- RESTRICT/NO ACTION (default behavior)
-- set default
drop database if exists myworld;
Create Database myworld;
#--------------------------------------------------------- 
# demonstrating default behaviour of Foreign key. 
#---------------------------------------------------------
use myworld;
drop table if exists myworld.student;
drop table if exists myworld.batch;
create table myworld.batch(
	bid INT auto_increment,
    name varchar(50) NOT NULL, 
    start_dt timestamp default current_timestamp,
    primary key(bid)
);
create table myworld.student(
	id INT auto_increment,
    name VARCHAR(30) NOT NULL,
    email varchar(100) UNIQUE NOT NULL,
    bid INT,
    primary key(id),
    foreign key(bid) references batch(bid)
);
show tables;
desc myworld.student;
desc myworld.batch;
insert into myworld.batch(name) values('begineer');
insert into myworld.batch(name) values('intermediate');
insert into myworld.batch(name) values('advanced');
select * from batch;
INSERT into myworld.student(name,email,bid) values('Razat','abc@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Razat','xyz@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Aggarwal','agg@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Rohan','rohan@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Graph','graph@gmail.com',3);
select * from student;
#--------------------------------------------------------
# TESTING different possibilities i.e.,CRUD during default behaviour.
#--------------------------------------------------------
# Scenario 1: Inserting a new record in reference table.i.e., batch
insert into myworld.batch(name) values('ninja');
-- works fine! 
# Scenario 2: Inserting a new record in student table without any batch id.  
INSERT into myworld.student(name,email,bid) values('John','John@gmail.com',null);
-- works fine! 
# Scenario 3: Inserting a new record in student table with unknown batch id. 
INSERT into myworld.student(name,email,bid) values('John2','John2@gmail.com',5);
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 4: Updating bid of an existing record in reference table i.e., batch. 
UPDATE myworld.batch
SET bid= 5
WHERE bid = 1; 
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 5: Updating bid to unknown value of an existing record in student table. 
UPDATE myworld.student
SET bid='5'
WHERE id='6';
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 6: Updating bid to known value of an exisiting record in student table. 
UPDATE myworld.student
SET bid='1'
WHERE id='6';
-- works fine!
# Scenario 7: Updating batchname of an existing record in reference table i.e., batch.
UPDATE myworld.batch
SET name= 'BEGINEER'
WHERE bid = 1; 
-- works fine! 
# Scenario 8: Deleting a record in reference table i.e., batch. STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=1;
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 9: Deleting a record in reference table i.e., batch. NO STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=4;
-- works fine!
# Scenario 10: Deleting a record in child table i.e., student. bid MAPPED
DELETE FROM myworld.student 
WHERE id=5;
-- works fine!
# Scenario 11: Deleting a record in child table i.e., student. NO bid MAPPED
DELETE FROM myworld.student 
WHERE id=6;
-- works fine!

#--------------------------------------------------------- 
# demonstrating CASCADE behaviour of Foreign key. 
#---------------------------------------------------------
use myworld;
drop table if exists myworld.student;
drop table if exists myworld.batch;
create table myworld.batch(
	bid INT auto_increment,
    name varchar(50) NOT NULL, 
    start_dt timestamp default current_timestamp,
    primary key(bid)
);
create table myworld.student(
	id INT auto_increment,
    name VARCHAR(30) NOT NULL,
    email varchar(100) UNIQUE NOT NULL,
    bid INT,
    primary key(id),
    foreign key(bid) references batch(bid) ON DELETE CASCADE ON UPDATE CASCADE
);
show tables;
desc myworld.student;
desc myworld.batch;
insert into myworld.batch(name) values('begineer');
insert into myworld.batch(name) values('intermediate');
insert into myworld.batch(name) values('advanced');
select * from batch;
INSERT into myworld.student(name,email,bid) values('Razat','abc@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Razat','xyz@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Aggarwal','agg@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Rohan','rohan@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Graph','graph@gmail.com',3);
select * from student;
#--------------------------------------------------------
# TESTING different possibilities i.e.,CRUD during default behaviour.
#--------------------------------------------------------
# Scenario 1: Inserting a new record in reference table.i.e., batch
insert into myworld.batch(name) values('ninja');
-- works fine! 
# Scenario 2: Inserting a new record in student table without any batch id.  
INSERT into myworld.student(name,email,bid) values('John','John@gmail.com',null);
-- works fine! 
# Scenario 3: Inserting a new record in student table with unknown batch id. 
INSERT into myworld.student(name,email,bid) values('John2','John2@gmail.com',5);
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 4: Updating bid of an existing record in reference table i.e., batch. 
UPDATE myworld.batch
SET bid= 5
WHERE bid = 1; 
-- works fine! It updates the student records with bid 1 to 5. 
# Scenario 5: Updating bid to unknown value of an existing record in student table. 
UPDATE myworld.student
SET bid='5'
WHERE id='6';
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 6: Updating bid to known value of an exisiting record in student table. 
UPDATE myworld.student
SET bid='1'
WHERE id='6';
-- works fine!
# Scenario 7: Updating batchname of an existing record in reference table i.e., batch.
UPDATE myworld.batch
SET name= 'BEGINEER'
WHERE bid = 1; 
-- works fine! 
# Scenario 8: Deleting a record in reference table i.e., batch. STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=1;
-- works fine! it deletes the students mapped to bid=1 . 
# Scenario 9: Deleting a record in reference table i.e., batch. NO STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=4;
-- works fine!
# Scenario 10: Deleting a record in child table i.e., student. bid MAPPED
DELETE FROM myworld.student 
WHERE id=5;
-- works fine!
# Scenario 11: Deleting a record in child table i.e., student. NO bid MAPPED
DELETE FROM myworld.student 
WHERE id=6;
-- works fine!

#--------------------------------------------------------- 
# demonstrating SET NULL behaviour of Foreign key. 
#---------------------------------------------------------
use myworld;
drop table if exists myworld.student;
drop table if exists myworld.batch;
create table myworld.batch(
	bid INT auto_increment,
    name varchar(50) NOT NULL, 
    start_dt timestamp default current_timestamp,
    primary key(bid)
);
create table myworld.student(
	id INT auto_increment,
    name VARCHAR(30) NOT NULL,
    email varchar(100) UNIQUE NOT NULL,
    bid INT,
    primary key(id),
    foreign key(bid) references batch(bid) ON UPDATE SET NULL ON DELETE SET NULL
);
show tables;
desc myworld.student;
desc myworld.batch;
insert into myworld.batch(name) values('begineer');
insert into myworld.batch(name) values('intermediate');
insert into myworld.batch(name) values('advanced');
select * from batch;
INSERT into myworld.student(name,email,bid) values('Razat','abc@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Razat','xyz@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Aggarwal','agg@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Rohan','rohan@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Graph','graph@gmail.com',3);
select * from student;
#--------------------------------------------------------
# TESTING different possibilities i.e.,CRUD during default behaviour.
#--------------------------------------------------------
# Scenario 1: Inserting a new record in reference table.i.e., batch
insert into myworld.batch(name) values('ninja');
-- works fine! 
# Scenario 2: Inserting a new record in student table without any batch id.  
INSERT into myworld.student(name,email,bid) values('John','John@gmail.com',null);
-- works fine! 
# Scenario 3: Inserting a new record in student table with unknown batch id. 
INSERT into myworld.student(name,email,bid) values('John2','John2@gmail.com',5);
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 4: Updating bid of an existing record in reference table i.e., batch. 
UPDATE myworld.batch
SET bid= 5
WHERE bid = 1; 
-- works fine! the student mapped to bid 1 have bid set to Null. 
# Scenario 5: Updating bid to unknown value of an existing record in student table. 
UPDATE myworld.student
SET bid='5'
WHERE id='6';
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 6: Updating bid to known value of an exisiting record in student table. 
UPDATE myworld.student
SET bid='1'
WHERE id='6';
-- works fine!
# Scenario 7: Updating batchname of an existing record in reference table i.e., batch.
UPDATE myworld.batch
SET name= 'BEGINEER'
WHERE bid = 1; 
-- works fine! 
# Scenario 8: Deleting a record in reference table i.e., batch. STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=1;
-- works fine! The students mapped to bid 1 have their bid set to null. 
# Scenario 9: Deleting a record in reference table i.e., batch. NO STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=4;
-- works fine!
# Scenario 10: Deleting a record in child table i.e., student. bid MAPPED
DELETE FROM myworld.student 
WHERE id=5;
-- works fine!
# Scenario 11: Deleting a record in child table i.e., student. NO bid MAPPED
DELETE FROM myworld.student 
WHERE id=6;
-- works fine!


#--------------------------------------------------------- 
# demonstrating RESTRICT behaviour of Foreign key. 
#---------------------------------------------------------
use myworld;
drop table if exists myworld.student;
drop table if exists myworld.batch;
create table myworld.batch(
	bid INT auto_increment,
    name varchar(50) NOT NULL, 
    start_dt timestamp default current_timestamp,
    primary key(bid)
);
create table myworld.student(
	id INT auto_increment,
    name VARCHAR(30) NOT NULL,
    email varchar(100) UNIQUE NOT NULL,
    bid INT,
    primary key(id),
    foreign key(bid) references batch(bid) ON UPDATE RESTRICT ON DELETE RESTRICT
);
show tables;
desc myworld.student;
desc myworld.batch;
insert into myworld.batch(name) values('begineer');
insert into myworld.batch(name) values('intermediate');
insert into myworld.batch(name) values('advanced');
select * from batch;
INSERT into myworld.student(name,email,bid) values('Razat','abc@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Razat','xyz@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Aggarwal','agg@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Rohan','rohan@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Graph','graph@gmail.com',3);
select * from student;
#--------------------------------------------------------
# TESTING different possibilities i.e.,CRUD during default behaviour.
#--------------------------------------------------------
# Scenario 1: Inserting a new record in reference table.i.e., batch
insert into myworld.batch(name) values('ninja');
-- works fine! 
# Scenario 2: Inserting a new record in student table without any batch id.  
INSERT into myworld.student(name,email,bid) values('John','John@gmail.com',null);
-- works fine! 
# Scenario 3: Inserting a new record in student table with unknown batch id. 
INSERT into myworld.student(name,email,bid) values('John2','John2@gmail.com',5);
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 4: Updating bid of an existing record in reference table i.e., batch. 
UPDATE myworld.batch
SET bid= 5
WHERE bid = 1; 
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 5: Updating bid to unknown value of an existing record in student table. 
UPDATE myworld.student
SET bid='5'
WHERE id='6';
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 6: Updating bid to known value of an exisiting record in student table. 
UPDATE myworld.student
SET bid='1'
WHERE id='6';
-- works fine!
# Scenario 7: Updating batchname of an existing record in reference table i.e., batch.
UPDATE myworld.batch
SET name= 'BEGINEER'
WHERE bid = 1; 
-- works fine! 
# Scenario 8: Deleting a record in reference table i.e., batch. STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=1;
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 9: Deleting a record in reference table i.e., batch. NO STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=4;
-- works fine!
# Scenario 10: Deleting a record in child table i.e., student. bid MAPPED
DELETE FROM myworld.student 
WHERE id=5;
-- works fine!
# Scenario 11: Deleting a record in child table i.e., student. NO bid MAPPED
DELETE FROM myworld.student 
WHERE id=6;
-- works fine!

#--------------------------------------------------------- 
# demonstrating  SET DEFAULT referential constraint of Foreign key. 
# NOTE: MYSQL don't allow this constraint anymore!
#---------------------------------------------------------
use myworld;
drop table if exists myworld.student;
drop table if exists myworld.batch;
create table myworld.batch(
	bid INT auto_increment,
    name varchar(50) NOT NULL, 
    start_dt timestamp default current_timestamp,
    primary key(bid)
);
create table myworld.student(
	id INT auto_increment,
    name VARCHAR(30) NOT NULL,
    email varchar(100) UNIQUE NOT NULL,
    bid INT DEFAULT 1 NOT NULL,
    primary key(id),
    foreign key(bid) references batch(bid)
);
show tables;
desc myworld.student;
desc myworld.batch;
insert into myworld.batch(name) values('begineer');
insert into myworld.batch(name) values('intermediate');
insert into myworld.batch(name) values('advanced');
select * from batch;
INSERT into myworld.student(name,email,bid) values('Razat','abc@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Razat','xyz@gmail.com',1);
INSERT into myworld.student(name,email,bid) values('Aggarwal','agg@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Rohan','rohan@gmail.com',2);
INSERT into myworld.student(name,email,bid) values('Graph','graph@gmail.com',3);
select * from student;
#--------------------------------------------------------
# TESTING different possibilities i.e.,CRUD during default behaviour.
#--------------------------------------------------------
# Scenario 1: Inserting a new record in reference table.i.e., batch
insert into myworld.batch(name) values('ninja');
-- works fine! 
# Scenario 2: Inserting a new record in student table without any batch id.  
INSERT into myworld.student(name,email) values('John','John@gmail.com');
-- works fine!  It sets the default value i.e., 1. 
# Scenario 3: Inserting a new record in student table with unknown batch id. 
INSERT into myworld.student(name,email,bid) values('John2','John2@gmail.com',5);
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 4: Updating bid of an existing record in reference table i.e., batch. 
UPDATE myworld.batch
SET bid= 5
WHERE bid = 1; 
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 5: Updating bid to unknown value of an existing record in student table. 
UPDATE myworld.student
SET bid='5'
WHERE id='6';
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 6: Updating bid to known value of an exisiting record in student table. 
UPDATE myworld.student
SET bid='1'
WHERE id='6';
-- works fine!
# Scenario 7: Updating batchname of an existing record in reference table i.e., batch.
UPDATE myworld.batch
SET name= 'BEGINEER'
WHERE bid = 1; 
-- works fine! 
# Scenario 8: Deleting a record in reference table i.e., batch. STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=1;
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`myworld`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `batch` (`bid`))
# Scenario 9: Deleting a record in reference table i.e., batch. NO STUDENTS MAPPED
DELETE FROM myworld.batch 
WHERE bid=4;
-- works fine!
# Scenario 10: Deleting a record in child table i.e., student. bid MAPPED
DELETE FROM myworld.student 
WHERE id=5;
-- works fine!
# Scenario 11: Deleting a record in child table i.e., student. NO bid MAPPED
DELETE FROM myworld.student 
WHERE id=6;
-- works fine!