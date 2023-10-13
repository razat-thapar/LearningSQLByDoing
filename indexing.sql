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
