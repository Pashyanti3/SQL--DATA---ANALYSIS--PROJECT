------------Customer Report-----------------
/*purpose :  - This report consolidates key customer metrics and behaviors
Highlights:
	1.Gather essential fields such as names,ages,and transaction details,
	2.Segments customers into categories (VIP,Regular,New) and age groups,
	3.Aggregates customers - level Matrics:
		- total orders
		- total Sales
		- total quantity purchase
		- total products
		- lifespan (in months)
	4.calculates values KPI:
		-Recency (Months since last order)
		-Average order value
		-Average monthly spend
	----------------------------------------------------------*/
---Base Query : Retrive core colums from the tables----
create view gold.report_customers as 
with Base_Query as (
	Select 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	f.price,
	D.Customer_key,
	D.customer_number,
	CONCAT(D.first_name,' ',D.last_name) as Customer_name,
	datediff(YEAR,D.birthdate,GETDATE()) as Age 
	from gold.fact_sales as f
	left join gold.dim_customers as D
	on f.customer_key = d.customer_key
	),Customer_Aggrigation as 
(select ---Aggrigation Query---
	customer_key,
	Customer_name,
	customer_number,
	Age ,
	count(Distinct order_number) as total_orders,
	sum(sales_amount) as Total_sales,
	Sum(quantity) as Total_quantity,
	Count(distinct product_key) as total_products,
	max(Order_date) as last_order,
	datediff(month,min(order_date),max(order_date))as lifespan
	from Base_Query
	group by 
	customer_key,
	Customer_name,
	customer_number,
	Age
 )
 select 
	customer_key,
	Customer_name,
	customer_number,
	Age,
	case when Age<20 then 'Under 20'
		 when Age between 20 and 29 then 'Age : 20-29'
		 when Age between 30 and 39 then 'Age : 30-39'
		 when Age between 40 and 49 then 'Age : 40-49'
		 else 'Above 50'
	End as Age_Grop,
	last_order,
	DATEDIFF(MONTH,last_order,GETDATE()) as Recency,
	total_orders,
	Total_quantity,
	Total_sales,
	total_products,
	lifespan,
	case when lifespan >= 12 and Total_sales>5000 then 'VIP'
			 when lifespan >= 12 and Total_sales<5000 then 'Regular'
			 else 'New'
		End as Cust_segment,
---Compute average order value------
case when total_orders = 0 then 0
	 else Total_sales/total_orders
end as avg_total_values,
----compute Avg Monthly spend-------
case when lifespan = 0 then Total_sales
	 else Total_sales/lifespan
end as avg_Monthly_sales
from Customer_Aggrigation
--- To check view----
select * from gold.report_customers
