#---------------------------------------------------------------
# Demonstrating DIFFERENT TYPES OF SUBQUERIES
# Pre-requisites : 
# Download sakila, classicmodels databases. 
#---------------------------------------------------------------

################################################################
### SINGLE VALUE SUBQUERY. 
###############################################################
##-------------------------------------------------------------
#SCENARIO 1: Subquery in WHERE clause. 
##-------------------------------------------------------------
-- find all the longest duration films.
SELECT * 
FROM sakila.film f
WHERE f.length = 
(
	SELECT f2.length
    FROM sakila.film f2
    ORDER BY f2.length DESC
    LIMIT 1
);
##-------------------------------------------------------------
#SCENARIO 2: Subquery in FROM clause. 
##-------------------------------------------------------------
-- give me the largest order (in terms of amount) from classicmodels.orders
SELECT CONCAT('$',X.maxtotal) AS 'largestOrder'
FROM
(
	SELECT MAX(p.quantityOrdered*p.priceEach) as Maxtotal
    FROM classicmodels.orderdetails p
) AS X;
##-------------------------------------------------------------
#SCENARIO 3: Subquery in SELECT clause. 
##-------------------------------------------------------------
-- give me the details of cheapest motorcycles. 
SELECT 'cheapest Bike',
(
SELECT MIN(p.MSRP)
FROM classicmodels.products p
WHERE p.productLine='Motorcycles' 
) AS Price;

################################################################
### MULTIPLE VALUE SUBQUERY. 
###############################################################
##-------------------------------------------------------------
#SCENARIO 1: Subquery in WHERE clause. 
##-------------------------------------------------------------
-- IN operator
	-- give me all films ids whose cast have lastnames as "NEESON"
		-- 1. SELECT those actors whose lastnames is NEESON. 
		-- 2. SELECT Those film id's whose actors IN result set of 1. 	
		SELECT fa.film_id
		FROM sakila.film_actor fa
		WHERE fa.actor_id IN 
		(
			SELECT a.actor_id
			FROM sakila.actor a 
			WHERE a.last_name ='NEESON'
		);
-- ALL operator
	-- give me all films 
-- Exists operator

##-------------------------------------------------------------
#SCENARIO 2: Subquery in FROM clause. 
##-------------------------------------------------------------
-- print customer full name and max rental payment amount for each customer
SELECT c.customer_id,c.first_name,c.last_name,X.maxamt
FROM 
(
	SELECT p.customer_id, MAX(p.amount) as maxamt
    FROM sakila.payment p 
    GROUP BY p.customer_id
) AS X
RIGHT OUTER JOIN sakila.Customer c ON c.customer_id = X.customer_id
;
##-------------------------------------------------------------
#SCENARIO 3: Subquery in SELECT clause. 
##-------------------------------------------------------------
################################################################
### CORRELATED SUBQUERY. 
###############################################################
##-------------------------------------------------------------
#SCENARIO 1: Subquery in WHERE clause. 
##-------------------------------------------------------------
-- give me the costliest product name based on MSRP in each product line. 

-- 1. get the costliest product MSRP for a given product line. 
-- 2. get all the products which is having MSRP in result set 1. 
SELECT p.productLine,p.productName AS 'costliest product',p.MSRP
FROM classicmodels.products p 
WHERE p.MSRP IN 
(
	SELECT MAX(p2.MSRP)
    FROM classicmodels.products p2 
    WHERE p2.productLine=p.productLine
);

##-------------------------------------------------------------
#SCENARIO 2: Subquery in FROM clause. 
##-------------------------------------------------------------

##-------------------------------------------------------------
#SCENARIO 3: Subquery in SELECT clause. 
##-------------------------------------------------------------
-- give me the costliest product name based on MSRP in each product line. 
-- explain analyze
SELECT pl.productLine , 
(
	SELECT p.productName
    FROM classicmodels.products p 
    WHERE p.productLine = pl.productLine
    ORDER BY p.MSRP DESC 
    LIMIT 1
) AS 'costliest product'
FROM classicmodels.productLines pl 
;