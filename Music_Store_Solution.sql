-- Ques-1 Who is the senior most employee based on job title? 

SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- -------------------------------------------------------------------------------------

-- Ques-2 Which countries have the most Invoices? 

SELECT 
    billing_country, COUNT(*)
FROM
    invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC
LIMIT 1;

-- -------------------------------------------------------------------------------------

 -- Ques-3 What are top 3 values of total invoice? 
 
SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;
 
 -- -------------------------------------------------------------------------------------
 
--  Ques-4 Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals 


SELECT 
    SUM(total) AS invoice_total, billing_city
FROM
    invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

-- -------------------------------------------------------------------------------------

-- Ques-5 Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money

SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    SUM(invoice.total) AS total
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id,
    customer.first_name,
    customer.last_name
ORDER BY total DESC
LIMIT 1;

-- -------------------------------------------------------------------------------------

-- Ques-6 Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A 

SELECT DISTINCT
    email, first_name, last_name
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE
    track_id IN (SELECT 
            track_id
        FROM
            track
                JOIN
            genre ON track.genre_id = genre.genre_id
        WHERE
            genre.name LIKE 'Rock')
ORDER BY email;

-- -------------------------------------------------------------------------------------

-- Ques-7 Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands 

SELECT 
    artist.artist_id,
    artist.name,
    COUNT(artist.artist_id) AS number_of_songs
FROM
    track
        JOIN
    album ON album.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album.artist_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name LIKE 'Rock'
GROUP BY artist.artist_id , artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- -------------------------------------------------------------------------------------

-- Ques-8 Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first 

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_track_length
        FROM
            track)
ORDER BY milliseconds DESC;

 -- -------------------------------------------------------------------------------------
 
-- Ques-9 Find how much amount spent by each customer on artists? Write a query to return 
-- customer name, artist name and total spent 

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line 
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.album_id
group by 1,2
order by 3 desc
limit 1
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM
    invoice i
        JOIN
    customer c ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON il.invoice_id = i.invoice_id
        JOIN
    track t ON t.track_id = il.track_id
        JOIN
    album alb ON alb.album_id = t.album_id
        JOIN
    best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1 , 2 , 3 , 4
ORDER BY 5 DESC;

-- -------------------------------------------------------------------------------------

-- Ques-10 We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres

with popular_genre as
( select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id, 
row_number() over(partition by customer.country order by count(invoice_line.quantity)desc) as RowNo
from invoice_line 
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id= track.genre_id
group by 2,3,4
order by 2 asc, 1 desc )
select * from popular_genre where RowNo <=1

 




