#cte labs

use sakila;
select * from rental;

/*First, create a view that summarizes rental information for each customer. The view should include the customer's ID, 
name, email address, and total number of rentals (rental_count).*/

select r.customer_id, concat(c.first_name, " ", c.last_name) as full_name, c.email
from rental r
inner join customer c
on r.customer_id = c.customer_id;

select r.customer_id, concat(c.first_name, " ", c.last_name) as full_name, c.email, count(*) as rental_count
from rental r
inner join customer c
on r.customer_id = c.customer_id
group by r.customer_id
order by rental_count desc;

create view total_rental_customer as (
select r.customer_id, concat(c.first_name, " ", c.last_name) as full_name, c.email, count(*) as rental_count
from rental r
inner join customer c
on r.customer_id = c.customer_id
group by r.customer_id
order by rental_count desc);

select * from total_rental_customer;

/*Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary 
Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total 
amount paid by each customer.*/

create temporary table total_amount_customer as (
select sum(p.amount) as total_paid, t.full_name
from total_rental_customer t
inner join payment p
on t.customer_id = p.customer_id
group by t.customer_id
order by total_paid desc);

select * from total_amount_customer;

/*Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.*/

#VIEW: 
select * from total_rental_customer;

drop table total_amount_customer;

#TEMPORARY TABLE
create temporary table total_amount_customer as (
select sum(p.amount) as total_paid, t.full_name, t.customer_id
from total_rental_customer t
inner join payment p
on t.customer_id = p.customer_id
group by t.customer_id
order by total_paid desc);

select * from total_amount_customer;

with cust_summary as (
	select t.full_name,
    t.email,
    t.rental_count,
    c.total_paid as total_amount_paid
    from total_rental_customer as t
    inner join total_amount_customer as c
    on t.customer_id = c.customer_id)
    
select * from cust_summary;   

/*Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, 
email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.*/

with cust_summary as (
	select t.full_name,
    t.email,
    t.rental_count,
    c.total_paid as total_amount_paid
    from total_rental_customer as t
    inner join total_amount_customer as c
    on t.customer_id = c.customer_id)  
select *, (total_amount_paid / rental_count) as avg_pay_rental from cust_summary;   
