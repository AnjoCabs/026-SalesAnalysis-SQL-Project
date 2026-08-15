/*
"Mastering SQL is an essential skill for data analysts.
 This project uses real-world sales data to practice sales performance analysis,
 product and territory ranking, customer insights, trend analysis,
 and advanced business reporting using MySQL."
*/

USE salesandfinanceanalysis;

CREATE TABLE IF NOT EXISTS factTable (
	ProductKey INT NOT NULL,
	OrderDateKey INT NOT NULL,
	DueDateKey INT NOT NULL,
	ShipDateKey INT NOT NULL,
	CustomerKey INT NOT NULL,
	PromotionKey INT NOT NULL,
	CurrencyKey INT NOT NULL,
	SalesTerritoryKey INT NOT NULL,
	SalesOrderNumber VARCHAR (50) NOT NULL,
	SalesOrderLineNumber INT NOT NULL,
	RevisionNumber INT NOT NULL,
	OrderQuantity INT NOT NULL,
	UnitPrice DECIMAL(8,2) NOT NULL,
	ExtendedAmount DECIMAL(8,2) NOT NULL,
	UnitPriceDiscountPct INT NOT NULL,
	DiscountAmount DECIMAL(8,2) NOT NULL,
	ProductStandardCost DECIMAL(8,2) NOT NULL,
	TotalProductCost DECIMAL(8,2) NOT NULL,
	SalesAmount DECIMAL(8,2) NOT NULL,
	TaxAmt DECIMAL(8,2) NOT NULL,
	Freight DECIMAL(8,2) NOT NULL,
	OrderDate DATE NOT NULL,
	DueDate DATE NOT NULL,
	ShipDate DATE NOT NULL,
	PRIMARY KEY(SalesOrderNumber)
);

CREATE TABLE IF NOT EXISTS dimTerritory (
	SalesTerritoryKey INT NOT NULL,
	SalesTerritoryAlternateKey INT NOT NULL,
	SalesTerritoryRegion VARCHAR(255),
	SalesTerritoryCountry VARCHAR(255),
	SalesTerritoryGroup VARCHAR(255),
	PRIMARY KEY(SalesTerritoryKey)
);

LOAD DATA LOCAL INFILE 'C:/Users/billy/OneDrive/Desktop/Adventure work Excel Dashboard/dimTerritory.csv'
INTO TABLE dimTerritory
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE IF NOT EXISTS dimProduct (
	ProductKey INT NOT NULL,
	ProductAlternateKey VARCHAR(50) NOT NULL,
	EnglishProductName VARCHAR(50) NOT NULL,
	FinishedGoodsFlag VARCHAR(50) NOT NULL,
	Color VARCHAR(50),
	SafetyStockLevel INT,
	ReorderPoint INT, 
	SizeRange INT,
	DaysToManufacture INT,
	StartDate DATE,
	Status VARCHAR(50) NOT NULL,
	PRIMARY KEY(ProductKey)
);

CREATE TABLE IF NOT EXISTS dimGeography (
	GeographyKey INT NOT NULL,
	City VARCHAR(255),
	StateProvinceCode VARCHAR(255),
	StateProvinceName VARCHAR(255),
	CountryRegionCode VARCHAR(255),
	EnglishCountryRegionName VARCHAR(255),
	SpanishCountryRegionName VARCHAR(255),
	FrenchCountryRegionName VARCHAR(255),
	PostalCode INT NOT NULL,
	SalesTerritoryKey INT NOT NULL,
	IpAddressLocator VARCHAR(15),
	PRIMARY KEY(GeographyKey)
);

CREATE TABLE IF NOT EXISTS dimDate
(
	DateKey INT NOT NULL, 
	FullDateAlternateKey INT NOT NULL, 
	DayNumberOfWeek INT NOT NULL,
	EnglishDayNameOfWeek VARCHAR(15) NOT NULL,
	DayNumberOfMonth INT NOT NULL,
	DayNumberOfYear INT NOT NULL,
	WeekNumberOfYear INT NOT NULL,
	EnglishMonthName VARCHAR(15) NOT NULL,
	MonthNumberOfYear INT NOT NULL,
	CalendarQuarter INT NOT NULL,
	CalendarYear INT NOT NULL,
	CalendarSemester INT NOT NULL,
	FiscalQuarter INT NOT NULL,
	FiscalYear INT NOT NULL,
	FiscalSemester INT NOT NULL,
	PRIMARY KEY(DateKey)
);

CREATE TABLE IF NOT EXISTS dimCustomer (
	CustomerKey INT NOT NULL,
	GeographyKey INT NOT NULL,
	CustomerAlternateKey VARCHAR(50),
	FirstName VARCHAR(50),
	MiddleName VARCHAR(50),
	LastName VARCHAR(50),
	BirthDate DATE,
	MaritalStatus VARCHAR(50),
	Suffix VARCHAR(50),
	Gender VARCHAR(50),
	EmailAddress VARCHAR(50),
	YearlyIncome DECIMAL(8,2),
	TotalChildren INT,
	NumberChildrenAtHome INT, 
	EnglishEducation VARCHAR(50),
	EnglishOccupation VARCHAR(50),
	HouseOwnerFlag INT,
	NumberCarsOwned INT, 
	Phone VARCHAR(50),
	DateFirstPurchase DATE,
	CommuteDistance VARCHAR(50),
	PRIMARY KEY(CustomerKey)
);

-- 1. Calculate the total SalesAmount from factTable.
SELECT  
	SUM(SalesAmount) AS totalSalesAmount
FROM facttable;

-- 2. How many unique SalesOrderNumber values are in factTable?
SELECT 
	COUNT(DISTINCT SalesOrderNumber) AS totalUniqueSalesOrderNumber
FROM facttable;

-- 3. Calculate the total OrderQuantity.
SELECT 
	SUM(OrderQuantity) AS totalOrderQuantity
FROM facttable;

-- 4. Calculate the average sales amount per order.
SELECT 
	ROUND(
		AVG(SalesAmount),2) AS avgSalesAmount
FROM factTable;

-- 5. Calculate the total Freight cost.
SELECT 
	SUM(Freight) AS totalFreightCost
FROM factTable;

-- 6. Calculate the total TaxAmt.
SELECT 
	SUM(TaxAmt) AS totalTaxAmount
FROM facttable;

-- 7. Calculate the total DiscountAmount.
SELECT 
	SUM(DiscountAmount) AS totalADiscountAmount
FROM factTable;

-- 8. Calculate the total TotalProductCost.
SELECT 
	SUM(TotalProductCost) AS summaryTotalProductCost
FROM factTable;

-- 9. Calculate total profit using.
SELECT 
	SUM(SalesAmount - TotalProductCost) AS totalProfit
FROM factTable;

-- 10. Calculate the overall profit margin.
SELECT 
    (SUM(SalesAmount - TotalProductCost) / SUM(SalesAmount)) * 100 AS overallProfitMargin
FROM factTable;

-- 11. calculate total sales for each CalendarYear.    
SELECT
	YEAR(OrderDate) AS year_,
    SUM(SalesAmount) AS totalSalesAmount
FROM factTable
GROUP BY year_;

-- 12. Calculate total sales for each month.
SELECT
    MONTH(OrderDate) AS monthNum,
    YEAR(OrderDate) AS year_,
    MONTHNAME(OrderDate) AS monthName_,
    SUM(SalesAmount) AS totalSalesAmount
FROM factTable
GROUP BY 1, 2, 3
ORDER BY year_, monthNum;

-- 13. Join factTable with dimTerritory and calculate sales by territory. 
SELECT 
	dt.SalesTerritoryCountry,
    SUM(SalesAmount) AS totalSalesAmount
FROM factTable ft
JOIN dimterritory dt
	ON ft.SalesTerritoryKey = dt.SalesTerritoryKey
GROUP BY dt.SalesTerritoryCountry
ORDER BY totalSalesAmount DESC;

-- 14. Join factTable with dimProduct and calculate total quantity sold for every product.
SELECT 
	ft.ProductKey,
    dp.EnglishProductName,
    SUM(SalesAmount) AS totalSalesAmount
FROM factTable ft
JOIN dimproduct dp
	ON ft.ProductKey = dp.ProductKey
GROUP BY ft.ProductKey, dp.EnglishProductName
ORDER BY totalSalesAmount DESC;

-- 15. Calculate profit for every product.
SELECT 
	ft.ProductKey,
    dp.EnglishProductName,
    SUM(SalesAmount - TotalProductCost) AS totalProfit
FROM factTable ft
JOIN dimproduct dp
	ON ft.ProductKey = dp.ProductKey
GROUP BY ft.ProductKey, dp.EnglishProductName
ORDER BY totalProfit DESC;

-- 16. Calculate the number of orders placed by each customer.
SELECT 
    dc.CustomerKey,
    CONCAT_WS(' ', dc.FirstName, dc.MiddleName, dc.LastName) AS fullName,
    COUNT(DISTINCT ft.SalesOrderNumber) AS totalOrders
FROM dimCustomer dc
JOIN factTable ft
    ON dc.CustomerKey = ft.CustomerKey
GROUP BY 
    dc.CustomerKey,
    dc.FirstName,
    dc.MiddleName,
    dc.LastName
ORDER BY 
    totalOrders DESC;
    
-- 17. Calculate total sales generated by every customer.
SELECT 
    dc.CustomerKey,
    CONCAT_WS(' ', dc.FirstName, dc.MiddleName, dc.LastName) AS fullName,
    SUM(SalesAmount) AS totalSalesAmount
FROM dimCustomer dc
JOIN factTable ft
    ON dc.CustomerKey = ft.CustomerKey
GROUP BY 
    dc.CustomerKey,
    dc.FirstName,
    dc.MiddleName,
    dc.LastName
ORDER BY 
    totalSalesAmount DESC;
    
-- 18. Find the 10 products with the highest total sales.
 WITH RankedProducts AS (
    SELECT 
        ft.ProductKey,
        dp.EnglishProductName,
        SUM(ft.SalesAmount) AS totalSalesAmount,
        DENSE_RANK() OVER (ORDER BY SUM(ft.SalesAmount) DESC) AS salesRank
    FROM facttable ft
    JOIN dimproduct dp 
        ON ft.ProductKey = dp.ProductKey
    GROUP BY 
        ft.ProductKey, 
        dp.EnglishProductName
)
SELECT 
    ProductKey,
    EnglishProductName,
    totalSalesAmount
FROM RankedProducts
WHERE salesRank <= 10
ORDER BY salesRank;   
   
 -- 19. Find the 10 most profitable products.
WITH rankedProfit AS (
    SELECT 
        ft.ProductKey,
        dp.EnglishProductName,
        SUM(ft.SalesAmount) AS totalSalesAmount,
        SUM(ft.ProductStandardCost) AS totalProductCost,
        SUM(ft.SalesAmount - ft.ProductStandardCost) AS totalProfitAmount,
        DENSE_RANK() OVER (
            ORDER BY SUM(ft.SalesAmount - ft.ProductStandardCost) DESC
        ) AS profitRank
    FROM facttable ft
    JOIN dimproduct dp 
        ON ft.ProductKey = dp.ProductKey
    GROUP BY 
        ft.ProductKey, 
        dp.EnglishProductName
)
SELECT 
    ProductKey,
    EnglishProductName,
    totalProfitAmount,
    profitRank
FROM rankedProfit
WHERE profitRank <= 10
ORDER BY profitRank;

-- 20. Find customers who placed more than 10 orders.
SELECT 
    dc.CustomerKey,
    CONCAT_WS(' ', dc.FirstName, dc.MiddleName, dc.LastName) AS fullName,
    COUNT(DISTINCT ft.SalesOrderNumber) AS totalOrders
FROM dimCustomer dc
JOIN factTable ft
    ON dc.CustomerKey = ft.CustomerKey
GROUP BY 
    dc.CustomerKey,
    dc.FirstName,
    dc.MiddleName,
    dc.LastName
HAVING 
    COUNT(DISTINCT ft.SalesOrderNumber) > 10
ORDER BY 
    totalOrders DESC;
    
-- 21. Customers Generating More Than $10,000
SELECT 
    dc.CustomerKey,
    CONCAT_WS(' ', dc.FirstName, dc.MiddleName, dc.LastName) AS fullName,
    SUM(SalesAmount) AS totalSalesAmount
FROM dimCustomer dc
JOIN factTable ft
    ON dc.CustomerKey = ft.CustomerKey
GROUP BY 
    dc.CustomerKey,
    dc.FirstName,
    dc.MiddleName,
    dc.LastName
HAVING 
    totalSalesAmount > 10000
ORDER BY 
    totalSalesAmount DESC;    

-- 22. Products Selling More Than 1,000 Units
SELECT 
	ft.ProductKey,
    EnglishProductName,
    SUM(OrderQuantity) AS totalOrderQuantity
FROM facttable ft
JOIN dimproduct dp
	ON ft.productkey = dp.ProductKey
GROUP BY ft.ProductKey, EnglishProductName
HAVING totalOrderQuantity > 1000
ORDER BY totalOrderQuantity DESC;

-- 23. Calculate each territory's percentage contribution to total company sales.
SELECT
    dt.SalesTerritoryRegion,
    ROUND(SUM(ft.SalesAmount), 2) AS totalSalesAmount,
    ROUND(
        SUM(ft.SalesAmount) /
        (SELECT SUM(SalesAmount) FROM factTable) * 100,
        2
    ) AS salesPercentage
FROM factTable ft
JOIN dimTerritory dt
    ON ft.SalesTerritoryKey = dt.SalesTerritoryKey
GROUP BY dt.SalesTerritoryRegion
ORDER BY totalSalesAmount DESC;

-- 24. For each SalesTerritoryRegion, find the product with the highest sales.
WITH productTerritorySales AS (
    SELECT
        dt.SalesTerritoryRegion,
        dp.EnglishProductName,
        SUM(ft.SalesAmount) AS totalSalesAmount
    FROM factTable ft
    JOIN dimTerritory dt
        ON ft.SalesTerritoryKey = dt.SalesTerritoryKey
    JOIN dimProduct dp
        ON ft.ProductKey = dp.ProductKey
    GROUP BY
        dt.SalesTerritoryRegion,
        dp.EnglishProductName
),
rankedProducts AS (
    SELECT
        SalesTerritoryRegion,
        EnglishProductName,
        totalSalesAmount,
        ROW_NUMBER() OVER (
            PARTITION BY SalesTerritoryRegion
            ORDER BY totalSalesAmount DESC
        ) AS productRank
    FROM productTerritorySales
)
SELECT
    SalesTerritoryRegion,
    EnglishProductName,
    ROUND(totalSalesAmount, 2) AS totalSalesAmount
FROM rankedProducts
WHERE ProductRank = 1
ORDER BY totalSalesAmount DESC;

-- 25. Calculate profit for every product and classify each product.
SELECT 
	ft.ProductKey,
    EnglishProductName,
    SUM(SalesAmount) AS totalSalesAmount,
	    CASE 
		WHEN NTILE(3) OVER (ORDER BY SUM(SalesAmount)) = 1
			THEN "Low Profit"
		WHEN NTILE(3) OVER (ORDER BY SUM(SalesAmount)) = 2
			THEN "Medium Profit"
		ELSE "High Profit" END AS productClassification
FROM facttable ft
JOIN dimproduct dp
	ON ft.productkey = dp.productkey
GROUP BY ft.ProductKey, EnglishProductName
ORDER BY totalSalesAmount DESC;

/*
"Mastering SQL is an essential skill for data analysts.
 This project uses real-world sales data to practice sales performance analysis,
 product and territory ranking, customer insights, trend analysis,
 and advanced business reporting using MySQL."
*/
