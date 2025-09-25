/*Production report 
========================================================
Purpose:
		- This report consolidates key product mertics and behaviour.
Highlights:
	1.Gather essential fields such as product name,category,subcategory,and cost.
	2.Segments products by revenue to identify high-Performance,mid range,or low performancers,
	3.Aggrigates product - level metrics:
		i.Total orders
		ii.Total sales
		iii.Total Quantity sold
		iv.Total Customers (Unique)
		v.lifespan (in months)
	4.calculates valuable KPIs:
		i.recency(months since last sales)
		ii.average order revenue (AOR)
		iii.Average Monthly revenue
============================================================
*/
----Base Query------
create view gold.Production_report as 
with Base_Production_Query as (
	select
		p.product_name,
		p.product_key,
		p.category,
		p.subcategory,
		p.cost,
		F.order_number,
		F.sales_amount,
		F.Quantity,
		F.customer_key,
		F.order_date
		from gold.fact_sales as F
		left join gold.dim_products as P
		on F.product_key = P.product_key
),
Product_aggrigation as(
 select
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	count(Distinct customer_key) as Customers_Unique ,
	count(order_number) as Total_orders,
	Sum(sales_amount) as total_sales,
	case when Sum(sales_amount) >5000 then 'High- Performance'
		 when Sum(sales_amount) between 3000 and 5000 then 'Mid-Range Performance'
		 else 'Low Performance'
	end as Revenue_Identifier,
	Sum(Quantity) as Total_Quantity_sold,
	Round(avg(cast(sales_amount as float)/nullif(Quantity,0)),1)as Avg_Selling_price,
	Max(Order_date) as last_order,
	DATEDIFF(month,Min(order_date),Max(Order_date)) as lifespan
	from Base_Production_Query
	group by product_key,
	product_name,
	category,
	subcategory,
	cost
)
select
product_key,
Product_name,
category,
subcategory,
cost,
Total_orders,
Total_sales,
revenue_identifier,
total_quantity_sold,
customers_unique,
lifespan,
last_order,
DATEDIFF(month,last_order,getdate()) as recency,
case when Total_orders = 0 then 0
	 else round(cast(total_sales*1.0/Total_orders as float),2)
end as Avg_Orer_Rrevenue,-- AOR--
case when lifespan = 0 then total_sales
	 else round(cast(total_sales*1.0/lifespan as float),2)
end as Avg_Monthly_Revenu
from Product_aggrigation

select * from gold.Production_report
