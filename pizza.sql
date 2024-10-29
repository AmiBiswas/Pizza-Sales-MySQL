create database pizza;
use pizza;
select * from orders;
select * from order_details;
select * from  pizza_types;
select * from pizzas;

/*=----Advanced:=------*/
/*1.Calculate the percentage contribution of each pizza categories to total revenue.*/

/*SELECT 
    pizza_type_id,
    SUM(price) AS total_price,
    ROUND((SUM(p.price*od.quantity) / (SELECT SUM(p.price*od.quantity) FROM pizzas)) * 100, 1) AS percentage_of_total
FROM pizzas as p join order_details od on od.pizza_id=p.pizza_id
GROUP BY pizza_type_id;*/

with temp as(
SELECT 
    pt.category, 
    /*SUM(p.price * od.quantity) AS total_price,*/ 
    ROUND((SUM(p.price * od.quantity) / (SELECT SUM(p.price * od.quantity) FROM pizzas p 
    JOIN order_details od ON p.pizza_id = od.pizza_id)) * 100, 1) AS percentage_of_total 
FROM 
     order_details od 
JOIN 
    pizzas p
ON 
    p.pizza_id = od.pizza_id 
    join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
GROUP BY 1)
select category, concat(percentage_of_total ,"%") as '% contribution ' from temp;
		


/* 2..Analyze the cumulative revenue generated over time.*/
with temp as
(
select o.date,
sum(p.price*od.quantity) as revenue
from pizzas as p join order_details as od on p.pizza_id=od.pizza_id
join orders as o on o.order_id=od.order_id
group by 1)
select date,sum(revenue) over ( order by date) from temp;
;

select o.date, 
       sum(p.price*od.quantity) over (order by date desc) cumulative_revenue 
from pizzas as p
join order_details as od on p.pizza_id=od.pizza_id
join orders as o on o.order_id=od.order_id
group by o.date, p.price;


/*3 Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/

with temp2 as
(with temp as
(SELECT pt.pizza_type_id, pt.name, pt.category,   sum(p.price*od.quantity)  as TR
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY 1,2,3 order by tr desc)
select name, category,row_number() Over (partition by category  Order By tr DESC) as myRank 
from temp)
select * from temp2 where myRank=1
;



/*   Intermediate:
1..Join the necessary tables to find the total quantity of each pizza category ordered.*/

SELECT pt.category,sum(od.quantity) as cnt
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
group by pt.category
order by cnt desc;

/* 2  Determine the distribution of orders by hour of the day.*/
select hour(time) as hr,count(order_id) cnt  from orders
group by hr
order by cnt desc;

/*  3	Join relevant tables to find the category-wise distribution of pizzas.*/
SELECT category,count(pizza_type_id) as cnt
FROM pizza_types group by category with rollup;



/* 4.  Group the orders by date and calculate the average number of pizzas ordered per day. */

WITH temp AS (
    SELECT o.date, SUM(od.quantity) AS total_quantity
    FROM orders AS o
    JOIN order_details AS od ON od.order_id = o.order_id
    GROUP BY o.date
)
SELECT date, AVG(total_quantity) AS avg_quantity
FROM temp
GROUP BY date;

/*5  Determine the top 3 most ordered pizza types based on revenue.*/
select pizza_type_id , sum(p.price*od.quantity)  as total_revenue from pizzas as p 
join  order_details AS od ON od.pizza_id = p.pizza_id
group by pizza_type_id 
order by total_revenue desc
limit 3;


