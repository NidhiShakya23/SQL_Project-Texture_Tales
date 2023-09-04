use casestudy3;
select *from product_details limit 10;
select *from product_prices limit 10;
select *from product_hierarchy limit 10;
select *from sales limit 10;

##1.What was the total quantity sold for all products?
select d.product_name,sum(s.qty) as total_qty
from product_details as d
inner join sales as s
on d.product_id=s.prod_id
group by d.product_name
##2.What is the total generated revenue for all products before  discounts?
select sum(s.price*s.qty) as total_revenue
from sales as s;
##3.What was the total discount amount for all products?
select sum(price*qty*discount)/100 as total_discount from sales;
##4.How many unique transactions were there?
select count(distinct txn_id) from sales;
##5.What are the average unique products purchased in each  transaction?
with new_cte as (select txn_id ,count( distinct prod_id) as count_1 from sales group by txn_id)
select round(avg(count_1)) as avg_products
from new_cte;
##6.What is the average discount value per transaction?
with cte2 as (select txn_id,sum(price*qty*discount)/100 as 'discount' from sales group by txn_id)
select avg(discount) as avg_discount from cte2;
##7.hat is the average revenue for member transactions and non member transaction
with cte3 as (
select qty*price as total_revenue,member from sales )
select avg(total_revenue) as avg_profit,member 
from cte3
group by member;
##What are the top 3 products by total revenue before discount?
select  product_details.product_name,sum(sales.price*sales.qty) as total_revenue
from product_details,sales
where product_details.product_id=sales.prod_id
group by product_details.product_name
order by total_revenue desc
limit 3;
##9.What are the total quantity, revenue and discount for each segment
##also use inner join
select sum(qty) as total_quantity,sum(sales.price*sales.qty) as total_revenue,sum(sales.discount*sales.price*sales.qty)/100 as total_discount ,product_details.segment_name
from sales,product_details
where product_details.product_id=sales.prod_id
group by product_details.segment_name
##10.. What is the top selling product for each segment?
with cte4 as(
select sum(sales.qty)as total_quantity,product_details.product_name as prod_name,product_details.segment_name
from sales,product_details
where product_details.product_id=sales.prod_id
group by product_details.segment_name,product_details.product_name 
order by segment_name)
select segment_name,prod_name,total_quantity,rank() over(partition by segment_name order by total_quantity desc) as rnk
from cte4
order by rnk
limit 4;
##11. What are the total quantity, revenue and discount for each category;
##we can use inner join also
select sum(qty) as total_quantity,sum(sales.price*sales.qty) as total_revenue,sum(sales.discount*sales.
qty*sales.price)/100 as total_discount ,product_details.category_name
from sales,product_details
where product_details.product_id=sales.prod_id
group by product_details.category_name;
##12What is the top selling product for each category
with cte5 as (
select sum(sales.price)as total_revenue,product_details.product_name as prod_name,product_details.category_name
from sales,product_details
where product_details.product_id=sales.prod_id
group by product_details.category_name,product_details.product_name
order by category_name)
select category_name,prod_name,total_revenue,first_value(prod_name)over (partition by category_name order by total_revenue desc) as top_selling_product
from cte5;