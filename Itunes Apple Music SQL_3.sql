-- Who is the senior most employee based on job title? --
SELECT * FROM employee_data ORDER BY levels DESC LIMIT 1;

-- Which countries have the most Invoices? --
SELECT billing_country, COUNT(*) AS invoice_count FROM invoice GROUP BY billing_country 
ORDER BY invoice_count DESC;

-- What are top 3 values of total invoice? --
SELECT total FROM invoice  ORDER BY total DESC LIMIT 3;

-- Which city has the best customers? --
SELECT billing_city, SUM(total) AS total_revenue FROM invoice GROUP BY billing_city 
ORDER BY total_revenue DESC LIMIT 1;

-- Who is the best customer? --
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id GROUP BY c.customer_id ORDER BY total_spent DESC 
LIMIT 1;

-- Rock Music listeners --
SELECT DISTINCT c.email, c.first_name, c.last_name FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id 
JOIN invoice_line il ON i.invoice_id = il.invoice_id JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id WHERE g.name = 'Rock' ORDER BY c.email;

-- Top 10 rock artists --
SELECT a.name AS artist_name, COUNT(t.track_id) AS track_count FROM ARTIST_DATA a
JOIN ALBUMS_DATASET al ON a.ARTIST_ID = al.ARTIST JOIN track t ON al.ALBUM_ID = t.album_id
JOIN genre g ON t.genre_id = g.genre_id WHERE g.name = 'Rock' GROUP BY a.ARTIST_ID
ORDER BY track_count DESC LIMIT 10;

-- Tracks longer than average length --
SELECT name, milliseconds FROM track WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

-- Amount spent by each customer on artists --
SELECT c.first_name, c.last_name, a.name AS artist_name,
SUM(il.unit_price * il.quantity) AS total_spent FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN ALBUMS_DATASET al ON t.album_id = al.ALBUM_ID
JOIN ARTIST_DATA a ON al.ARTIST = a.ARTIST_ID
GROUP BY c.customer_id, a.ARTIST_ID
ORDER BY total_spent DESC;

-- Most popular music genre for each country --
WITH country_genre_sales AS (
    SELECT 
        i.billing_country AS country,
        g.name AS genre_name,
        COUNT(il.invoice_line_id) AS purchase_count,
        RANK() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.invoice_line_id) DESC) AS rank_num
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY i.billing_country, g.genre_id
)
SELECT country, genre_name, purchase_count
FROM country_genre_sales
WHERE rank_num = 1
ORDER BY country;

-- Top spending customer for each country --
WITH customer_spending AS (
    SELECT 
        c.country,
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(i.total) AS total_spent,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS rank_num
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id
)
SELECT country, first_name, last_name, total_spent
FROM customer_spending
WHERE rank_num = 1
ORDER BY country;

-- Most popular artists --
SELECT 
    a.name AS artist_name,
    COUNT(il.invoice_line_id) AS tracks_sold,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM ARTIST_DATA a
JOIN ALBUMS_DATASET al ON a.ARTIST_ID = al.ARTIST
JOIN track t ON al.ALBUM_ID = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY a.ARTIST_ID
ORDER BY tracks_sold DESC
LIMIT 10;

-- Most popular song --
SELECT 
    t.name AS track_name,
    a.name AS artist_name,
    COUNT(il.invoice_line_id) AS times_purchased,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM track t
JOIN ALBUMS_DATASET al ON t.album_id = al.ALBUM_ID
JOIN ARTIST_DATA a ON al.ARTIST = a.ARTIST_ID
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id
ORDER BY times_purchased DESC
LIMIT 1;

-- Average prices of different music types --
SELECT 
    g.name AS genre,
    ROUND(AVG(t.unit_price), 2) AS avg_price,
    COUNT(t.track_id) AS total_tracks,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id
ORDER BY avg_price DESC;

-- Most popular countries for music purchases --
SELECT 
    billing_country AS country,
    COUNT(*) AS total_invoices,
    SUM(total) AS total_revenue,
    ROUND(AVG(total), 2) AS avg_invoice_value,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;