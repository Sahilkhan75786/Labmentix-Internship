-- ARTIST & GENRE PERFORMANCE --
-- 4.1 Top 5 highest-grossing artists
SELECT 
    a.ARTIST_ID,
    a.name as artist_name,
    COUNT(DISTINCT al.ALBUM_ID) as total_albums,
    COUNT(DISTINCT t.track_id) as total_tracks,
    COUNT(il.invoice_line_id) as tracks_sold,
    SUM(il.unit_price * il.quantity) as total_revenue
FROM ARTIST_DATA a
JOIN ALBUMS_DATASET al ON a.ARTIST_ID = al.ARTIST
JOIN track t ON al.ALBUM_ID = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY a.ARTIST_ID
ORDER BY total_revenue DESC
LIMIT 5;

-- 4.2 Genre popularity by tracks sold
SELECT 
    g.genre_id,
    g.name as genre_name,
    COUNT(il.invoice_line_id) as tracks_sold,
    SUM(il.unit_price * il.quantity) as total_revenue,
    ROUND(AVG(t.unit_price), 2) as avg_price
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id
ORDER BY tracks_sold DESC;

-- 4.3 Genre popularity by revenue
SELECT 
    g.genre_id,
    g.name as genre_name,
    SUM(il.unit_price * il.quantity) as total_revenue,
    COUNT(il.invoice_line_id) as tracks_sold,
    ROUND(SUM(il.unit_price * il.quantity) / COUNT(il.invoice_line_id), 2) as revenue_per_track
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id
ORDER BY total_revenue DESC;

-- 4.4 Genre popularity by country
SELECT 
    c.country,
    g.name as genre_name,
    COUNT(il.invoice_line_id) as tracks_sold,
    SUM(il.unit_price * il.quantity) as total_revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name
ORDER BY c.country, total_revenue DESC;

--- EMPLOYEE & OPERATIONAL EFFICIENCY ---
-- 5.1 Employees managing highest-spending customers
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) as sales_rep,
    e.title,
    COUNT(DISTINCT c.customer_id) as total_customers,
    SUM(i.total) as total_revenue,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer,
    MAX(i.total) as largest_sale
FROM employee_data e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id
ORDER BY total_revenue DESC;

-- 5.2 Average number of customers per employee
SELECT 
    ROUND(COUNT(DISTINCT c.customer_id) * 1.0 / COUNT(DISTINCT e.employee_id), 2) as avg_customers_per_rep
FROM employee_data e
LEFT JOIN customer c ON e.employee_id = c.support_rep_id
WHERE e.title LIKE '%Sales%' OR e.title LIKE '%Support%';

-- 5.3 Revenue by employee regions
SELECT 
    e.city as employee_city,
    e.country as employee_country,
    COUNT(DISTINCT e.employee_id) as total_employees,
    COUNT(DISTINCT c.customer_id) as customers_managed,
    SUM(i.total) as total_revenue
FROM employee_data e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.city, e.country
ORDER BY total_revenue DESC;

-- GEOGRAPHIC TRENDS --
-- 6.1 Countries with highest number of customers
SELECT 
    country,
    COUNT(*) as total_customers,
    SUM(i.total) as total_revenue,
    ROUND(SUM(i.total) / COUNT(*), 2) as revenue_per_customer
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY country
ORDER BY total_customers DESC;

-- 6.2 Revenue variation by region
SELECT 
    country,
    COUNT(DISTINCT c.customer_id) as total_customers,
    SUM(i.total) as total_revenue,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) as avg_revenue_per_customer,
    COUNT(i.invoice_id) as total_transactions
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY country
HAVING total_customers >= 5
ORDER BY total_revenue DESC;

-- 6.3 Underserved geographic regions
SELECT 
    country,
    COUNT(*) as total_customers,
    COALESCE(SUM(i.total), 0) as total_revenue,
    CASE 
        WHEN COUNT(*) > 10 AND COALESCE(SUM(i.total), 0) < 100 THEN 'High Potential - Low Revenue'
        WHEN COUNT(*) > 5 AND COALESCE(SUM(i.total), 0) < 50 THEN 'Medium Potential - Low Revenue'
        ELSE 'Adequately Served'
    END as service_status
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY country
ORDER BY total_customers DESC;

-- CUSTOMER RETENTION & PURCHASE RETURNS --
-- 7.1 Purchase frequency distribution
SELECT 
    purchase_frequency,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 2) as percentage
FROM (
    SELECT 
        c.customer_id,
        COUNT(i.invoice_id) as purchase_frequency
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) freq_table
GROUP BY purchase_frequency
ORDER BY purchase_frequency;

-- 7.2 Average time between customer purchases
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(i.invoice_id) as total_purchases,
    ROUND(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) / NULLIF(COUNT(i.invoice_id) - 1, 0), 2) as avg_days_between_purchases
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
HAVING total_purchases > 1
ORDER BY avg_days_between_purchases;

-- 7.3 Customers purchasing from multiple genres
SELECT 
    multi_genre_customers,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / MAX(total_customers), 2) as percentage
FROM (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT t.genre_id) as genres_purchased,
        CASE 
            WHEN COUNT(DISTINCT t.genre_id) > 1 THEN 'Multi-Genre Buyer'
            WHEN COUNT(DISTINCT t.genre_id) = 1 THEN 'Single-Genre Buyer'
            ELSE 'No Purchase'
        END as multi_genre_customers,
        (SELECT COUNT(*) FROM customer) as total_customers
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    LEFT JOIN invoice_line il ON i.invoice_id = il.invoice_id
    LEFT JOIN track t ON il.track_id = t.track_id
    GROUP BY c.customer_id
) genre_analysis
GROUP BY multi_genre_customers;

-- OPERATIONAL OPTIMIZATION --
-- 8.1 Common track combinations (purchased together)
SELECT 
    t1.track_id as track1_id,
    t1.name as track1_name,
    t2.track_id as track2_id,
    t2.name as track2_name,
    COUNT(*) as times_purchased_together
FROM invoice_line il1
JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
GROUP BY t1.track_id, t2.track_id
HAVING times_purchased_together >= 3
ORDER BY times_purchased_together DESC
LIMIT 20;

-- 8.2 Pricing patterns and sales performance
SELECT 
    price_range,
    COUNT(t.track_id) as total_tracks,
    SUM(il.quantity) as total_units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) as total_revenue,
    ROUND(SUM(il.quantity) * 1.0 / COUNT(t.track_id), 2) as avg_units_per_track
FROM (
    SELECT 
        track_id,
        CASE 
            WHEN unit_price < 0.50 THEN 'Under $0.50'
            WHEN unit_price < 0.75 THEN '$0.50-$0.74'
            WHEN unit_price < 1.00 THEN '$0.75-$0.99'
            WHEN unit_price < 1.25 THEN '$1.00-$1.24'
            ELSE '$1.25+'
        END as price_range
    FROM track
) price_categories
JOIN track t ON price_categories.track_id = t.track_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY price_range
ORDER BY total_revenue DESC;

-- 8.3 Media type usage trends
SELECT 
    m.media_type_id,
    m.name as media_type,
    YEAR(i.invoice_date) as year,
    COUNT(il.invoice_line_id) as tracks_sold,
    SUM(il.unit_price * il.quantity) as total_revenue,
    ROUND((COUNT(il.invoice_line_id) - LAG(COUNT(il.invoice_line_id)) 
        OVER (PARTITION BY m.media_type_id ORDER BY YEAR(i.invoice_date))) * 100.0 / 
        LAG(COUNT(il.invoice_line_id)) OVER (PARTITION BY m.media_type_id ORDER BY YEAR(i.invoice_date)), 2) as growth_percentage
FROM media_type m
JOIN track t ON m.media_type_id = t.media_type_id
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
GROUP BY m.media_type_id, YEAR(i.invoice_date)
ORDER BY m.media_type_id, year;
