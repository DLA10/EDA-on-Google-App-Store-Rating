--1.	What is the total revenue generated from all rentals in the database? (2 Marks)

SELECT SUM(rental_rate * rental_duration) AS total_revenue FROM film;


--2.	How many rentals were made in each month_name? (2 Marks)

SELECT 
    EXTRACT(MONTH FROM rental_date) AS month_number,
    COUNT(*) AS rentals_made
FROM 
    rental
GROUP BY 
    month_number;


--3.	What is the rental rate of the film with the longest title in the database? (2 Marks)

SELECT rental_rate FROM film 
WHERE film_id = (SELECT film_id FROM film ORDER BY LENGTH(title) DESC LIMIT 1);


--4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)

SELECT AVG(rental_rate)
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
WHERE rental_date >= '2005-04-05 22:04:30'::timestamp - INTERVAL '30 days';


--5.	What is the most popular category of films in terms of the number of rentals? (3 Marks)

SELECT category.name AS category_name, COUNT(*) AS rental_count 
FROM rental 
JOIN inventory ON rental.inventory_id = inventory.inventory_id 
JOIN film ON inventory.film_id = film.film_id 
JOIN film_category ON film.film_id = film_category.film_id 
JOIN category ON film_category.category_id = category.category_id 
GROUP BY category.category_id 
ORDER BY rental_count DESC 
LIMIT 1;


--6.	Find the longest movie duration from the list of films that have not been rented by any customer. (3 Marks)

SELECT film.title, film.length 
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
WHERE inventory.inventory_id IS NULL
ORDER BY length DESC
LIMIT 1;


--7.	What is the average rental rate for films, broken down by category? (3 Marks)

SELECT category.name AS category_name, AVG(film.rental_rate) AS avg_rental_rate
FROM film 
JOIN film_category ON film.film_id = film_category.film_id 
JOIN category ON film_category.category_id = category.category_id 
GROUP BY category.category_id 
ORDER BY avg_rental_rate DESC;


--8.	What is the total revenue generated from rentals for each actor in the database? (3 Marks)

SELECT actor.actor_id, actor.first_name, actor.last_name, SUM(payment.amount) AS total_revenue
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN inventory ON film_actor.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY actor.actor_id
ORDER BY total_revenue DESC;


--9.	Show all the actresses who worked in a film having a "Wrestler" in the description. (3 Marks)

SELECT DISTINCT actor.first_name, actor.last_name 
FROM actor 
JOIN film_actor ON actor.actor_id = film_actor.actor_id 
JOIN film ON film_actor.film_id = film.film_id 
WHERE film.description LIKE '%Wrestler%' ;



--10.	Which customers have rented the same film more than once? (3 Marks)

SELECT customer.customer_id, customer.first_name, customer.last_name, film.title, COUNT(*) as rental_count
FROM customer
JOIN rental ON rental.customer_id = customer.customer_id
JOIN rental rental2 ON rental.inventory_id = rental2.inventory_id AND rental.rental_id <> rental2.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP BY customer.customer_id, film.title
HAVING COUNT(*) > 1
ORDER BY customer.customer_id;



--11.	How many films in the comedy category have a rental rate higher than the average rental rate? (3 Marks)

SELECT COUNT(*) AS num_films
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Comedy'
AND film.rental_rate > (
  SELECT AVG(rental_rate)
  FROM film
  JOIN film_category ON film.film_id = film_category.film_id
  JOIN category ON film_category.category_id = category.category_id
  WHERE category.name = 'Comedy'
)



--12.	Which films have been rented the most by customers living in each city? (3 Marks)




--13.	What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)

SELECT SUM(amount) AS total_amount
FROM payment
WHERE customer_id IN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) > 200
);


--14.	Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] (2 Marks)




--15.	Create a View for the total revenue generated by each staff member, broken down by store city with the country name. (4 Marks)




--16.	Create a view based on rental information consisting of visiting_day, customer_name, the title of the film,  no_of_rental_days, the amount paid by the customer along with the percentage of customer spending. (4 Marks)

CREATE VIEW rental_info AS
SELECT 
    DATE_PART('day', rental.return_date - rental.rental_date) AS no_of_rental_days,
    rental.rental_date AS visiting_day,
    CONCAT(customer.first_name, ' ', customer.last_name) AS customer_name,
    film.title AS film_title,
    payment.amount AS amount_paid,
    100 * payment.amount / (
        SELECT SUM(amount) FROM payment
    ) AS percentage_spending
FROM rental
JOIN customer ON rental.customer_id = customer.customer_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN payment ON rental.rental_id = payment.rental_id;


SELECT * FROM rental_info;


--17.	Display the customers who paid 50% of their total rental costs within one day. (5 Marks)




