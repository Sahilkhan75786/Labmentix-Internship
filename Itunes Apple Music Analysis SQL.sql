CREATE DATABASE MUSIC_DATABASE;
USE MUSIC_DATABASE;

CREATE TABLE ALBUMS_DATASET(
ALBUM_ID INTEGER PRIMARY KEY,
TITLE TEXT NOT NULL,
ARTIST INTEGER NOT NULL);

CREATE TABLE ARTIST_DATA(
ARTIST_ID INTEGER PRIMARY KEY,
NAME TEXT NOT NULL);

CREATE TABLE employee_data (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    title VARCHAR(100),
    reports_to INT,
    levels VARCHAR(10),
    birthdate DATETIME,
    hire_date DATETIME,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(255)
);

CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    invoice_date DATETIME NOT NULL,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(50),
    billing_country VARCHAR(50),
    billing_postal_code VARCHAR(20),
    total DECIMAL(10, 2) NOT NULL
);

CREATE TABLE invoice_line (
    invoice_line_id INTEGER PRIMARY KEY,
    invoice_id INTEGER,
    track_id INTEGER,
    unit_price DECIMAL(10, 2),
    quantity INTEGER
);

CREATE TABLE media_type (
    media_type_id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE playlist_track (
    playlist_id INT NOT NULL,
    track_id INT NOT NULL,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id)
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    company VARCHAR(80),
    address VARCHAR(120),
    city VARCHAR(60),
    state VARCHAR(40),
    country VARCHAR(40),
    postal_code VARCHAR(20),
    phone VARCHAR(30),
    fax VARCHAR(30),
    email VARCHAR(80),
    support_rep_id INT
);

CREATE TABLE track (
    track_id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    album_id INTEGER,
    media_type_id INTEGER,
    genre_id INTEGER,
    composer VARCHAR(255),
    milliseconds INTEGER,
    bytes INTEGER,
    unit_price NUMERIC(4,2)
);

select * from employee_data;

insert into employee_data (employee_id, last_name, first_name, title, reports_to, levels, 
birthdate, hire_date, address, city, state, country, postal_code, phone, fax, email) values
(1, 'Adams', 'Andrew','General Manager',9,'L6', '1962-02-18 00:00','2016-08-14 00:00','1120 Jasper Ave NW',
'Edmonton','AB','Canada','T5K 2N1','+1 (780)-428-9482','+1 (780)-428-3457','andrew@chinookcorp.com'),
(2,'Edwards','Nancy','Sales Manager',1,'L4', '1958-12-08 00:00','2016-05-01 00:00','825 8 Ave SW',
'Calgary','AB','Canada','T2P 2T3', '+1 (403) 262-3443', '+1 (403) 262-3322', 'nancy@chinookcorp.com'),
(3,'Peacock','Jane', 'Sales Support Agent',2, 'L1','1973-08-29 00:00','2017-04-01 00:00',
'1111 6 Ave SW', 'Calgary', 'AB', 'Canada',	'T2P 5M5', '+1 (403) 262-3443',	'+1 (403) 262-6712', 'jane@chinookcorp.com'),
(4,'Park','Margaret','Sales Support Agent', 2,'L1', '1947-09-19 00:00',	'2017-05-03 00:00',	
'683 10 Street SW',	'Calgary', 'AB',' Canada', 'T2P 5G3',' +1 (403) 263-4423', '+1 (403) 263-4289', 'margaret@chinookcorp.com'),
(5,'Johnson','Steve', 'Sales Support Agent', 2, 'L1', '1965-03-03 00:00', '2017-10-17 00:00', 
'7727B 41 Ave',' Calgary', 'AB','Canada', 'T3B 1Y7', '1 (780) 836-9987', '1 (780) 836-9543', 'steve@chinookcorp.com'),
(6,'Mitchell','Michael', 'IT Manager', 1, 'L3', '1973-07-01 00:00', '2016-10-17 00:00', 
'5827 Bowness Road NW', 'Calgary', 'AB', 'Canada', 'T3B 0C5', '+1 (403) 246-9887', '+1 (403) 246-9899', 'michael@chinookcorp.com'),
(7, 'King', 'Robert', 'IT Staff',6, 'L2', '1970-05-29 00:00', '2017-01-02 00:00', 
'590 Columbia Boulevard West', 'Lethbridge', 'AB', 'Canada', 'T1K 5N8', '+1 (403) 456-9986', '+1 (403) 456-8485', 'robert@chinookcorp.com'),
(8,'Callahan', 'Laura',	'IT Staff',	6, 'L2', '1968-01-09 00:00', '2017-03-04 00:00', 
'923 7 ST NW', 'Lethbridge', 'AB', 'Canada', 'T1H 1Y8',  '+1 (403) 467-3351', '+1 (403) 467-8772', 'laura@chinookcorp.com'),
(9, 'Madan', 'Mohan', 'Senior General Manager', 5,'L7', '1961-01-26 00:00', '2016-01-14 00:00', 
'1008 Vrinda Ave MT', 'Edmonton', 'AB', 'Canada', 'T5K 2N1', '+1 (780) 428-9482', '+1 (780) 428-3457', 'madan.mohan@chinookcorp.com');

select * from employee_data;
select * from albums_dataset;
select * from customer;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

-- 1. Customer Overview
SELECT 
    country,
    COUNT(*) as total_customers,
    ROUND(AVG(total), 2) as avg_invoice_value
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY country
ORDER BY total_customers DESC;

-- 2. Revenue Trends by Month
SELECT 
    YEAR(invoice_date) as year,
    MONTH(invoice_date) as month,
    SUM(total) as monthly_revenue,
    ROUND(SUM(total) / SUM(SUM(total)) OVER (PARTITION BY YEAR(invoice_date)) * 100, 2) as revenue_percentage
FROM invoice
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY year, month;

-- 3. Top Selling Artists
SELECT 
    a.name as artist_name,
    COUNT(il.track_id) as tracks_sold,
    SUM(il.unit_price * il.quantity) as total_revenue
FROM ARTIST_DATA a
JOIN ALBUMS_DATASET al ON a.ARTIST_ID = al.ARTIST  -- Changed to al.ARTIST
JOIN track t ON al.ALBUM_ID = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY a.name
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Customer Engagement by Support Rep
SELECT 
    e.first_name,
    e.last_name,
    COUNT(DISTINCT c.customer_id) as customers_supported,
    SUM(i.total) as total_sales,
    ROUND(AVG(i.total), 2) as avg_sale_value
FROM employee_data e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id
ORDER BY total_sales DESC;

-- 5. Playlist Popularity
SELECT 
    p.name as playlist_name,
    COUNT(pt.track_id) as total_tracks,
    COUNT(DISTINCT il.invoice_id) as times_purchased
FROM playlist p
JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
LEFT JOIN invoice_line il ON pt.track_id = il.track_id
GROUP BY p.playlist_id
ORDER BY times_purchased DESC;

--- ADVANCED ANALYTICS ---
-- 1. Customer Segmentation using RFM Analysis
WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        DATEDIFF(MAX(i.invoice_date), CURRENT_DATE()) as recency,
        COUNT(i.invoice_id) as frequency,
        SUM(i.total) as monetary,
        NTILE(4) OVER (ORDER BY DATEDIFF(MAX(i.invoice_date), CURRENT_DATE()) DESC) as r_score,
        NTILE(4) OVER (ORDER BY COUNT(i.invoice_id)) as f_score,
        NTILE(4) OVER (ORDER BY SUM(i.total)) as m_score
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
)
SELECT 
    customer_id,
    first_name,
    last_name,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE 
        WHEN r_score = 4 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 3 AND m_score >= 3 THEN 'Potential Loyalists'
        WHEN r_score = 2 THEN 'Recent Customers'
        WHEN r_score = 1 THEN 'At Risk'
        ELSE 'Need Attention'
    END as customer_segment
FROM customer_rfm
ORDER BY monetary DESC;

-- 2. Top Performing Tracks with Window Functions
WITH track_performance AS (
    SELECT 
        t.track_id,
        t.name as track_name,
        a.name as artist_name,
        al.title as album_name,
        COUNT(il.invoice_line_id) as times_purchased,
        SUM(il.unit_price * il.quantity) as total_revenue,
        RANK() OVER (ORDER BY SUM(il.unit_price * il.quantity) DESC) as revenue_rank,
        DENSE_RANK() OVER (PARTITION BY g.genre_id ORDER BY SUM(il.unit_price * il.quantity) DESC) as genre_rank
    FROM track t
    JOIN ALBUMS_DATASET al ON t.album_id = al.ALBUM_ID
    JOIN ARTIST_DATA a ON al.ARTIST = a.ARTIST_ID  -- Changed to al.ARTIST
    JOIN genre g ON t.genre_id = g.genre_id
    JOIN invoice_line il ON t.track_id = il.track_id
    GROUP BY t.track_id
)
SELECT 
    track_name,
    artist_name,
    album_name,
    times_purchased,
    total_revenue,
    revenue_rank,
    genre_rank
FROM track_performance
WHERE revenue_rank <= 20
ORDER BY revenue_rank;

-- 3. Monthly Sales Growth Analysis
WITH monthly_sales AS (
    SELECT 
        YEAR(invoice_date) as year,
        MONTH(invoice_date) as month,
        SUM(total) as monthly_revenue,
        LAG(SUM(total)) OVER (ORDER BY YEAR(invoice_date), MONTH(invoice_date)) as prev_month_revenue
    FROM invoice
    GROUP BY YEAR(invoice_date), MONTH(invoice_date)
)
SELECT 
    year,
    month,
    monthly_revenue,
    prev_month_revenue,
    ROUND(((monthly_revenue - prev_month_revenue) / prev_month_revenue) * 100, 2) as growth_percentage,
    CASE 
        WHEN monthly_revenue > prev_month_revenue THEN 'Growth'
        WHEN monthly_revenue < prev_month_revenue THEN 'Decline'
        ELSE 'Stable'
    END as trend
FROM monthly_sales
ORDER BY year, month;

-- 4. Customer Lifetime Value (CLV) Analysis
WITH customer_purchases AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(i.invoice_id) as total_purchases,
        SUM(i.total) as total_spent,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) as customer_tenure_days,
        CASE 
            WHEN DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) = 0 THEN SUM(i.total)
            ELSE SUM(i.total) / (DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) / 30.0)
        END as monthly_value
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
)
SELECT 
    customer_id,
    first_name,
    last_name,
    total_purchases,
    total_spent,
    customer_tenure_days,
    monthly_value,
    NTILE(5) OVER (ORDER BY monthly_value DESC) as value_segment
FROM customer_purchases
ORDER BY monthly_value DESC;

-- 5. Genre Popularity Over Time
SELECT 
    g.name as genre_name,
    YEAR(i.invoice_date) as year,
    QUARTER(i.invoice_date) as quarter,
    COUNT(il.invoice_line_id) as tracks_sold,
    SUM(il.unit_price * il.quantity) as genre_revenue,
    ROUND(SUM(il.unit_price * il.quantity) / SUM(SUM(il.unit_price * il.quantity)) 
        OVER (PARTITION BY YEAR(i.invoice_date), QUARTER(i.invoice_date)) * 100, 2) as market_share
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
GROUP BY g.genre_id, YEAR(i.invoice_date), QUARTER(i.invoice_date)
ORDER BY year, quarter, genre_revenue DESC;

