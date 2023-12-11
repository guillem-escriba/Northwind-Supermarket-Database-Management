-- Name: Guillem Escriba Molto NIA: 242123
-- Name: Clàudia Quera Madrenas  NIA: 231197

/*
1. Get the supplier with the biggest amount of different provided products. Return the
supplier name and the count of different provided products.
*/
DROP VIEW IF EXISTS query_1;

CREATE VIEW query_1 AS
SELECT s.CompanyName, COUNT(p.ProductID) AS NProvidedProducts
FROM Suppliers s
JOIN Products p
WHERE s.SupplierID = p.SupplierID
GROUP BY s.CompanyName
ORDER BY NProvidedProducts DESC
LIMIT 1;

SELECT * FROM query_1;


/*
2. Get the first five employees with the highest number of orders. Show the Employee’s
ID’s FirstName, LastName and their count of orders. Sort the result by the count of
orders descending.
*/
DROP VIEW IF EXISTS query_2;

CREATE VIEW query_2 AS
SELECT e.EmployeeID, e.FirstName, e.LastName, COUNT(o.OrderID) AS NOrders
FROM Employees e
JOIN Orders o
WHERE e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID
ORDER BY NOrders DESC;

SELECT * FROM query_2;

/*
3. Display all information stored at the database for all the products of the Supplier named
"Grandma Kelly's Homestead". Use a single query (with subquery if needed).
*/

DROP VIEW IF EXISTS query_3;

CREATE VIEW query_3 AS
SELECT p.* 
FROM Products p
JOIN Suppliers s
ON p.SupplierID = s.SupplierID
AND s.CompanyName = "Grandma Kelly's Homestead";


SELECT * FROM query_3;

/*
4. Show the count of different served Products for each Order, also show the name and the
last name of the Employee who placed the Order.
*/
DROP VIEW IF EXISTS query_4;

CREATE VIEW query_4 AS
SELECT d.OrderID, COUNT(d.OrderID) AS DifferentProducts, e.FirstName, e.LastName
FROM OrderDetails d
JOIN Orders o
ON d.OrderID = o.orderID
JOIN Employees e
ON o.EmployeeID = e.EmployeeID
GROUP BY d.OrderID;

SELECT * FROM query_4;
/*
5. Show the product name, quantity and average unit price for each product sold.
*/

DROP VIEW IF EXISTS query_5;

CREATE VIEW query_5 AS
SELECT p.ProductName, COUNT(d.OrderID) AS Quantity, AVG(d.UnitPrice) AS AveragePrice
FROM Products p
JOIN OrderDetails d
ON p.ProductID = d.ProductID
GROUP BY p.ProductID;

SELECT * FROM query_5;

/*
6. Show complete information for orders placed in 1997 and shipped in the same year by 
German customers. Sort the result by customer and order date ascending.
*/

DROP VIEW IF EXISTS query_6;

CREATE VIEW query_6 AS
SELECT o.* 
FROM Orders o
JOIN Customers c
ON o.CustomerID = c.CustomerID 
AND c.Country = "Germany" 
AND INSTR(o.OrderDate , '1997') > 0
AND INSTR(o.ShippedDate , '1997') > 0
ORDER BY 
o.CustomerID ASC,
o.OrderDate ASC;


SELECT * FROM query_6;

/*
7. Return the order identifier and the date for all Orders which contain Products that
belong to the "Beverages" Category. Sort the results by date descending. Do not use the
Category Identifier, use "Beverages".
*/

-- Aquest te repetits
DROP VIEW IF EXISTS query_7;

CREATE VIEW query_7 AS
SELECT o.OrderID, o.OrderDate 
FROM Orders o
JOIN OrderDetails d
ON o.OrderID = d.OrderID
JOIN Products p
ON d.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID 
AND INSTR(c.CategoryName , 'Beverages') > 0
ORDER BY o.OrderID DESC;

SELECT * FROM query_7;

/*
8. Locate the OrderID 10255 and calculate its total cost adding the UnitPrice of
all the contained products inside it.
*/

DROP VIEW IF EXISTS query_8;

CREATE VIEW query_8 AS
SELECT SUM(UnitPrice*Quantity) AS TotalCost
FROM OrderDetails
WHERE OrderID = 10255;

SELECT * FROM query_8;

/*
9. Show the complete information for orders containing Products from Japanese Suppliers.
Sort the result by customer and order date ascending.
*/

DROP VIEW IF EXISTS query_9;

CREATE VIEW query_9 AS
SELECT o.* 
FROM Orders o
JOIN OrderDetails d
ON o.OrderID = d.OrderID
JOIN Products p
ON d.ProductID = p.ProductID
JOIN Suppliers s
ON p.SupplierID = s.SupplierID 
AND s.Country = 'Japan'
ORDER BY
o.CustomerID ASC,
o.OrderDate ASC;


SELECT * FROM query_9;

/*
10. Show the cheapest and the most expensive product(s) (Use only a single query)
*/
DROP VIEW IF EXISTS query_10;

CREATE VIEW query_10 AS
SELECT * 
FROM Products 
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products) 
OR UnitPrice = (SELECT MIN(UnitPrice) FROM Products);

SELECT * FROM query_10;

/*
11.  Return the address, city, postal code and country of all Clients. All fields in the same
return field, that is, the previous four fields in a single column (find a function to help 
you concatenate those values in a single field). Also show the client's identifier and name
in two other single columns.
*/

DROP VIEW IF EXISTS query_11;

CREATE VIEW query_11 AS
SELECT CustomerID, ContactName, CONCAT(Address, City, PostalCode, Country) AS ClientAddress
FROM Customers;

SELECT * FROM query_11;

/*
12. We want to know who are the employees with more processed orders than the
employee with id number 8. Show their personal information.
*/

DROP VIEW IF EXISTS query_12;

CREATE VIEW query_12 AS
SELECT * 
FROM(
SELECT e.*, COUNT(o.OrderID) AS ProcessedOrders
FROM Employees e
JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID
) aux
WHERE ProcessedOrders > (SELECT COUNT(OrderID) FROM Orders WHERE EmployeeID = 8 GROUP BY EmployeeID);

SELECT * FROM query_12;

/*
13. Show the orders with more than three different products inside.
*/

DROP VIEW IF EXISTS query_13;

-- No se si esta be
CREATE VIEW query_13 AS
SELECT OrderID, COUNT(DISTINCT(ProductID)) AS DifferentProducts
FROM OrderDetails
GROUP BY OrderID
HAVING COUNT(DISTINCT(ProductID)) >=3;


SELECT * FROM query_13;

/*
14. Return the orders of customers located in London and for the suppliers in New Orleans.
*/

DROP VIEW IF EXISTS query_14;

CREATE VIEW query_14 AS
SELECT o.* 
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
JOIN OrderDetails d
ON o.OrderID = d.OrderID
JOIN Products p
ON d.ProductID = p.ProductID
JOIN Suppliers s
ON p.SupplierID = s.SupplierID 
AND s.City = 'New Orleans' 
AND c.City = 'London';

SELECT * FROM query_14;

/*
15. Show the name of the products, their category and the price, only when its price is
above 20 and they are linked to the category with the minimum number of registered
products.
*/

DROP VIEW IF EXISTS query_15;

CREATE VIEW query_15 AS
SELECT ProductName, UnitPrice, CategoryID
FROM Products p
WHERE p.UnitPrice > 20 AND p.CategoryID = (SELECT CategoryID
FROM Products GROUP BY CategoryID ORDER BY COUNT(CategoryID) ASC LIMIT 1);

SELECT * FROM query_15;

/*
16. Show the complete name of the employees who processed the highest number of
orders. (Note: There could be more than one employee with the same record, so deliver
a query that accepts more than one result).
*/

DROP VIEW IF EXISTS query_16;

CREATE VIEW query_16 AS
SELECT FirstName, LastName, MAX(OrdersProcessed) 
FROM (
SELECT e.FirstName, e.LastName, COUNT(o.OrderID) AS OrdersProcessed
FROM Employees e
JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID) 
aux;

SELECT * FROM query_16;

/*
17. Return VIP customers (those with more than 25 registered orders and worked also with
more than 2 shippers and with 4 or more employees).
*/

DROP VIEW IF EXISTS query_17;

-- CREATE VIEW query_17 AS
SELECT * 
FROM (
SELECT CustomerID, COUNT(OrderID) AS NOrders, COUNT(DISTINCT(ShipperID)) AS NShippers, COUNT(DISTINCT(EmployeeID)) AS NEmployees 
FROM Orders
GROUP BY CustomerID
) aux
WHERE NOrders > 25 
AND NShippers > 2
AND NEmployees >= 4;


SELECT * FROM query_17;

/*
18. Show the names of the employees who worked with all the registered shipping
companies.
*/

DROP VIEW IF EXISTS query_18;

CREATE VIEW query_18 AS
SELECT FirstName, LastName
FROM (
SELECT e.FirstName, e.LastName, COUNT(DISTINCT(p.SupplierID)) AS NSuppliers
FROM Employees e
JOIN Orders o
ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails d
ON o.OrderID = d.OrderID
JOIN Products p 
ON d.ProductID = p.ProductID
GROUP BY e.EMployeeID
) aux
WHERE NSuppliers = (SELECT COUNT(*) FROM Suppliers);

SELECT COUNT(SupplierID) FROM Suppliers;

/*
19. Return the order ID’s that are required more than 7 days after their order date to
process. You should find a function to help you calculate between two dates.
*/

DROP VIEW IF EXISTS query_19;
CREATE VIEW query_19 AS
SELECT OrderID 
FROM orders 
WHERE datediff(ShippedDate,OrderDate) > 7;
 
 SELECT * FROM query_19;
 
/*
20. For every order detail, return the product name, supplier name, category name,
employee first and last name, shipper company name, and customer company name.
Order all the results depending on the OrderID ascending, and then on the ProductName
also ascending.
*/

DROP VIEW IF EXISTS query_20;

CREATE VIEW query_20 AS
SELECT d.OrderID, p.ProductName, s.CompanyName AS Supplier, c.CategoryName, e.FirstName, e.LastName, sh.CompanyName AS Shipper, cu.CompanyName AS Customer
FROM OrderDetails d
JOIN Orders o
ON d.OrderID = o.OrderID
JOIN Customers cu
ON o.CustomerID = cu.CustomerID
JOIN Employees e
ON o.EmployeeID = e.EmployeeID
JOIN Shippers sh
ON o.ShipperID = sh.ShipperID
JOIN Products p
ON d.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
JOIN Suppliers s
ON p.SupplierID = s.SupplierID
ORDER BY
d.OrderID ASC,
p.ProductName ASC; 

SELECT * FROM query_20;

