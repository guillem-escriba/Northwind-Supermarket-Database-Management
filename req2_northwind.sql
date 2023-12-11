USE northwind;

-- Find out who the fired employee is

SELECT COUNT(orders.orderID) AS processedOrders, employees.* 
FROM employees
JOIN orders ON orders.EmployeeID = employees.EmployeeID
GROUP BY employees.EmployeeID
ORDER BY COUNT(orders.OrderID) ASC LIMIT 1;

DELIMITER %%
DROP PROCEDURE IF EXISTS CheckDates%%
CREATE PROCEDURE CheckDates()
BEGIN
DECLARE done INT DEFAULT 0;
DECLARE order_date DATE;
DECLARE shipped_date DATE;
DECLARE required_date DATE;
DECLARE order_id int;
DECLARE orders_now CURSOR FOR (SELECT orders.orderID, orders.OrderDate, orders.ShippedDate, orders.RequiredDate FROM orders);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
OPEN orders_now;

Label1: LOOP

FETCH orders_now INTO order_id, order_date, shipped_date, required_date;
-- OrderDate has to be the oldest among the three
-- ShippedDate has to be older or equal to RequiredDate
-- RequiredDate should be the newest date of all the three.

IF done = 1 THEN
	LEAVE Label1;
END IF;


IF order_date >= shipped_date THEN
	UPDATE orders SET orders.OrderDate = (DATE(shipped_date) - 1) WHERE orders.orderID = order_id;
END IF;


IF shipped_date > required_date THEN
	UPDATE orders SET orders.ShippedDate = required_date WHERE orders.orderID = order_id;
	SET shipped_date = required_date;
END IF;
END LOOP Label1;

CLOSE orders_now;
END %%


DELIMITER ;
UPDATE orders SET orders.RequiredDate = orders.OrderDate WHERE orders.orderID = 10003;
SELECT * FROM orders WHERE orders.orderID = 10003;
CALL checkDates();
SELECT * FROM orders WHERE orders.orderID = 10003;
SELECT * FROM Orders_log WHERE orders_log.orderID = 10003;