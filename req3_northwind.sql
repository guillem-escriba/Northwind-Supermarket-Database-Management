

use northwind;
-- requierment 3


ALTER TABLE Products RENAME COLUMN  UnitPrice TO UnitPriceUSD;
ALTER TABLE Products ADD  UnitPriceEUR double;
ALTER TABLE Products ADD UnitPriceGBP double;
ALTER TABLE Products ADD UnitPriceJPY double;
SET SQL_SAFE_UPDATES=0;

DELIMITER //

DROP PROCEDURE IF EXISTS CurrencyChange //
CREATE PROCEDURE CurrencyChange(IN productID int)
BEGIN
		IF productID =-1 THEN -- Selects all products
			BEGIN
				DECLARE done int DEFAULT 0;
				DECLARE price double;
				DECLARE cur_products CURSOR FOR (SELECT UnitPriceUSD FROM Products);
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;

				open cur_products; -- Loops for every product and updates the rows
				label1: LOOP
						FETCH cur_products INTO price;
						IF done =1 THEN
							LEAVE label1;
						END IF;
						UPDATE Products SET UnitPriceEUR=price*0.96 WHERE UnitPriceUSD=price ;
						UPDATE Products SET UnitPriceGBP=price*0.84 WHERE UnitPriceUSD=price ;
						UPDATE Products SET UnitPriceJPY=price*140 WHERE UnitPriceUSD=price ;
                
						END LOOP label1;
						CLOSE cur_products;
			END;
			ELSEIF productID>0 THEN -- Updates only one product with productID
					IF EXISTS (SELECT ProductID FROM Products WHERE ProductID=productID) THEN
                    BEGIN
                            SET @price = (SELECT UnitPriceUSD FROM Products WHERE ProductID=productID);
							UPDATE Products SET UnitPriceEUR = 0.96 * @price WHERE productID=ProductID;
                            UPDATE Products SET UnitPriceGBP = 0.84 * @price WHERE productID=ProductID;
                            UPDATE Products SET UnitPriceJPY = 140 * @price WHERE productID=ProductID;
					END;
                           END IF;
				END IF;
					
                
        
END //
delimiter ;

CALL CurrencyChange(-1);
SELECT * FROM products;
