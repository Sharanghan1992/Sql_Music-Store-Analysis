SELECT * FROM album
SELECT * FROM artist
SELECT * FROM customer
SELECT * FROM employee
SELECT * FROM genre
SELECT * FROM invoice
SELECT * FROM invoice_line
SELECT * FROM media_type
SELECT * FROM playlist
SELECT * FROM playlist_track
SELECT * FROM track


--Question set 1
--Q1) Who is the senior most employee based on job title?
SELECT
	title,
	first_name,
	last_name,
	levels
FROM
	employee
ORDER BY
	levels DESC

--Q2) Which  countries have the most invoices?
SELECT
	billing_country,
	COUNT(*) AS number_of_invoices
FROM
	invoice
GROUP BY
	billing_country
ORDER BY
	COUNT(*) desc

--Q3) What are top 3 values of total invocie?
SELECT TOP 3
	*
FROM
	invoice
ORDER BY
	total DESC

--Q4) Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals */
SELECT
	billing_city,
	COUNT(customer_id) AS number_of_customers,
	SUM(total) AS invoice_total
FROM
	invoice
GROUP BY
	billing_city
ORDER BY
	SUM(total) DESC

--Q5) Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
SELECT TOP 1
	customer.first_name,
	customer.last_name,
	customer.country,
	SUM(invoice.total) AS total_spent
FROM
	customer
JOIN
	invoice	
ON
	customer.customer_id = invoice.customer_id
GROUP BY
	customer.first_name,
	customer.last_name,
	customer.country
ORDER BY
	SUM(invoice.total) DESC


--Question set 2
--Q1) Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.
SELECT
	DISTINCT(customer.first_name),
	customer.last_name,
	customer.email,
	genre.name
FROM
	customer
JOIN
	invoice ON invoice.customer_id = customer.customer_id
JOIN
	invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN
	track ON track.track_id = invoice_line.track_id
JOIN
	genre ON genre.genre_id = track.genre_id
WHERE
	genre.name = 'Rock'
ORDER BY
	email

--Q2) Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT TOP 10
	artist.name AS artist_name,
	COUNT(track.track_id) AS total_tracks
FROM
	artist
JOIN
	album ON album.artist_id = artist.artist_id
JOIN
	track ON track.album_id = album.album_id
JOIN
	genre ON genre.genre_id = track.genre_id
WHERE
	genre.name = 'Rock'
GROUP BY
	artist.name
ORDER BY
	COUNT(track.track_id) DESC

--Q3) Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT
	name,
	milliseconds
FROM
	track
WHERE
	milliseconds >
	(SELECT
		AVG(milliseconds) AS avg_track_lenght
		FROM
			track)
ORDER BY
	milliseconds DESC

-- Question set 3

-- Q1) Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

--Method 1 - Using JOINS
SELECT
	customer.customer_id,
	CONCAT(customer.first_name,' ',customer.last_name) AS customer_Name,
	artist.name AS artist_name,
	SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM
	customer
JOIN
	invoice ON invoice.customer_id = customer.customer_id
JOIN
	invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN
	track ON track.track_id = invoice_line.track_id
JOIN
	album ON album.album_id = track.album_id
JOIN
	artist ON artist.artist_id = album.artist_id
GROUP BY
	customer.customer_id,
	customer.first_name,
	customer.last_name,
	artist.name

--Method 2 - Using CTE
WITH artist_sales AS (
	SELECT
		artist.artist_id,
		artist.name AS artist_name,
		SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM
		artist
	JOIN
		album ON album.artist_id = artist.artist_id
	JOIN
		track ON track.album_id = album.album_id
	JOIN
		invoice_line ON invoice_line.track_id = track.track_id
	GROUP BY
		artist.artist_id,
		artist.name
)
SELECT
	customer.customer_id,
	customer.first_name,
	customer.last_name,
	artist_sales.artist_name,
	SUM(invoice_line.unit_price * invoice_line.quantity) AS amount_spent
FROM
	customer
JOIN
	invoice ON invoice.customer_id = customer.customer_id
JOIN
	invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN
	track ON track.track_id = invoice_line.track_id
JOIN
	album ON album.album_id = track.album_id
JOIN
	artist_sales ON artist_sales.artist_id = album.artist_id
GROUP BY
	customer.customer_id,
	customer.first_name,
	customer.last_name,
	artist_sales.artist_name


--Q2) We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount (Count) of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres
WITH genre_rank AS
(
	SELECT
		customer.country,
		genre.name AS genre_name,
		COUNT(invoice_line.quantity) AS qty_purchased,
		RANK() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rank
	FROM
		customer
	JOIN
		invoice ON invoice.customer_id = customer.customer_id
	JOIN
		invoice_line ON invoice_line.invoice_id = invoice.invoice_id
	JOIN
		track ON track.track_id = invoice_line.track_id
	JOIN
		genre On genre.genre_id = track.genre_id
	GROUP BY
		customer.country,
		genre.name
)
SELECT *
FROM
	genre_rank
WHERE
	rank <=1


--Q3) Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH customer_rank AS
(
	SELECT
		customer.country,
		customer.first_name,
		customer.last_name,
		SUM(invoice_line.quantity * invoice_line.unit_price) AS total_spent,
		RANK() OVER(PARTITION BY customer.country ORDER BY SUM(invoice_line.quantity * invoice_line.unit_price) DESC) AS Rank
	FROM
		customer
	JOIN
		invoice ON invoice.customer_id = customer.customer_id
	JOIN
		invoice_line ON invoice_line.invoice_id = invoice.invoice_id
	GROUP BY
		customer.first_name,
		customer.last_name,
		customer.country
)
SELECT *
FROM
	customer_rank
WHERE
	Rank <= 1
ORDER BY
	total_spent DESC





	




















