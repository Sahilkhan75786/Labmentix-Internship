-- CUSTOMER ANALYTICS --
-- 1.1 Which customers have spent the most money on music?
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.country,
    c.email,
    SUM(i.total) as total_spent,
    COUNT(i.invoice_id) as total_purchases
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 1.2 What is the average customer lifetime value?
SELECT 
    ROUND(AVG(total_spent), 2) as avg_lifetime_value,
    ROUND(AVG(purchase_count), 2) as avg_purchases_per_customer
FROM (
    SELECT 
        c.customer_id,
        SUM(i.total) as total_spent,
        COUNT(i.invoice_id) as purchase_count
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) customer_stats;

-- 1.3 How many customers have made repeat purchases versus one-time purchases?
SELECT 
    purchase_type,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 2) as percentage
FROM (
    SELECT 
        c.customer_id,
        CASE 
            WHEN COUNT(i.invoice_id) > 1 THEN 'Repeat Customer'
            WHEN COUNT(i.invoice_id) = 1 THEN 'One-time Customer'
            ELSE 'No Purchase'
        END as purchase_type
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) purchase_categories
GROUP BY purchase_type;

-- 1.4 Which country generates the most revenue per customer?
SELECT 
    country,
    COUNT(DISTINCT c.customer_id) as total_customers,
    SUM(i.total) as total_revenue,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY country
HAVING total_customers > 5
ORDER BY revenue_per_customer DESC;

-- 1.5 Which customers haven't made a purchase in the last 6 months?
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.country,
    MAX(i.invoice_date) as last_purchase_date,
    DATEDIFF(CURDATE(), MAX(i.invoice_date)) as days_since_last_purchase
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
HAVING last_purchase_date IS NULL OR last_purchase_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY days_since_last_purchase DESC;

-- SALES AND REVENUE ANALYSIS --
-- 2.1 Monthly revenue trends for the last two years
SELECT 
    YEAR(invoice_date) as year,
    MONTH(invoice_date) as month,
    MONTHNAME(invoice_date) as month_name,
    COUNT(invoice_id) as total_invoices,
    SUM(total) as monthly_revenue,
    ROUND(AVG(total), 2) as avg_invoice_value
FROM invoice
WHERE invoice_date >= DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 2 YEAR)
GROUP BY YEAR(invoice_date), MONTH(invoice_date), MONTHNAME(invoice_date)
ORDER BY year DESC, month DESC;

-- 2.2 Average value of an invoice
SELECT 
    ROUND(AVG(total), 2) as avg_invoice_value,
    MIN(total) as min_invoice_value,
    MAX(total) as max_invoice_value,
    COUNT(*) as total_invoices
FROM invoice;

-- 2.3 Payment methods analysis (assuming payment method is in invoice table)
-- If you have a payment_method column, use this:
SELECT 
    DAYNAME(invoice_date) as day_of_week,
    COUNT(*) as transaction_count,
    SUM(total) as total_revenue,
    ROUND(AVG(total), 2) as avg_transaction_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM invoice), 2) as percentage_of_total
FROM invoice
GROUP BY DAYNAME(invoice_date), DAYOFWEEK(invoice_date)
ORDER BY DAYOFWEEK(invoice_date);

SELECT 
    HOUR(invoice_date) as hour_of_day,
    COUNT(*) as transaction_count,
    SUM(total) as total_revenue,
    ROUND(AVG(total), 2) as avg_transaction_value
FROM invoice
GROUP BY HOUR(invoice_date)
ORDER BY hour_of_day;

-- 2.4 Revenue contribution by sales representative
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) as sales_rep,
    e.title,
    COUNT(DISTINCT c.customer_id) as customers_managed,
    COUNT(i.invoice_id) as total_invoices,
    SUM(i.total) as total_revenue,
    ROUND(SUM(i.total) / COUNT(i.invoice_id), 2) as avg_sale_value
FROM employee_data e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id
ORDER BY total_revenue DESC;

-- 2.5 Peak sales months or quarters
SELECT 
    YEAR(invoice_date) as year,
    QUARTER(invoice_date) as quarter,
    COUNT(invoice_id) as total_invoices,
    SUM(total) as quarterly_revenue,
    ROUND(SUM(total) / COUNT(DISTINCT MONTH(invoice_date)), 2) as avg_monthly_revenue
FROM invoice
GROUP BY YEAR(invoice_date), QUARTER(invoice_date)
ORDER BY quarterly_revenue DESC;

-- PRODUCT & CONTENT ANALYSIS --
-- 3.1 Tracks that generated the most revenue
SELECT 
    t.track_id,
    t.name as track_name,
    a.name as artist_name,
    al.title as album_name,
    g.name as genre,
    COUNT(il.invoice_line_id) as times_purchased,
    SUM(il.unit_price * il.quantity) as total_revenue
FROM track t
JOIN ALBUMS_DATASET al ON t.album_id = al.ALBUM_ID
JOIN ARTIST_DATA a ON al.ARTIST = a.ARTIST_ID
JOIN genre g ON t.genre_id = g.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id
ORDER BY total_revenue DESC
LIMIT 20;

-- 3.2 Most frequently purchased albums
SELECT 
    al.ALBUM_ID,
    al.title as album_name,
    a.name as artist_name,
    COUNT(DISTINCT il.invoice_id) as times_purchased,
    COUNT(il.track_id) as total_tracks_sold,
    SUM(il.unit_price * il.quantity) as total_revenue
FROM ALBUMS_DATASET al
JOIN ARTIST_DATA a ON al.ARTIST = a.ARTIST_ID
JOIN track t ON al.ALBUM_ID = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY al.ALBUM_ID
ORDER BY times_purchased DESC
LIMIT 15;

-- 3.3 Tracks or albums that have never been purchased
-- Tracks never purchased
SELECT 
    t.track_id,
    t.name as track_name,
    a.name as artist_name,
    al.title as album_name
FROM track t
JOIN ALBUMS_DATASET al ON t.album_id = al.ALBUM_ID
JOIN ARTIST_DATA a ON al.ARTIST = a.ARTIST_ID
LEFT JOIN invoice_line il ON t.track_id = il.track_id
WHERE il.track_id IS NULL;

-- 3.4 Average price per track across different genres
SELECT 
    g.genre_id,
    g.name as genre_name,
    COUNT(t.track_id) as total_tracks,
    ROUND(AVG(t.unit_price), 2) as avg_track_price,
    SUM(il.unit_price * il.quantity) as total_genre_revenue,
    COUNT(il.invoice_line_id) as total_tracks_sold
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id
ORDER BY total_genre_revenue DESC;

-- 3.5 Tracks per genre vs sales correlation
SELECT 
    g.genre_id,
    g.name as genre_name,
    COUNT(DISTINCT t.track_id) as available_tracks,
    COUNT(il.invoice_line_id) as tracks_sold,
    ROUND(COUNT(il.invoice_line_id) * 100.0 / COUNT(DISTINCT t.track_id), 2) as sales_ratio,
    SUM(il.unit_price * il.quantity) as total_revenue
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id
ORDER BY sales_ratio DESC;
