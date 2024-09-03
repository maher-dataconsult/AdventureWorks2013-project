-------------------------------------------------------------------------------------------
/* Used DATABASE:
https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak
*/
-------------------------------------------------------------------------------------------
--Importing the Database
-- Step 1: see the of List the logical file names contained in the first backup set
RESTORE FILELISTONLY
FROM DISK = 'C:\Users\Maher\Downloads\AdventureWorks2022\AdventureWorks2022.bak'
WITH FILE = 1;

-- Step 2: Restore the database from the second backup set
-- FILE = 1 specifies that the first backup set in the file should be used
-- MOVE specifies the new physical file locations for the data and log files
-- NOUNLOAD specifies that the tape drive is not to be unloaded (usually not needed for disk backups)
-- REPLACE specifies that the existing database should be overwritten
RESTORE DATABASE [AdventureWorks2022]
FROM DISK = 'C:\Users\Maher\Downloads\AdventureWorks2022\AdventureWorks2022.bak'
WITH FILE = 1,
MOVE 'AdventureWorks2022' TO 'D:\x\SQLserver\MSSQL16.MSSQLSERVER\MSSQL\DATA\AdventureWorks2022.mdf',
MOVE 'AdventureWorks2022_Log' TO 'D:\x\SQLserver\MSSQL16.MSSQLSERVER\MSSQL\Log\AdventureWorks2022.ldf',
NOUNLOAD,
REPLACE;

-------------------------------------------------------------------------------------------
--Selecting the Database
USE AdventureWorks2022

--What Tables in Production Schema ?? 
--and How Many BaseTables ??
SELECT TABLE_NAME
		,COUNT(TABLE_NAME) over() TablesCount
FROM information_schema.tables
WHERE TABLE_SCHEMA='Production'
	AND TABLE_TYPE='BASE TABLE'
	
--Columns Details and Count in every Production schema Table
SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION as Position
		,DATA_TYPE, IS_NULLABLE as [NULLABLE?]
		,COUNT (TABLE_NAME) OVER (PARTITION by TABLE_NAME)
		AS ColumnsCount
FROM information_schema.columns
WHERE table_schema = 'Production'
ORDER BY TABLE_NAME, ORDINAL_POSITION

-------------------------------------------------------------------------------------------
--Data wrangling
--Checking Nulls / Missing Values (in WorkOrder table as example) :
SELECT *
FROM production.WorkOrder
WHERE OrderQty IS NULL
   OR ScrappedQty IS NULL
   OR StartDate IS NULL
   OR EndDate IS NULL;
   
--Checking if there any Duplicates (in WorkOrder table as example) :
SELECT WorkOrderID, 
		COUNT(*) DupliCount
FROM production.WorkOrder
GROUP BY WorkOrderID
HAVING COUNT(*) > 1;

--Checking if there are Outliers potential Using Zscore 
--(on OrderQty in WorkOrder table as example) :
----1)) Compute mean and standard deviation
WITH Stats AS (
    SELECT 
        AVG(OrderQty) AS MeanQty,
        STDEV(OrderQty) AS StdDevQty
    FROM production.WorkOrder
)
----2)) Select the potentials outliers
SELECT WorkOrderID,
    	ProductID,
    	StartDate,
    	OrderQty,
    	(OrderQty - Stats.MeanQty) / Stats.StdDevQty AS ZScore
FROM production.WorkOrder
CROSS JOIN Stats
WHERE YEAR(StartDate) IN (2012, 2013)
    	AND (OrderQty > Stats.MeanQty + 3 * Stats.StdDevQty
         OR OrderQty < Stats.MeanQty - 3 * Stats.StdDevQty);
----3) Investigate the Outliers potentials

-------------------------------------------------------------------------------------------
/* Analytical Goals & Target KPIs AND Its Formulas:
1) Production Efficiency and Performance Metrics:
	1- Production Schedule Adherence = Actual Production Duration - Scheduled Production Duration (for all orders)
	2- Throughput Rate = Total Units Produced / Total Production Time
	3- Cost of Poor Quality (COPQ) = Scrap Cost / Total Production Cost * 100
	4- Setup Time Ratio = Total Setup Time / Total Production Time * 100
	5- Production Efficiency Rate = (Actual Production Time / Planned Production Time) * 100
	6- Scrap Rate = (Quantity of Scrapped Items / Total Quantity Produced) * 100
	7- Manufacturing Cycle Time = Average(ActualEndDate - ActualStartDate) for all WorkOrders 
2) Inventory Metric:
	8- Inventory Accuracy = (Total Correct Inventory Counts / Total Inventory Counts) * 100
3) Delivery Performance:
	9- On-Time Delivery Rate = Percentage of orders delivered on or before the due date
*/
  
-------------------------------------------------------------------------------------------
--1) Production Efficiency and Performance Metrics:
---1- Production Schedule Adherence = Actual Production Duration - Scheduled Production Duration (for all orders)
WITH src AS (
	SELECT YEAR(ScheduledStartDate) AS Year,
			WorkOrderID,ProductID,
			AVG(DATEDIFF(DAY,ScheduledStartDate,ScheduledEndDate)) Planned,
			AVG(DATEDIFF(DAY,ActualStartDate,ActualEndDate)) Actual,
			(AVG(DATEDIFF(DAY,ScheduledStartDate,ScheduledEndDate))
				-AVG(DATEDIFF(DAY,ActualStartDate,ActualEndDate))) as diff --Planned - Actual
	FROM production.WorkOrderRouting
	WHERE YEAR(ScheduledStartDate) in (2012,2013)
	GROUP BY YEAR(ScheduledStartDate), WorkOrderID, ProductID
)
SELECT YEAR,
    COUNT(src.WorkOrderID) TotalWorkOrders,
    COUNT(CASE WHEN diff=0 THEN 1 ELSE null END) AS OnTimeWorkOrders, -------Planned = Actual
	COUNT(CASE WHEN diff>0 THEN 1 ELSE null END) AS EarlyCompletionWorkOrders, --Planned > Actual
    COUNT(CASE WHEN diff<0 THEN 1 ELSE null END) AS OverdueWorkOrders, ----Planned < Actual
 	COUNT(CASE WHEN diff<0 THEN 1 ELSE null END)*100/COUNT(src.WorkOrderID) AS [%% OverdueOrdersPercentage %%]
FROM src
GROUP BY YEAR
ORDER BY YEAR DESC;

-------------------------------------------------------------------------------------------
---2- Throughput Rate = Total Units Produced / Total Production Time
SELECT YEAR(wo.StartDate) AS Year,
    CAST(SUM(wor.ActualResourceHrs) AS INT) ActualResourceHrs,
	SUM(wo.OrderQty) TotalOrdersQty,
    SUM(wo.OrderQty) / SUM(wor.ActualResourceHrs) AS [ThroughputRate(Hour)]
FROM production.WorkOrder AS wo
JOIN production.WorkOrderRouting AS wor
    ON wo.WorkOrderID = wor.WorkOrderID
WHERE YEAR(wo.StartDate) IN (2012, 2013)
GROUP BY YEAR(wo.StartDate);

-------------------------------------------------------------------------------------------
---3- Cost of Poor Quality (COPQ) = Scrap Cost / Total Production Cost * 100
SELECT YEAR(wo.StartDate) Year,
		SUM(wo.OrderQty) AS OrderQty, CAST(SUM(wo.OrderQty*pch.StandardCost) AS INT) ProductionCost, 
		SUM(wo.ScrappedQty) AS ScrappedQty, CAST(SUM(wo.ScrappedQty*pch.StandardCost) AS INT) ScrappedCost,
		/*percentage*/ (SUM(wo.ScrappedQty*pch.StandardCost))*100/(SUM(wo.OrderQty*pch.StandardCost))
						AS [%%ScrappedCost%%]
FROM Production.WorkOrder wo
join Production.ProductCostHistory pch on wo.ProductID=pch.ProductID 
	AND wo.StartDate >= pch.StartDate
    AND (wo.StartDate <= pch.EndDate OR pch.EndDate IS NULL)
WHERE YEAR(wo.StartDate) in (2012,2013)
GROUP BY YEAR(wo.StartDate);

-------------------------------------------------------------------------------------------
---4- Setup Time Ratio = Total Setup Time / Total Production Time * 100
SELECT YEAR(wor.ScheduledStartDate) Year,
		AVG(DATEDIFF(DAY, wor.ScheduledStartDate, wor.ActualStartDate)) AS [TotalSetupTime(AVG)],
		AVG(DATEDIFF(DAY, wor.ActualStartDate, wor.ActualENDDate)) AS [TotalProductionTime(AVG)],
		/*SetupTimeRatio*/ (AVG(DATEDIFF(DAY, wor.ScheduledStartDate, wor.ActualStartDate)))*100/
		(AVG(DATEDIFF(DAY, wor.ActualStartDate, wor.ActualENDDate))) AS [%%SetupTimeRatio%%]
FROM Production.WorkOrderRouting wor
JOIN Production.WorkOrder wo ON wor.WorkOrderID = wo.WorkOrderID 
WHERE YEAR(wor.ScheduledStartDate) IN (2012,2013)
GROUP BY YEAR(wor.ScheduledStartDate)
ORDER BY YEAR(wor.ScheduledStartDate);

-------------------------------------------------------------------------------------------
---5- Production Efficiency Rate = (Actual Production Time / Planned Production Time) * 100
SELECT YEAR(ScheduledStartDate) AS Year,
		SUM(DATEDIFF(DAY, wor.ScheduledStartDate, wor.ScheduledEndDate)) AS TotalPlannedProductionTime,
		SUM(DATEDIFF(DAY, wor.ActualStartDate,wor.ActualEndDate)) AS TotalActualProductionTime,
		/*ProductionEfficiencyRate*/ ((SUM(DATEDIFF(DAY, wor.ScheduledStartDate, wor.ScheduledEndDate)))*100/
		(SUM(DATEDIFF(DAY, wor.ActualStartDate,wor.ActualEndDate)))) AS [%%ProductionEfficiencyRate%%]
FROM production.WorkOrderRouting wor
WHERE YEAR(ScheduledStartDate) IN (2012,2013)
GROUP BY YEAR(ScheduledStartDate);

-------------------------------------------------------------------------------------------
---6- Scrap Rate = (Quantity of Scrapped Items / Total Quantity Produced) * 100
SELECT YEAR(wo.StartDate) Year,
		SUM(wo.OrderQty) AS OrderQty, 
		SUM(wo.ScrappedQty) AS ScrappedQty,
		((SUM(wo.ScrappedQty) * 100.0) / SUM(wo.OrderQty)) AS [%%ScrapRate%%]
FROM Production.WorkOrder wo
WHERE YEAR(wo.StartDate) in (2012,2013)
GROUP BY YEAR(wo.StartDate);

-------------------------------------------------------------------------------------------
---7- Manufacturing Cycle Time = Average(ActualEndDate - ActualStartDate) for all WorkOrders
SELECT YEAR(StartDate) YEAR,
    AVG(DATEDIFF(day, StartDate, EndDate)) AS AvgManufacturingCycleTime
FROM production.WorkOrder
WHERE YEAR(StartDate) IN (2013,2012)
GROUP BY YEAR(StartDate);

-------------------------------------------------------------------------------------------
--2) Inventory and Resource Metrics:
---8- Inventory Accuracy = (Total Correct Inventory Counts / Total Inventory Counts) * 100
--- After investigate turned out that Inventory Accuracy is being achieved on 6 products from 432 product
---- which mean we need to give a detailed table for the differences
WITH InventoryCounts AS (
    SELECT pi.ProductID, 
           SUM(pi.Quantity) AS ActualStocked
    FROM production.ProductInventory AS pi
    GROUP BY pi.ProductID
), 
Transactions AS (
    SELECT ProductID,
           SUM(CASE WHEN TransactionType = 'P' THEN Quantity ELSE 0 END) AS PurchasedProducts,
           SUM(CASE WHEN TransactionType = 'W' THEN Quantity ELSE 0 END) AS ProducedProducts,
           SUM(CASE WHEN TransactionType = 'S' THEN Quantity ELSE 0 END) AS QuantitySold
    FROM ( --combine the TransactionHistory table with its Archive
        SELECT ProductID, Quantity, TransactionType 
        FROM production.TransactionHistory
        UNION ALL
        SELECT ProductID, Quantity, TransactionType 
        FROM production.TransactionHistoryArchive
    ) AS th
    GROUP BY ProductID
),
RecordedInventory AS (
    SELECT t.ProductID, 
           ((t.PurchasedProducts + t.ProducedProducts) - t.QuantitySold) AS RecordedInventory
    FROM Transactions t
)
SELECT ic.ProductID, ic.ActualStocked, ci.RecordedInventory,
    (ci.RecordedInventory - ic.ActualStocked) AS Difference
FROM InventoryCounts ic
JOIN RecordedInventory ci ON ic.ProductID = ci.ProductID
WHERE ic.ActualStocked != ci.RecordedInventory
ORDER BY ic.ProductID;

-------------------------------------------------------------------------------------------
--3) Delivery Performance:
---9- On-Time Delivery Rate = Percentage of orders delivered on or before the due date
SELECT YEAR(StartDate) Year,
		COUNT(CASE WHEN DAY(EndDate) <= DAY(DueDate) THEN 1 END)*100.0
		/COUNT(*) AS [%%OnTimeDeliveryRate%%]
FROM production.WorkOrder
WHERE YEAR(StartDate) in(2012,2013)
GROUP BY YEAR(StartDate);
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------