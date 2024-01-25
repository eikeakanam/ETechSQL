

-- What is the Sales, and Profits trend over the years
SELECT 
    YEAR([Order Date]) AS YEAR_,
	FORMAT(SUM(Sales), 'C', 'en-GB') AS Total_Sales,
	FORMAT(SUM(CASE WHEN order_status = 'Completed' THEN Sales END), 'C', 'en-GB') AS Net_Sales,
	FORMAT(SUM(CASE WHEN order_status = 'Returned' THEN Sales END), 'C', 'en-GB') AS Returned_Sales,
	FORMAT(SUM(Profit), 'C', 'en-GB') AS Total_Profit,
	FORMAT(SUM(CASE WHEN order_status = 'Completed' THEN Profit END), 'C', 'en-GB') AS Net_Profit,
	FORMAT(SUM(CASE WHEN order_status = 'Returned' THEN Profit END), 'C', 'en-GB') AS Returned_Profit,
	COUNT([Row ID]) AS Total_Orders,
	COUNT(CASE WHEN order_status = 'Completed' THEN [Order ID] END) AS Net_Orders,
	COUNT(CASE WHEN order_status = 'Returned' THEN [Order ID] END) AS Returned_Orders
FROM orders
-- WHERE order_status = 'Completed'
GROUP BY YEAR([Order Date])
ORDER BY YEAR_ DESC;


-- Sales trend by regions for completed orders
SELECT 
    o.Region,
    CONCAT(u.[First Name], ' ', u.[Last Name]) AS [Regional Manager],
    FORMAT(SUM(o.Sales), 'C', 'en-GB') AS Net_Sales,
    FORMAT(SUM(o.Profit), 'C', 'en-GB') AS Net_Profit,
    COUNT(o.[Order ID]) AS Total_Orders
FROM 
    orders o
LEFT JOIN 
    users u ON o.Region = u.Region
WHERE 
    o.order_status = 'Completed'
GROUP BY 
    o.Region, CONCAT(u.[First Name], ' ', u.[Last Name])
ORDER BY 
    Net_Sales DESC;



-- Rate of fulfilment and returns of orders by region
SELECT
    Region,
    COUNT(CASE WHEN order_status = 'Completed' THEN [Order ID] END) AS Completed_Orders,
	COUNT(CASE WHEN order_status = 'Returned' THEN [Order ID] END) AS Returned_Orders,
    COUNT([Order ID]) AS TotalOrders,
    FORMAT((COUNT(CASE WHEN order_status = 'Completed' THEN [Order ID] END) * 
		1.0 / COUNT([Order ID])), '0.00%') AS Rate_of_Fulfilment,
	FORMAT((COUNT(CASE WHEN order_status = 'Returned' THEN [Order ID] END) * 
		1.0 / COUNT([Order ID])), '0.00%') AS Rate_of_Return
FROM
    orders
GROUP BY
    Region



-- Highest Products Sold and their product category
SELECT TOP 10 
	COUNT(*) AS Total_Orders, [Product Name],  [Product Category]
FROM orders
GROUP BY [Product Name], [Product Category] 
ORDER BY Total_Orders DESC;



-- Seasonal trend with Monthly Sales and Returns Per Month
SELECT
    DATENAME(MONTH, [Order Date]) AS OrderMonth,
    FORMAT(SUM(o.Sales), 'C', 'en-GB') AS TotalSales,
    SUM(CASE WHEN Status = 'Returned' THEN 1 ELSE 0 END) AS TotalReturns,
	COUNT(o.[Order ID]) - SUM(CASE WHEN Status = 'Returned' THEN 1 ELSE 0 END) 
		AS Completed_Orders
FROM
    Orders o
    LEFT JOIN Returns r ON o.[Order ID] = r.[Order ID]
GROUP BY
    DATENAME(MONTH, [Order Date])
ORDER BY
	SUM(o.Sales) DESC

-- MIN(DATEPART(MONTH, [Order Date])), ;



WITH AnnualSales AS (
    SELECT
        YEAR([Order Date]) AS OrderYear,
        SUM(Sales) AS TotalSales
    FROM
        Orders
    GROUP BY
        YEAR([Order Date])
)
SELECT
    a1.OrderYear,
    a1.TotalSales AS CurrentYearSales,
    a2.TotalSales AS PreviousYearSales,
    (a1.TotalSales - a2.TotalSales) / a2.TotalSales * 100 AS AnnualSalesIncreasePercentage
FROM
    AnnualSales a1
JOIN
    AnnualSales a2 ON a1.OrderYear = a2.OrderYear + 1
ORDER BY
    a1.OrderYear DESC;


-- Most active customer segment
SELECT 
	COUNT(*) AS Total_Orders, [Customer Segment]
FROM orders
WHERE order_status = 'Completed'
GROUP BY [Customer Segment]
ORDER BY Total_Orders DESC;


-- Return patterns based on customer segments.
SELECT
    o.[Customer Segment],
    COUNT(r.[Order ID]) AS Total_Returns
FROM
    Orders o
LEFT JOIN
    Returns r ON o.[Order ID] = r.[Order ID]
GROUP BY
    o.[Customer Segment]
ORDER BY Total_Returns DESC;


-- Most profitable products 
SELECT TOP 5 
	[Product Name], [Product Category],
    FORMAT(SUM([Profit]), 'C', 'en-GB') AS Total_Profit
FROM Orders
GROUP BY 
	[Product Name], [Product Category]
ORDER BY
     SUM([Profit]) DESC



-- Impact of discount levels on sales and profits (E.g. Most Profitable product)
SELECT
	Discount, [Product Name],
	COUNT([Row ID]) AS Quantity_Sold,
	FORMAT(AVG([Sales]), 'C', 'en-GB') AS Total_Sales,
	FORMAT(AVG([Profit]), 'C', 'en-GB') AS Total_Profit
FROM orders
WHERE order_status = 'Completed' AND [Product Name] = 'Global Troy™ Executive Leather Low-Back Tilter'
GROUP BY Discount, [Product Name]
ORDER BY COUNT([Row ID]) DESC


-- Average order processing days and shipping costs per ship mode
SELECT 
	AVG(DATEDIFF(DAY, [Order Date], [Ship Date])) AS Avg_Order_Processing_Days,
	FORMAT(AVG([Shipping Cost]), 'C', 'en-GB') AS Avg_Shipping_Cost,
	[Ship Mode],
	COUNT([Row ID]) AS Total_Orders
FROM orders
GROUP BY [Ship Mode]
ORDER BY AVG([Shipping Cost]) DESC;


