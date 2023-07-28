-- CREATE DATABASE sql_practical;

USE sql_practical;



CREATE TABLE User(
	user_id INT PRIMARY KEY AUTO_INCREMENT,
    u_name VARCHAR(25),
    u_email VARCHAR(35)
);

CREATE TABLE Product(
	product_id INT PRIMARY KEY AUTO_INCREMENT,
    p_name VARCHAR(25),
    p_price VARCHAR(35)
);

CREATE TABLE Orders(
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    order_status VARCHAR(50),
    order_date DATE,
    expected_delivery_date DATE,
    FOREIGN KEY(user_id) REFERENCES User(user_id)
);


CREATE TABLE OrderDetail(
	orderDetails_id INT AUTO_INCREMENT PRIMARY KEY,
	order_id INT,
    product_id INT,
	FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


DELIMITER $$
CREATE TRIGGER set_default_dates
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
  IF NEW.order_date IS NULL THEN
    SET NEW.order_date = CURRENT_DATE();
  END IF;

  IF NEW.expected_delivery_date IS NULL THEN
    SET NEW.expected_delivery_date = DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY);
  END IF;
END$$
DELIMITER ;


-- Adding expected delievery date in days in Orders table
ALTER TABLE Orders
ADD COLUMN expected_delivery_days INT;


--  Calculating the expected delivery days
DELIMITER $$
CREATE TRIGGER calculate_expected_delivery_days
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
  SET NEW.expected_delivery_days = DATEDIFF(NEW.expected_delivery_date, NEW.order_date);
END$$
DELIMITER ;


--  adding not null and unique constraints in the product table
ALTER TABLE Product
ADD CONSTRAINT unique_pName_Pprice UNIQUE (p_name,p_price);

ALTER TABLE Orders
MODIFY order_status VARCHAR(20) NOT NULL;




--  INSERTING VALUES IN USER TABLE
DESCRIBE User;

INSERT INTO User(u_name,u_email) values ('Neckvy','neckvy@gmail.com'),
					('Harshit','harshit@gmail.com'),
				        ('Jeel','jeel@gmail.com'),
				        ('Sneha','sneha@gmail.com'),
				        ('Sagar','sagar@gmail.com'),
				        ('Sahil','sahil@gmail.com'),
				        ('Jay','jay@gmail.com'),
				        ('Smit','smit@gmail.com');
                
--  INserting values for inactive users
INSERT INTO User(u_name,u_email) values ('Jane','jane@gmail.com'),
					('kate','kate@gmail.com'),
                                        ('Ells','el@gmail.com');
						

SELECT * FROM User;

--  INSERTING VALUES IN Product TABLE

INSERT INTO Product(p_name,p_price) values ('Google Pixel 5', 699.99),
					   ('Dell XPS 13 Laptop', 1299.99),
				           ('Nintendo Switch', 299.99),
				           ('GoPro HERO9 Black', 449.99),
				           ('Bose QuietComfort 35 II', 349.99),
				           ('LG OLED 4K TV', 1999.99),
				           ('Fitbit Versa 3', 229.99),
				           ('Canon EOS Rebel T7i', 799.99),
				           ('Microsoft Surface Pro 7', 1199.99),
				           ('Amazon Echo Dot', 39.99);

SELECT * FROM Product;




--  Inserting into Orders table
DESCRIBE Orders;

INSERT INTO Orders (user_id, order_status, order_date, expected_delivery_date)
VALUES
  (1, 'Pending', '2023-07-01', '2023-07-06'),
  (2, 'Shipped', '2023-07-02', '2023-07-08'),
  (3, 'Delivered', '2023-07-01', '2023-07-04'),
  (1, 'Pending', '2023-07-04', '2023-07-09'),
  (4, 'Shipped', '2023-07-05', '2023-07-11'),
  (7, 'Delivered', '2023-07-06', '2023-07-13');
  
SELECT * FROM Orders;

INSERT INTO Orders (user_id, order_status)
VALUES
  (5, 'Pending'),
  (6, 'Shipped'),
  (2, 'Delivered');
  
  

--  Inserting into OrderDetails table
DESCRIBE OrderDetail;
INSERT INTO OrderDetail(order_id,product_id) values(1,2),
						   (2,1),
                                                   (3,5),
                                                   (4,7),
                                                   (5,10),
                                                   (6,1),
                                                   (7,5),
                                                   (8,4),
                                                   (9,6),
                                                   (2,7),
                                                   (5,6);
                                                    
SELECT * FROM OrderDetail;



--  QUERIES
-- 1. Fetch all the User order list and include atleast following details in that.
-- Customer name
-- Product names
-- Order Date
-- Expected delivery date (in days, i.e. within X days)

SELECT
  U.u_name AS Customer_Name,
  group_concat(P.p_name SEPARATOR ', ') AS Product_Names,
  O.order_date AS Order_Date,
  O.expected_delivery_days AS Expected_Delivery_In_Days
FROM
  User U
  JOIN Orders O ON U.user_id = O.user_id
  JOIN OrderDetail OD ON O.order_id = OD.order_id
  JOIN Product P ON OD.product_id = P.product_id
GROUP BY 
	O.order_id
ORDER BY
  O.order_date;
  


-- 2. Create summary report which provide information about
-- All undelivered Orders

SELECT U.u_name AS 'Customer Name',
	   O.order_id,
       O.order_date,
       O.order_status,
       O.expected_delivery_days
FROM User U
JOIN Orders O ON U.User_id=O.user_id
WHERE O.order_status <> 'Delivered';



-- 2. Create summary report which provide information about
-- 5 Most recent orders
SELECT U.u_name AS 'Customer Name',
	    group_concat(P.p_name SEPARATOR ',') AS Product_Names,
       O.order_id,
       O.order_date,
       O.expected_delivery_days
FROM User U
JOIN Orders O ON U.user_id=O.user_id
JOIN OrderDetail OD ON O.order_id=OD.order_id
JOIN Product P ON OD.product_id=P.product_id 
GROUP BY
	O.order_id
ORDER BY 
	O.order_date DESC
LIMIT 5;


-- 2. Create summary report which provide information about
-- Top 5 active users (Users having most number of orders)

SELECT U.u_name AS 'Customer Name',
		COUNT(O.order_id) AS Total_Orders
FROM User U
JOIN Orders O ON U.user_id= O.user_id
GROUP BY 
	O.user_id
ORDER BY
	Total_Orders DESC
LIMIT 5;


-- 2. Create summary report which provide information about
-- Inactive users (Users who hasn’t done any order)
SELECT U.user_id as 'Customer Id',
	   U.u_name AS 'Customer Name'
FROM User U
WHERE U.user_id NOT IN (
SELECT DISTINCT O.user_id 
FROM Orders O
)
ORDER BY U.user_id ASC;


-- 2. Create summary report which provide information about
-- Top 5 Most purchased products

SELECT P.p_name,
	   COUNT(OD.product_id) AS Total_orders
FROM Product P
JOIN OrderDetail OD ON P.product_id=OD.product_id
GROUP BY 
	OD.product_id
ORDER BY
	Total_orders DESC
LIMIT 5;


-- 2. Create summary report which provide information about
-- Most expensive and most chepest orders.

(SELECT U.u_name AS 'Customer Name',
		group_concat(P.p_name SEPARATOR ',') AS Product_Names,
        SUM(P.p_price) AS Total_Price,
        'Most Expensive' AS Order_Category
FROM User U
JOIN Orders O ON U.user_id= O.user_id
JOIN OrderDetail OD ON O.order_id=OD.order_id
JOIN Product P ON OD.product_id=P.product_id 
GROUP BY
	OD.order_id
ORDER BY
	Total_Price DESC
LIMIT 1)
UNION
(SELECT U.u_name AS 'Customer Name',
		group_concat(P.p_name SEPARATOR ',') AS Product_Names,
        SUM(P.p_price) AS Total_Price,
        'Cheapest' AS Order_Category
FROM User U
JOIN Orders O ON U.user_id= O.user_id
JOIN OrderDetail OD ON O.order_id=OD.order_id
JOIN Product P ON OD.product_id=P.product_id 
GROUP BY
	OD.order_id
ORDER BY
	Total_Price ASC
LIMIT 1);




--  CREATING STORED PROCEDURE
-- DELIMITER $$
-- CREATE PROCEDURE get_user_order_lists()
-- BEGIN
-- 	SELECT
-- 	  U.u_name AS Customer_Name,
-- 	  group_concat(P.p_name SEPARATOR ', ') AS Product_Names,
-- 	  O.order_date AS Order_Date,
-- 	  O.expected_delivery_days AS Expected_Delivery_In_Days
-- 	FROM
-- 	  User U
-- 	  JOIN Orders O ON U.user_id = O.user_id
-- 	  JOIN OrderDetail OD ON O.order_id = OD.order_id
-- 	  JOIN Product P ON OD.product_id = P.product_id
-- 	GROUP BY 
-- 		O.order_id
-- 	ORDER BY
-- 	  O.order_date;
-- END$$
-- DELIMITER ;
		
