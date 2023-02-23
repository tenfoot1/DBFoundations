--*************************************************************************--
-- Title: Assignment06
-- Author: Justin Logan
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-02-21,Justin Logan,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JLogan')
	 Begin 
	  Alter Database [Assignment06DB_JLogan] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JLogan;
	 End
	Create Database Assignment06DB_JLogan;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JLogan;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

USE Assignment06DB_JLogan

go

CREATE View vCategories 
	WITH SCHEMABINDING
	AS SELECT CategoryID, CategoryName
	From Categories
;
go

CREATE View vProducts 
	WITH SCHEMABINDING
	AS SELECT ProductID, ProductName, CategoryID, UnitPrice
	From Products
;
go

CREATE View vEmployees 
	WITH SCHEMABINDING
	AS SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From Employees
;
go

CREATE View vInventories 
	WITH SCHEMABINDING
	AS SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	From Inventories
;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

USE Assignment06DB_JLogan

DENY SELECT on Categories to Public;
DENY SELECT on Products to Public;
DENY SELECT on Employees to Public;
DENY SELECT on Inventories to Public;

GRANT SELECT on vCategories to Public;
GRANT SELECT on vProducts to Public;
GRANT SELECT on vEmployees to Public;
GRANT SELECT on vInventories to Public;

go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

USE Assignment06DB_JLogan

go

CREATE View vProductsByCategories AS
	SELECT Top 100000
	CategoryName, ProductName, UnitPrice
	From Products Join Categories
		On Products.CategoryID = Categories.CategoryID
	Order By CategoryName, ProductName
;

go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Use Assignment06DB_JLogan;

go

CREATE View vInventoriesByProductsByDates AS
	SELECT Top 100000
	[Count], InventoryDate, ProductName
		From Inventories Join Products
			On Products.ProductID = Inventories.ProductID
		Order By ProductName, InventoryDate, [Count]
;

go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Use Assignment06DB_JLogan;

go

CREATE View vInventoriesByEmployeesByDates AS
	SELECT DISTINCT (InventoryDate), [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
		From Inventories Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Order By InventoryDate offset 0 rows
;

go

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Use Assignment06DB_JLogan;

go

CREATE View vInventoriesByProductsByCategories AS
	SELECT Top 100000
	[Count], InventoryDate, ProductName, CategoryName
		From Products 
		Inner Join Categories
			On Categories.CategoryID = Products.CategoryID
		Inner Join Inventories
			On Inventories.ProductID = Products.ProductID
		Order By CategoryName, ProductName, InventoryDate, [Count]
;

go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Use Assignment06DB_JLogan;

go

CREATE View vInventoriesByProductsByEmployees AS
	SELECT Top 100000
	CategoryName, ProductName, InventoryDate, [Count], [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
		From Products 
		Inner Join Categories
			On Categories.CategoryID = Products.CategoryID
		Inner Join Inventories
			On Inventories.ProductID = Products.ProductID
		Inner Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Order By InventoryDate, CategoryName, ProductName, [Employee Name]
;

go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Use Assignment06DB_JLogan;

go

CREATE View vInventoriesForChaiAndChangByEmployees AS
	SELECT Top 100000
	CategoryName, ProductName, InventoryDate, [Count], [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
		From Products 
		Inner Join Categories
			On Categories.CategoryID = Products.CategoryID
		Inner Join Inventories
			On Inventories.ProductID = Products.ProductID
		Inner Join Employees
			On Inventories.EmployeeID = Employees.EmployeeID
		Where ProductName = 'Chai' OR ProductName = 'Chang'
		Order By InventoryDate, CategoryName, ProductName, [Employee Name]
;

go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Use Assignment06DB_JLogan;

go

CREATE View vEmployeesByManager AS
	SELECT Top 100000 
		[Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName,
		[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	From Employees as E Inner Join Employees as M
		On E.ManagerID = M.EmployeeID
	Order By 1,2
;

go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Use Assignment06DB_JLogan;

go

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
	   SELECT TOP 100000
              vc.CATEGORYID, vc.CATEGORYNAME, vp.PRODUCTID, vp.PRODUCTNAME, vp.UNITPRICE AS [PRICE],
			  vi.INVENTORYID, vi.INVENTORYDATE, vi.[COUNT] AS [COUNT], ve.EMPLOYEEID, 
			  ve.EMPLOYEEFIRSTNAME + ' ' + ve.EMPLOYEELASTNAME AS [EMPLOYEE], vm.EMPLOYEEFIRSTNAME + ' ' + vm.EMPLOYEELASTNAME AS [MANAGER]
        FROM dbo.vCATEGORIES vc
		JOIN dbo.vPRODUCTS vp ON vp.CATEGORYID = vc.CATEGORYID
		JOIN dbo.vINVENTORIES vi ON vi.PRODUCTID = vp.PRODUCTID
		JOIN dbo.vEMPLOYEES ve ON ve.EMPLOYEEID = vi.EMPLOYEEID
		JOIN dbo.vEMPLOYEES vm ON vm.EMPLOYEEID = ve.MANAGERID
        ORDER BY
	          vc.CATEGORYNAME, vp.PRODUCTNAME, EMPLOYEE	
;
go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/