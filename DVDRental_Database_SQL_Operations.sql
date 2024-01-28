------------------ DVDRental Database SQL Operations -------------------

/*
SQL Operations:
Write SQL queries to perform the following operations:

1) Select distinct values for key columns in each table.
2) Join relevant tables to create a consolidated view.
3) Calculate summary statistics for important columns.
4) Filter and sort data based on specific conditions.
*/

/*
1) Select distinct values for key columns in each table.
*/ 

-- 1. actor table
SELECT DISTINCT actor_id, first_name, last_name FROM actor;

-- 2. address table
SELECT DISTINCT address_id, address, district, city_id FROM address;

-- 3. category table
SELECT DISTINCT category_id, name FROM category;

-- 4. city table
SELECT DISTINCT city_id, city, country_id FROM city;

-- 5. country table
SELECT DISTINCT country_id, country FROM country;

-- 6. customer table
SELECT DISTINCT customer_id, first_name, last_name FROM customer;

-- 7. film table
SELECT DISTINCT film_id, title, release_year FROM film;

-- 8. film_actor table
SELECT DISTINCT film_id, actor_id FROM film_actor;

-- 9. film_category table
SELECT DISTINCT film_id, category_id FROM film_category;

-- 10. inventory table
SELECT DISTINCT inventory_id, film_id, store_id FROM inventory;

-- 11. language table
SELECT DISTINCT language_id, name FROM language;

-- 12. payment table
SELECT DISTINCT payment_id, customer_id FROM payment;

-- 13. rental table
SELECT DISTINCT rental_id, rental_date, inventory_id, customer_id FROM rental;

-- 14. staff table
SELECT DISTINCT staff_id, first_name, last_name FROM staff;

-- 15. store table
SELECT DISTINCT store_id, manager_staff_id, address_id FROM store;

/*
2) Join relevant tables to create a consolidated view.
*/ 
	
-- 1. Consolidated view of customer table with rental table

CREATE VIEW customer_rental_view AS
SELECT 
c.customer_id AS customer_customer_id, 
r.customer_id AS rental_customer_id, 
c.first_name, 
c.last_name, 
r.rental_id, 
r.inventory_id
FROM customer c
INNER JOIN rental r 
ON c.customer_id = r.customer_id;

SELECT * FROM customer_rental_view;

-- 2. Consolidated view of actor table with film_actor table
CREATE VIEW actor_flim_actor_view AS
SELECT 
a.actor_id AS actor_actor_id, 
fa.actor_id AS film_actor_actor_id, 
a.first_name, 
a.last_name, 
fa.film_id
FROM actor a
LEFT JOIN film_actor fa
ON a.actor_id = fa.actor_id;

SELECT * FROM actor_flim_actor_view;

-- 3. Consolidated view of language table with film table
CREATE VIEW language_flim_view AS
SELECT
l.language_id AS language_language_id, 
f.language_id AS film_language_id, 
l.name, 
f.film_id,
f.title,
f.release_year,
f.length,
f.rating
FROM language l
RIGHT JOIN film f
ON l.language_id = f.language_id;

SELECT * FROM language_flim_view;

-- 4. Consolidated view of country table with city table
CREATE VIEW country_city_view AS
SELECT
co.country_id AS country_country_id, 
ci.country_id AS city_country_id, 
co.country, 
ci.city
FROM country co
FULL OUTER JOIN city ci
ON co.country_id = ci.country_id;

SELECT * FROM country_city_view;

/*
3) Calculate summary statistics for important columns.
*/ 

-- 1. Calculate the total number of films in the database:
SELECT COUNT(*) AS total_films FROM film;

-- 2. Calculate the average length of films
SELECT AVG(length) AS average_length FROM film;

-- 3. Determine the number of active and inactive customers:
SELECT active, COUNT(customer_id) AS customer_count
FROM customer
GROUP BY active;

-- 4. Determine the total number of films in each category:
SELECT c.name AS category, COUNT(fc.film_id) AS film_count
FROM category c
JOIN film_category fc 
ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY c.name;

-- 5. Calculate the total revenue generated from each store:
SELECT s.store_id, SUM(p.amount) AS total_revenue
FROM store s
JOIN staff st ON s.manager_staff_id = st.staff_id
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY s.store_id;

/*
4) Filter and sort data based on specific conditions.
*/ 

-- 1. How many actors have 8 letters only in their first_names.
SELECT COUNT(first_name) AS no_of_actors FROM actor
WHERE LENGTH(first_name) = 8;

-- 2. Count the number of actors who’s first_names don’t start with an ‘A’.
SELECT COUNT(*) AS no_of_actors FROM actor
WHERE first_name NOT LIKE 'A%';

-- 3. Find actor names that start with ‘P’ followed by any letter from a to e then any other letter.
SELECT * FROM actor
WHERE first_name SIMILAR TO 'P[a-e]%';

-- 4. Which movies have been rented so far.
SELECT title FROM film
WHERE film_id IN (
	SELECT DISTINCT film_id FROM rental
	JOIN inventory
	on rental.inventory_id = inventory.inventory_id
);

-- 5. Display the names of the actors that acted in more than 20 movies.
SELECT first_name, last_name, COUNT(fa.film_id) AS movie_count
FROM film_actor fa
JOIN actor a 
ON fa.actor_id = a.actor_id
GROUP BY first_name, last_name
HAVING COUNT(fa.film_id) > 20
ORDER BY movie_count;

/*

Formulate 15 questions based on the dataset, ranging from easy to difficult. 

Questions:

1) Retrieve all the distinct country names from the country table.
2) List the titles of films along with their categories.
3) Calculate the maximum length of films in the database.
4) Retrieve all the rental records where the return date is null.
5) What are the addresses of each store?
6) Count the number of films in each category, but only for categories with more than 10 films.
7) What is the name of the customer who lives in the city 'Apeldoorn'?
8) Update the email of the staff member with ID 101 to 'newemail@example.com'.
9) Write a query to create a count of movies in each of the 4 filmlen_groups:
1 hour or less
Between 1-2 hours
Between 2-3 hours
More than 3 hours
10) Select the titles of the movies that have the highest replacement cost.
11) Insert a new category named 'Documentary' into the category table.
12) Combine first_name and last_name from the customer table to become full_name.
13) Show how many inventory items are available at each store.
14) What is the total amount paid by each customer for all their rentals? For each customer, print their name and the total amount paid.
15) What payments have amounts between 3 USD and 5 USD?
*/

/*
Implement SQL code to answer the set of 15 questions.
*/
-- 1. Retrieve all the distinct country names from the country table.
SELECT DISTINCT country FROM country;

-- 2. List the titles of films along with their categories.
SELECT f.title, c.name AS categories FROM film f 
JOIN film_category fc 
ON f.film_id = fc.film_id 
JOIN category c ON fc.category_id = c.category_id;

-- 3. Calculate the maximum length of films in the database.
SELECT MAX(length) AS maximum_length_of_films FROM film;

-- 4. Retrieve all the rental records where the return date is null.
SELECT * FROM rental WHERE return_date IS NULL;

-- 5. What are the addresses of each store?
SELECT s.store_id, a.address, a.address2
FROM store s
JOIN address a ON s.address_id = a.address_id;

-- 6. Count the number of films in each category, but only for categories with more than 10 films.
SELECT c.name AS category, COUNT(fc.film_id) AS film_count FROM category c 
JOIN film_category fc 
ON c.category_id = fc.category_id 
GROUP BY c.name 
HAVING COUNT(fc.film_id) > 10
ORDER BY film_count;

-- 7. What is the name of the customer who lives in the city 'Apeldoorn'?
SELECT first_name, last_name FROM customer
WHERE address_id IN (
    SELECT address_id FROM address
    WHERE city_id = (
        SELECT city_id FROM city
        WHERE city = 'Apeldoorn'
    )
);

-- 8. Update the email of the staff member with ID 1 to 'newemail@example.com'.
UPDATE staff SET email = 'newemail@example.com' WHERE staff_id = 1;

/* 9. Write a query you to create a count of movies in each of the 4 filmlen_groups: 1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours.

filmlen_groups		filmcount_bylencat
1 hour or less			104
Between 1-2 hours		439
Between 2-3 hours		418
More than 3 hours		39
*/
SELECT DISTINCT(filmlen_groups),
      COUNT(title) OVER (PARTITION BY filmlen_groups) AS filmcount_bylencat
FROM  
     (SELECT title,length,
      CASE WHEN length <= 60 THEN '1 hour or less'
      WHEN length > 60 AND length <= 120 THEN 'Between 1-2 hours'
      WHEN length > 120 AND length <= 180 THEN 'Between 2-3 hours'
      ELSE 'More than 3 hours' END AS filmlen_groups
      FROM film ) t1
ORDER BY  filmlen_groups;

-- 10. Select the titles of the movies that have the highest replacement cost.
SELECT title, replacement_cost FROM film
WHERE replacement_cost = (
    SELECT MAX(replacement_cost) FROM film
);

-- 11. Insert a new category named 'Documentary' into the category table.
INSERT INTO category (name, last_update) VALUES ('Documentary', NOW());

-- 12. Combine first_name and last_name from the customer table to become full_name.
SELECT first_name, last_name, CONCAT(first_name, ' ', last_name) AS full_name
FROM  customer;

-- 13. Show how many inventory items are available at each store.
SELECT store.store_id, COUNT(inventory_id) FROM store, inventory
WHERE inventory.store_id = store.store_id
GROUP BY store.store_id;

-- 14. What is the total amount paid by each customer for all their rentals? For each customer print their name and the total amount paid.
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_amount_paid FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_amount_paid DESC;

-- 15. What payments have amounts between 3 USD and 5 USD?
SELECT customer_id, payment_id, amount FROM payment
WHERE amount BETWEEN 3 AND 5
ORDER BY amount;