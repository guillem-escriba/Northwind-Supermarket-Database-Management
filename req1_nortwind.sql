SET GLOBAL event_scheduler =1;
USE northwind;
DROP TABLE IF EXISTS Orders_log;
CREATE TABLE IF NOT EXISTS Orders_Log LIKE Orders;
ALTER TABLE Orders_Log ADD change_datetime date;
ALTER TABLE Orders_Log ADD DMLAction varchar(10);
ALTER TABLE Orders_log ADD version int default 1;
ALTER TABLE Orders_log ADD userID varchar(64);
ALTER TABLE Orders_Log DROP PRIMARY KEY, ADD PRIMARY KEY(OrderID,DMLAction,version);
DESCRIBE Orders_log;

DROP TRIGGER IF EXISTS insert_trigger;
 DELIMITER %%
 CREATE TRIGGER insert_trigger  AFTER INSERT ON Orders 
 FOR EACH ROW
 BEGIN
	DECLARE data_version INT DEFAULT 0;
    SET data_version = (SELECT version FROM Orders_log WHERE Orders_Log.OrderID=NEW.OrderID  ORDER BY Orders_Log.version DESC LIMIT 1);
	IF data_version IS NULL THEN
		SET data_version = 0;
	END IF;
INSERT INTO Orders_Log(`OrderID`,`CustomerID`,`EmployeeID`,`OrderDate`,`RequiredDate`,`ShippedDate`,`ShipperID`,`Freight`,`ShipName`,`ShipAddress`,`ShipCity`,`ShipRegion`,`ShipPostalCode`,`ShipCountry`,change_datetime, DMLAction, version, userID)
  VALUES(new.OrderID, new.CustomerID, new.EmployeeID, new.OrderDate,
  new.RequiredDate, new.shippedDate, new.shipperID, new.freight, new.ShipName, new.ShipAddress,
  new.ShipCity, new.ShipRegion, new.ShipPostalCode, new.ShipCountry,now(),"Insert", data_version+1, user());
 END %%
 
 DELIMITER ;
 DROP TRIGGER IF EXISTS update_trigger;
 DELIMITER %%
 CREATE TRIGGER update_trigger  AFTER UPDATE ON Orders
 FOR EACH ROW
	BEGIN
		DECLARE data_version INT DEFAULT 0;
		SET data_version = (SELECT version FROM Orders_log WHERE Orders_Log.OrderID=NEW.OrderID  ORDER BY Orders_Log.version DESC LIMIT 1);
		IF data_version IS NULL THEN
			SET data_version = 0;
		END IF;
		INSERT INTO Orders_Log(`OrderID`,`CustomerID`,`EmployeeID`,`OrderDate`,`RequiredDate`,`ShippedDate`,`ShipperID`,`Freight`,`ShipName`,`ShipAddress`,`ShipCity`,`ShipRegion`,`ShipPostalCode`,`ShipCountry`,change_datetime, DMLAction,version, userID)
			VALUES(new.OrderID, new.CustomerID, new.EmployeeID, new.OrderDate,
				new.RequiredDate, new.shippedDate, new.shipperID, new.freight, new.ShipName, new.ShipAddress,
				new.ShipCity, new.ShipRegion, new.ShipPostalCode, new.ShipCountry,now(),"Update",data_version+1, user());
	END %%
 DELIMITER ;
  DROP TRIGGER IF EXISTS delete_trigger;
 DELIMITER %%
 CREATE TRIGGER delete_trigger  AFTER DELETE ON Orders 
 FOR EACH ROW
    BEGIN
		DECLARE data_version INT DEFAULT 0;
		SET data_version = (select version from Orders_log where Orders_Log.OrderID=old.OrderID  order by Orders_Log.version desc limit 1);
		IF data_version IS NULL THEN
			SET data_version = 0;
		END IF;
		INSERT INTO Orders_Log(`OrderID`,`CustomerID`,`EmployeeID`,`OrderDate`,`RequiredDate`,`ShippedDate`,`ShipperID`,`Freight`,`ShipName`,`ShipAddress`,`ShipCity`,`ShipRegion`,`ShipPostalCode`,`ShipCountry`,change_datetime, DMLAction,version, userID)
			VALUES(old.OrderID,old.CustomerID,old.EmployeeID, old.OrderDate,
				old.RequiredDate,old.shippedDate,old.shipperID,old.freight,old.ShipName,old.ShipAddress,
				old.ShipCity, old.ShipRegion, old.ShipPostalCode,old.ShipCountry,now(),"Delete",data_version+1, user());
	END %%
 DELIMITER ;
DELETE FROM orders WHERE orders.orderID=10003; 
INSERT INTO Orders  VALUES  (10003,'VINET',5,'1996-07-04 00:00:00','1996-08-01 00:00:00','1996-07-16 00:00:00',3,32.38,'Vins et alcools Chevalier','59 rue de l\'Abbaye','Reims','','51100','France');
UPDATE  orders SET shipName="New ship name vasya" where orderID = 10003;
SELECT * FROM Orders_log;

