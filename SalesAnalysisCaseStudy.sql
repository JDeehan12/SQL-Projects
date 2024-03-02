-- World Wide Importers Scenario Case Study

-- In this case study I have joined World Wide Importers as a Business Intelligence Analyst
-- I have been tasked with helping the product and marketing team by evaluating performance of specific products and salsepersons. 


-- Query 1: Retrieve the maximum fiscal year from the dimDate table
SELECT MAX([Fiscal Year]) AS MaxFiscalMonth
FROM dimDate

-- Query 2: Retrieve total sales excluding tax for each fiscal year
SELECT d.[Fiscal Year] AS FiscalYear,
        SUM(s.[Total Excluding Tax]) AS TotalSalesExcludingTax
FROM factSale AS s
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
GROUP BY d.[Fiscal Year]
ORDER BY d.[Fiscal Year] ASC

-- Query 3: Retrieve distinct fiscal years from the dimDate table, ordered by fiscal year
SELECT d.[Fiscal Year] AS FiscalYear
FROM dimDate as d
GROUP BY d.[Fiscal Year]
ORDER BY d.[Fiscal Year] AS

-- Query 4: Retrieve total sales, quantity sold, and profit for each fiscal year, ordered by fiscal year in descending order
SELECT 
	d.[Fiscal Year] AS FiscalYear,
	SUM(s.[Total Excluding Tax]) AS TotalSalesExcludingTax,
	SUM(s.[Quantity]) AS QuantitySold,
	SUM(s.[Profit]) AS Profit

FROM factSale AS s
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
		
GROUP BY d.[Fiscal Year]

ORDER BY d.[Fiscal Year] DESC

-- Query 5: Retrieve sales metrics grouped by fiscal year and fiscal month, ordered by fiscal year and fiscal month number in descending order
SELECT 
	d.[Fiscal Year] FiscalYear,
    d.[Fiscal Month Label] AS FiscalYearMonth,
    d.[Fiscal Month Number] AS FiscalMonthNumber,
	SUM(s.[Total Excluding Tax]) AS TotalSalesExcludingTax,
	SUM(s.[Quantity]) AS QuantitySold,
	SUM(s.[Profit]) AS Profit

FROM factSale AS s
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
		
GROUP BY d.[Fiscal Year],d.[Fiscal Month Label],d.[Fiscal Month Number]

ORDER BY FiscalYear DESC, FiscalMonthNumber DESC

-- Query 6: Retrieve total sales excluding tax for the fiscal year 2016
SELECT 
	SUM(s.[Total Excluding Tax]) AS TotalSalesExcludingTax,

FROM factSale AS s
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
	
WHERE [Fiscal Year] = 2016 

-- Query 7: Retrieve top 10 products based on year-to-date total sales excluding tax for the fiscal year 2016
SELECT TOP 10
    p.[Stock Item] AS Product,
	SUM(s.[Total Excluding Tax]) AS YTDTotalSalesExcludingTax

FROM factSale AS s
        INNER JOIN dimStockItem AS p
        ON s.[Stock Item Key]=p.[Stock Item Key]
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
	
WHERE [Fiscal Year] = 2016
GROUP BY p.[Stock Item]
ORDER BY YTDTotalSalesExcludingTax DESC

-- Query 8: Retrieve top 10 salespersons and their associated products based on year-to-date total sales excluding tax for the fiscal year 2016
SELECT TOP 10
    e.Employee AS SalesPerson,
    p.[Stock Item] AS Product,
	SUM(s.[Total Excluding Tax]) AS YTDTotalSalesExcludingTax

FROM factSale AS s
        INNER JOIN dimStockItem AS p
        ON s.[Stock Item Key]=p.[Stock Item Key]
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
        INNER JOIN dimEmployee AS e
        ON s.[Salesperson Key] = e.[Employee Key]
	
WHERE [Fiscal Year] = 2016
GROUP BY p.[Stock Item], e.Employee
ORDER BY YTDTotalSalesExcludingTax DESC

-- Query 9: Retrieve top 10 salespersons and their associated products with year-to-date total sales excluding tax and percent of total sales for the latest fiscal year available in the data
SELECT TOP 10
    e.Employee AS SalesPerson,
    p.[Stock Item] AS Product,
	SUM(s.[Total Excluding Tax]) AS YTDTotalSalesExcludingTax,
    FORMAT(CAST(SUM(s.[Total Excluding Tax]) / (SELECT SUM(s.[Total Excluding Tax])
                                                FROM factSale AS s
                                                INNER JOIN dimDate as d
                                                ON s.[Invoice Date Key] =d.[Date]
                                                WHERE d.[Fiscal Year] =2016)
            as decimal (8,6)), 'P4') AS PercentOfSalesYTD

FROM factSale AS s
        INNER JOIN dimStockItem AS p
        ON s.[Stock Item Key]=p.[Stock Item Key]
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
        INNER JOIN dimEmployee AS e
        ON s.[Salesperson Key] = e.[Employee Key]
	
WHERE [Fiscal Year] = 2016
GROUP BY p.[Stock Item], e.Employee
ORDER BY YTDTotalSalesExcludingTax DESC

-- Query 10: Same as above query using dynamic fiscal date
(SELECT MAX([Fiscal Year]) FROM factSale AS s INNER JOIN dimDate AS d ON s.[Invoice Date Key]=d.[Date])

SELECT TOP 10
    e.Employee AS SalesPerson,
    p.[Stock Item] AS Product,
	SUM(s.[Total Excluding Tax]) AS YTDTotalSalesExcludingTax,
    FORMAT(CAST(SUM(s.[Total Excluding Tax]) / (SELECT SUM(s.[Total Excluding Tax])
                                                FROM factSale AS s
                                                INNER JOIN dimDate as d
                                                ON s.[Invoice Date Key] =d.[Date]
                                                WHERE d.[Fiscal Year] =(SELECT MAX([Fiscal Year]) FROM factSale AS s INNER JOIN dimDate AS d ON s.[Invoice Date Key]=d.[Date])
)
            as decimal (8,6)), 'P4') AS PercentOfSalesYTD

FROM factSale AS s
        INNER JOIN dimStockItem AS p
        ON s.[Stock Item Key]=p.[Stock Item Key]
        INNER JOIN dimDate as d
        ON s.[Invoice Date Key] = d.[Date]
        INNER JOIN dimEmployee AS e
        ON s.[Salesperson Key] = e.[Employee Key]
	
WHERE [Fiscal Year] = (SELECT MAX([Fiscal Year]) FROM factSale AS s INNER JOIN dimDate AS d ON s.[Invoice Date Key]=d.[Date])
GROUP BY p.[Stock Item], e.Employee
ORDER BY YTDTotalSalesExcludingTax DESC
