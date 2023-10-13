####################################################################################
##  INDEXING IN MYSQL 
##  Prerequisites: Install Sakila db. 
####################################################################################

#---------------------------------------------------------
# Analyze the performance of query using EXPLAIN ANALYZE 
#---------------------------------------------------------

#---------------------------------------------------------
# DELETING THE INDEX on a particular table. 
#---------------------------------------------------------
DROP INDEX idx_title 
ON sakila.film;
Commit; 

#Scenario 1: POST deletion of index on film.title 
EXPLAIN ANALYZE
Select * 
From sakila.film f 
WHERE f.title='african egg';
# RESULT :
#'-> Filter: (sakila.f.title = \'african egg\')  
#(cost=103.00 rows=100) 
#(actual time=0.069..3.060 rows=1 loops=1)\n    
#-> Table scan on f  (cost=103.00 rows=1000) 
#(actual time=0.047..2.743 rows=1000 loops=1)\n'

#---------------------------------------------
# CREATE AN INDEX ON film.title column . 
#---------------------------------------------
CREATE INDEX idx_film_title
ON sakila.film(title);
COMMIT;

#Scenario 2:  index on film.title column already exists. 
EXPLAIN ANALYZE
Select * 
From sakila.film f 
WHERE f.title='african egg';
# RESULT
-- '-> Index lookup on f using idx_film_title (title=\'african egg\')  
-- (cost=0.35 rows=1) 
-- (actual time=0.056..0.062 rows=1 loops=1)\n'

#---------------------------------------------
# CREATE FULLTEXT INDEX ON film.title column  
#---------------------------------------------
CREATE FULLTEXT INDEX idx_fulltext_film_title
ON sakila.film(title);
COMMIT; 
# scenario 1: Searching pattern in title using full text index. 
EXPLAIN ANALYZE
SELECT * 
FROM sakila.film f 
WHERE MATCH(f.title) AGAINST ('WAR');
-- '-> Filter: (match sakila.f.title against (\'WAR\'))  
-- (cost=1.03 rows=1) (actual time=0.061..0.092 rows=3 loops=1)\n    
-- -> Full-text index search on f using idx_fulltext_film_title (title=\'WAR\')  
-- (cost=1.03 rows=1) (actual time=0.041..0.070 rows=3 loops=1)\n'

#Scenario 2: Normal Searching 'WAR' in title column.  
EXPLAIN ANALYZE
SELECT * 
FROM sakila.film f 
WHERE f.title LIKE '%WAR%';
-- '-> Filter: (sakila.f.title like \'%WAR%\')  
-- (cost=111.18 rows=111) (actual time=0.231..4.033 rows=19 loops=1)\n    
-- -> Table scan on f  
-- (cost=111.18 rows=1000) (actual time=0.043..3.345 rows=1000 loops=1)\n'

#scenario 3: Full text Searching 'WAR' in description column. (using full text search way)
EXPLAIN ANALYZE
SELECT * 
FROM sakila.film f 
WHERE MATCH(f.description) AGAINST ('WAR');
-- Error Code: 1191. Can't find FULLTEXT index matching the column list

#Scenario 4: Normal Searching 'WAR' in description column (using LIKE) 
EXPLAIN ANALYZE
SELECT * 
FROM sakila.film f 
WHERE f.description LIKE '%WAR%';
-- '-> Filter: (sakila.f.`description` like \'%WAR%\')  
-- (cost=111.18 rows=111) (actual time=4.818..4.818 rows=0 loops=1)\n    
-- -> Table scan on f  
-- (cost=111.18 rows=1000) (actual time=0.051..3.080 rows=1000 loops=1)\n'
