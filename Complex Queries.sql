## 	Chapter:- SQL Basics: Complex Queries




### Module: Subqueries

-- Select a movie with highest imdb_rating
	-- without subquery
	select * from movies order by imdb_rating desc limit 1;
	
	-- with subquery
	select * from movies where imdb_rating=(select max(imdb_rating) from movies);

-- Select a movie with highest and lowest imdb_rating
	-- without subquery
	select * from movies where imdb_rating in (1.9, 9.3);

	-- with subquery
	select * from movies where imdb_rating in (
        				(select min(imdb_rating) from movies), 
    					(select max(imdb_rating) from movies)
						);

-- Select all the actors whose age is greater than 70 and less than 85
	select 
	    actor_name, age
	FROM 
  	    (Select
                name as actor_name,
                (year(curdate()) - birth_year) as age
    	     From actors
            ) AS actors_age_table
	WHERE age > 70 AND age < 85;

-- Exercise
-- 1) select all the movies with minimum and maximum release_year. Note that there can be more than one movies in min and max year hence output rows can be more than 2

	select * from movies where release_year in (
        (select min(release_year) from movies),
		(select max(release_year) from movies)
	);
	
-- 2) select all the rows from movies table whose imdb_rating is higher than the average rating

	select * from movies 
	where imdb_rating >  
        (select avg(imdb_rating) from movies);
	


### Module: ANY, ALL Operators

-- select actors who acted in any of these movies (101,110, 121)
	select * From actors WHERE actor_id = ANY(select actor_id From movie_actor where movie_id IN (101, 110, 121));

-- select all movies whose rating is greater than *any* of the marvel movies rating
	select * from movies where imdb_rating > ANY(select imdb_rating from movies where studio="Marvel studios");

-- Above, can be achieved in another way too (sub query, min)
	select * from movies where imdb_rating > (select min(imdb_rating) from movies where studio="Marvel studios");

-- select all movies whose rating is greater than *all* of the marvel movies rating
	select * from movies where imdb_rating > ALL(select imdb_rating from movies where studio="Marvel studios");

-- Above, can be achieved in another way too (sub query, max)
	select * from movies where imdb_rating > (select max(imdb_rating) from movies where studio="Marvel studios");





### Module: Co-Related Subquery

-- Get the actor id, actor name and the total number of movies they acted in.
	SELECT 
           actor_id, 
           name, 
	   (SELECT COUNT(*) FROM movie_actor WHERE actor_id = actors.actor_id) as movies_count
	FROM actors
	ORDER BY movies_count DESC;

-- Above, can be achieved by using Joins too!
	select 
	    a.actor_id, 
	    a.name, 
	    count(*) as movie_count
	from movie_actor ma
	join actors a
	on a.actor_id=ma.actor_id
	group by actor_id
	order by movie_count desc;




### Module: Common Table Expression (CTE)

-- Select all the actors whose age is greater than 70 and less than 85 [Previously, we have used sub-queries to solve this. Now we use CTE's]
	with actors_age as 
	   (select
                name as actor_name,
                year(curdate()) - birth_year as age
            from actors
	    )
	select actor_name, age from actors_age where age > 70 and age < 85;


-- Movies that produced 500% profit and their rating was less than average rating for all movies
	with 
	   x as 
	      (select 
		   *, 
                   (revenue-budget)*100/budget as pct_profit
               from financials),
    	   y as 
	      (select * from movies where imdb_rating < (select avg(imdb_rating) from movies))
	select 
	    x.movie_id, y.title, x.pct_profit, y.imdb_rating
	from x
	join y
	on x.movie_id=y.movie_id
	where x.pct_profit > 500;


-- Above, can be achieved using sub-query too (But, code readability is less here compared to CTE's)
	select 
	   x.movie_id, y.title, x.pct_profit, y.imdb_rating
	from ( 
              select
                  *, 
                  (revenue-budget)*100/budget as pct_profit
              from financials
	     ) x
	join 
	     (select * from movies where imdb_rating < (select avg(imdb_rating) from movies)) y
	on x.movie_id=y.movie_id
	where pct_profit>500;
    
    -- Exercise
    
    -- 1) select all hollowood movies released after year 2000 that made more than 500 millions $ profit or more profit. 
    -- Note that all hollywood movies have millions as a unit hence you don't
	-- need to do unit converstion. Also you can write this query without CTE as well but you should try to write this using CTE only

	with cte as (select title, release_year, (revenue-budget) as profit
			from movies m
			join financials f
			on m.movie_id=f.movie_id
			where release_year>2000 and industry="hollywood"
	)
	select * from cte where profit>500;