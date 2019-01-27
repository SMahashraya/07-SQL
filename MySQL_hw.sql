use sakila;
SELECT first_name, last_name
FROM actor;

ALTER TABLE actor ADD COLUMN actor_name VARCHAR(50);

UPDATE actor 
SET actor_name = CONCAT(first_name, ' ', last_name)
WHERE actor_id > ' ';

SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_name LIKE 'joe%';

SELECT actor_name
FROM actor
WHERE last_name LIKE '%gen';

SELECT *
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

SELECT country, country_id
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

ALTER TABLE actor ADD COLUMN description BLOB;

ALTER TABLE actor 
DROP COLUMN description;

SELECT last_name, COUNT(*) as num
FROM actor
GROUP BY last_name;

SELECT last_name, COUNT(*) as num
FROM actor a
GROUP BY last_name
HAVING num >= 2;

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

SHOW CREATE TABLE address;

SELECT s.first_name, s.last_name, a.address
FROM staff s
JOIN address a ON
a.address_id= s.address_id;

SELECT a.first_name, a.last_name, amt
FROM (
SELECT s.first_name, s.last_name, SUM(amount) as amt
FROM payment p
JOIN staff s ON
s.staff_id = p.staff_id
WHERE payment_date LIKE '2005%'
GROUP BY s.first_name, s.last_name) a;


SELECT title, COUNT(actor_id)
FROM film_actor fa
INNER JOIN film f ON
fa.film_id = f.film_id
GROUP BY title;

SELECT f.title, COUNT(f.title)
FROM film f
INNER JOIN inventory i ON
f.film_id = i.film_id
GROUP BY f.title
HAVING f.title = 'Hunchback Impossible';

SELECT c.first_name, c.last_name, SUM(p.amount)
FROM customer c
JOIN payment p ON 
c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name;


SELECT a.title
FROM (
SELECT l.name, l.language_id, f.title
FROM language l
JOIN film f ON
l.language_id = f.language_id
WHERE (f.title LIKE 'Q%')
OR (f.title LIKE 'K%')
GROUP BY l.name, l.language_id, f.title) a;

SELECT f.film_id, f.title, z.first_name, z.last_name
FROM (
SELECT a.actor_id, a.first_name, a.last_name, fa.film_id
FROM actor a
JOIN film_actor fa ON
a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name, fa.film_id) z
JOIN film f ON
f.film_id = z.film_id
WHERE f.title = 'Alone Trip'
GROUP BY f.film_id, f.title, z.first_name, z.last_name;



SELECT q. first_name, q.last_name, q.email,  co.country
FROM (
SELECT cu.first_name, cu.last_name, cu.email
FROM ( 
SELECT a.address_id, a.city_id, c.country_id
FROM address a
JOIN city c ON
a.city_id = c.city_id
GROUP BY a.address_id) z
JOIN customer cu ON
z.address_id = cu.address_id
GROUP BY cu.email) q
JOIN country co ON
q.country_id = co.country_id
GROUP BY q.email;

SELECT cu.email, cu.first_name, cu.last_name, z.country
FROM (
SELECT co.country, co.country_id, q.address_id
FROM (
SELECT a.address_id, a.city_id, ci.country_id
FROM address a
JOIN city ci ON
a.city_id = ci.city_id
GROUP BY a.address_id) q
JOIN country co ON
q.country_id = co.country_id
GROUP BY co.country_id, co.country, q.address_id
HAVING country = 'Canada') z
JOIN customer cu ON
cu.address_id = z.address_id
GROUP BY cu.email, cu.first_name, cu.last_name, z.country;


SELECT f.film_id, f.title
FROM (
SELECT ca.category_id, ca.name, fc.film_id
FROM category ca
JOIN film_category fc ON
fc.category_id = ca.category_id
GROUP BY ca.category_id, ca.name, fc.film_id) cafc
JOIN film f ON
cafc.film_id = f.film_id
GROUP BY f.film_id, f.title;


SELECT ir.rentals, f.film_id, f.title
FROM (
SELECT i.film_id, i.inventory_id, COUNT(r.rental_id) rentals
FROM inventory i
JOIN rental r ON
i.inventory_id = r.inventory_id
GROUP BY i.inventory_id) ir
JOIN film f ON
f.film_id = ir.film_id
GROUP BY ir.rentals, f.film_id, f.title
ORDER BY ir.rentals DESC;


SELECT s.store_id, total
FROM (
SELECT i.inventory_id, i.store_id, amt.total
FROM (
SELECT r.inventory_id, p.amount, p.payment_id, p.amount*p.payment_id as 'total'
FROM rental r
JOIN payment p ON
r.rental_id = p.rental_id
GROUP BY p.amount, p.payment_id, total) amt
JOIN inventory i ON
i.inventory_id = amt.inventory_id
GROUP BY i.inventory_id, i.store_id, amt.total) store_ttl
JOIN store s ON
s.store_id = store_ttl.store_id
GROUP BY s.store_id, total;


SELECT s.store_id, addci.city, addci.country
FROM (
SELECT a.address_id, a.city_id, coci.city, coci.country
FROM (
SELECT co.country_id, co.country, ci.city_id, ci.city
FROM country co
JOIN city ci ON
co.country_id = ci.country_id
GROUP BY co.country_id, co.country, ci.city_id, ci.city) coci
JOIN address a ON
a.city_id = coci.city_id
GROUP BY a.address_id, a.city_id) addci
JOIN store s ON
s.address_id = addci.address_id
GROUP BY s.store_id, s.address_id, addci.city, addci.country;


SELECT DISTINCT ca.category_id, ca.name, SUM(cipr.total) as 'sum_total'
FROM (
SELECT fc.film_id, fc.category_id, ipr.total
FROM (
SELECT i.film_id, i.inventory_id, pr.total
FROM (
SELECT r.inventory_id, p.payment_id, p.amount, p.payment_id*p.amount 'total'
FROM payment p
JOIN rental r ON
p.rental_id = r.rental_id
GROUP BY p.payment_id, p.amount, total) pr
JOIN inventory i ON
i.inventory_id = pr.inventory_id
GROUP BY i.film_id, i.inventory_id, pr.total) ipr
JOIN film_category fc ON
fc.film_id = ipr.film_id
GROUP BY fc.film_id, fc.category_id, ipr.total)cipr
JOIN category ca ON
ca.category_id = cipr.category_id
GROUP BY ca.category_id, ca.name
ORDER BY sum_total DESC
LIMIT 5;


CREATE VIEW top_five_genres AS
SELECT DISTINCT ca.category_id, ca.name, SUM(cipr.total) as 'sum_total'
FROM (
SELECT fc.film_id, fc.category_id, ipr.total
FROM (
SELECT i.film_id, i.inventory_id, pr.total
FROM (
SELECT r.inventory_id, p.payment_id, p.amount, p.payment_id*p.amount 'total'
FROM payment p
JOIN rental r ON
p.rental_id = r.rental_id
GROUP BY p.payment_id, p.amount, total) pr
JOIN inventory i ON
i.inventory_id = pr.inventory_id
GROUP BY i.film_id, i.inventory_id, pr.total) ipr
JOIN film_category fc ON
fc.film_id = ipr.film_id
GROUP BY fc.film_id, fc.category_id, ipr.total)cipr
JOIN category ca ON
ca.category_id = cipr.category_id
GROUP BY ca.category_id, ca.name
ORDER BY sum_total DESC
LIMIT 5; 

DROP VIEW top_five_genres;















