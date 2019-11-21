WITH baseline AS (
SELECT 
*,
LEAD (order_count, 1) OVER (PARTITION BY productid ORDER BY year DESC, month DESC) AS previous_month_order
FROM 
	(SELECT 
		productid,
		COUNT (DISTINCT orderid) AS order_count,
		month,
		year
		FROM 
			(SELECT
			o.orderid,
			od.productid,
			od.unitprice,
			od.quantity,
			DATE_PART ('month', o.orderdate) AS month,
			DATE_PART ('year', o.orderdate) AS year
			FROM orders o 
			INNER JOIN orderdetails od ON o.orderid = od.orderid
			ORDER BY orderdate DESC) AS monthly_orders
		GROUP BY year, month, productid
		ORDER BY year DESC, month DESC) AS base
)

SELECT 
p.productname,
bl.productid,
bl.order_count,
bl.month,
bl.year,
bl.previous_month_order,
COALESCE((order_count-previous_month_order),0) AS diff
FROM baseline bl
INNER JOIN products p ON p.productid = bl.productid