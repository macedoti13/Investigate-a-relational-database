/* Question Set #1, Question 2 */
WITH T1 AS (SELECT f.title film_title, c.name category_name, f.rental_duration rental_duration, NTILE(4) OVER(ORDER BY f.rental_duration) standard_quartile
FROM category c
JOIN film_category fc
ON fc.category_id = c.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 3 DESC)

SELECT category_name, rental_duration, count(*)
FROM T1
GROUP BY 1, 2
order by 1,2

/* Question Set #1, Question 3 */
WITH t1 AS (SELECT f.title film_title, c.name category_name, f.rental_duration, NTILE(4) OVER(ORDER BY f.rental_duration) standard_quartile
FROM category c
JOIN film_category fc
ON fc.category_id = c.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 3 DESC )

SELECT category_name, standard_quartile, COUNT(film_title)
FROM t1
GROUP BY 1, 2
ORDER BY 1, 2;


/* Question Set #2, Question 2*/
WITH t1 AS (
            SELECT (c.first_name)|| ' ' ||(c.last_name) AS full_name,
            SUM(p.amount) AS total_amt_spent
            FROM customer c
            JOIN payment p
            ON c.customer_id = p.customer_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 10)

SELECT (c.first_name)|| ' ' ||(c.last_name) full_name,
DATE_TRUNC('month', p.payment_date) pay_mon,
COUNT(p.*) pay_count,
SUM(p.amount) total_spent
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE (c.first_name)|| ' ' ||(c.last_name) IN (SELECT full_name FROM T1)
AND (p.payment_date BETWEEN '2007-01-01' AND '2008-01-01')
GROUP BY 1, 2
ORDER BY 1, 2, 3;


/* Question Set #2, Question 3 */
WITH t1 AS (
            SELECT (c.first_name)|| ' ' ||(c.last_name) AS full_name,
            SUM(p.amount) AS total_amt_spent
            FROM customer c
            JOIN payment p
            ON c.customer_id = p.customer_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 10),

t2 AS (
        SELECT (c.first_name)|| ' ' ||(c.last_name) full_name,
        DATE_TRUNC('month', p.payment_date) pay_mon,
        COUNT(p.*) pay_count,
        SUM(p.amount) total_spent
        FROM customer c
        JOIN payment p
        ON c.customer_id = p.customer_id
        WHERE (c.first_name)|| ' ' ||(c.last_name) IN (SELECT full_name FROM T1)
        AND (p.payment_date BETWEEN '2007-01-01' AND '2008-01-01')
        GROUP BY 1, 2
        ORDER BY 1, 2, 3),

t3 AS (
       SELECT *,
       LEAD(total_spent) OVER (PARTITION BY full_name ORDER BY pay_mon) AS lead,
       LEAD(total_spent) OVER (PARTITION BY full_name ORDER BY pay_mon) - total_spent AS lead_difference
       FROM t2)

SELECT *,
CASE WHEN lead_difference = (SELECT MAX(t3.lead_difference)  FROM t3 ORDER BY 1 DESC LIMIT 1)
THEN 'Maximum difference'
ELSE NULL
END AS is_max
FROM t3;
