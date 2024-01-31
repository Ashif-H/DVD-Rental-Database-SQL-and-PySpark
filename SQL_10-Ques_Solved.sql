/*
Question 1:
Level: Simple
Topic: DISTINCT

Task: Create a list of all the different (distinct) replacement costs of the films.
Question: What's the lowest replacement cost?
Answer: 9.99
*/

SELECT MIN(DISTINCT replacement_cost) AS lowest_replacement_cost
FROM film;

/*
Question 2:
Level: Moderate
Topic: CASE + GROUP BY

Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
low: 9.99 - 19.99
medium: 20.00 - 24.99
high: 25.00 - 29.99

Question: How many films have a replacement cost in the "low" group?
Answer: 514
*/

SELECT 
    CASE 
        WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
        WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
        WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
    END AS cost_range,
    COUNT(*) AS number_of_films
FROM film
GROUP BY 
    CASE 
        WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
        WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
        WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
    END
ORDER BY number_of_films DESC
LIMIT 1;

/*
Question 3:
Level: Moderate
Topic: JOIN

Task: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
Question: In which category is the longest film and how long is it?
Answer: Sports and 184
*/

SELECT f.title, f.length, category.name AS category_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category ON fc.category_id = category.category_id
WHERE category.name IN ('Drama', 'Sports')
ORDER BY f.length DESC;

/*
Question 4:
Level: Moderate
Topic: JOIN & GROUP BY

Task: Create an overview of how many movies (titles) there are in each category (name).
Question: Which category (name) is the most common among the films?
Answer: Sports with 74 titles
*/

SELECT c.name AS category_name, COUNT(f.title) AS movie_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY movie_count DESC
LIMIT 1;

/*
Question 5:
Level: Moderate
Topic: JOIN & GROUP BY

Task: Create an overview of the actors' first and last names and in how many movies they appear in.
Question: Which actor is part of most movies??
Answer: Susan Davis with 54 movies
*/

SELECT 
	CONCAT(a.first_name, ' ', a.last_name) AS actor_name, 
    COUNT(fa.film_id) AS movie_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 1;

/*
Question 6:
Level: Moderate
Topic: LEFT JOIN & FILTERING

Task: Create an overview of the addresses that are not associated to any customer.
Question: How many addresses are that?
Answer: 4
*/

SELECT COUNT(*) AS address_count FROM address a
LEFT JOIN customer c ON a.address_id = c.address_id
WHERE c.customer_id IS NULL;

/*
Question 7:
Level: Moderate
Topic: JOIN & GROUP BY

Task: Create the overview of the sales to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur.
Question: What city is that and how much is the amount?
Answer: Cape Coral with a total amount of 221.55
*/
	
SELECT c.city, SUM(p.amount) AS total_amount
FROM payment p
JOIN customer cust ON p.customer_id = cust.customer_id
JOIN address a ON cust.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
GROUP BY c.city
ORDER BY total_amount DESC;

/*
Question 8:
Level: Moderate to difficult
Topic: JOIN & GROUP BY

Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
Question: Which country, city has the least sales?
Answer: United States, Tallahassee with a total amount of 50.85.
*/

SELECT 
    CONCAT(country.country, ', ', city.city) AS country_city,
    SUM(payment.amount) AS total_amount
FROM payment
JOIN customer ON payment.customer_id = customer.customer_id
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
GROUP BY country.country, city.city
ORDER BY total_amount ASC;

/*
Question 9:
Level: Difficult
Topic: Uncorrelated subquery

Task: Create a list with the average of the sales amount each staff_id has per customer.
Question: Which staff_id makes on average more revenue per customer?
Answer: staff_id 2 with an average revenue of 56.64 per customer.
*/

SELECT 
    staff_id,
    ROUND(AVG(total_sales_per_customer), 2) AS average_revenue_per_customer
FROM 
    (
        SELECT 
            staff_id,
            customer_id,
            SUM(amount) AS total_sales_per_customer FROM payment
        GROUP BY staff_id, customer_id
    ) AS subquery
GROUP BY staff_id
ORDER BY average_revenue_per_customer DESC
LIMIT 1;

/*
Question 10:
Level: Difficult to very difficult
Topic: EXTRACT + Uncorrelated subquery

Task: Create a query that shows average daily revenue of all Sundays.
Question: What is the daily average revenue of all Sundays?
Answer: 1410.65
*/
SELECT ROUND(AVG(total_amount), 2) AS average_daily_revenue_of_all_sundays FROM
(	SELECT 
		SUM(amount) AS total_amount, 
		DATE(payment_date) AS only_date, 
		EXTRACT(DOW FROM payment_date) AS day_of_week FROM payment
	GROUP BY 
		only_date, day_of_week
) 
WHERE day_of_week = 0;
