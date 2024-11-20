-- Use the appropriate database

USE final_project_new;


-- Drop existing tables to start fresh
DROP TABLE IF EXISTS total_cost;
DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS shipping;
DROP TABLE IF EXISTS employee_response;
DROP TABLE IF EXISTS inquiry;
DROP TABLE IF EXISTS employee_info;
DROP TABLE IF EXISTS package;
DROP TABLE IF EXISTS customer;

-- Create the customer table
CREATE TABLE customer(
    `customer_id` VARCHAR(30),
    `first_name` VARCHAR(30),
    `last_name` VARCHAR(30), 
    `phone_number` CHAR(10),
    `email` VARCHAR(30),
    `address` VARCHAR(50),
    CONSTRAINT pk_customer PRIMARY KEY (customer_id)
);

-- Create the employee_info table
CREATE TABLE employee_info(
    `employee_id` VARCHAR(50),
    `first_name` VARCHAR(30),
    `last_name` VARCHAR(30),
    `email` VARCHAR(30),
    CONSTRAINT pk_employee_info PRIMARY KEY (employee_id)
);

-- Create the package table
CREATE TABLE package(
    `package_id` VARCHAR(30),
    `customer_id` VARCHAR(30),
    `status` CHAR(20),
    `cost` DECIMAL(10,2),
    CONSTRAINT fk_package FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT pk_package PRIMARY KEY (package_id)
);

-- Create the inquiry table
CREATE TABLE inquiry(
    `inquiry_id` VARCHAR(30),
    `employee_id` VARCHAR(50),
    `customer_id` VARCHAR(30),
    `inquiry_date` DATE,
    `inquiry_information` VARCHAR(255),
    `inquiry_status` VARCHAR(20),
    CONSTRAINT fk_inquiry_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_inquiry_employee FOREIGN KEY (employee_id) REFERENCES employee_info(employee_id),
    CONSTRAINT pk_inquiry PRIMARY KEY (inquiry_id)
);

-- Create the employee_response table
CREATE TABLE employee_response(
    `employee_id` VARCHAR(50),
    `inquiry_id` VARCHAR(30),
    CONSTRAINT fk_employee_response_employee FOREIGN KEY (employee_id) REFERENCES employee_info(employee_id),
    CONSTRAINT fk_employee_response_inquiry FOREIGN KEY (inquiry_id) REFERENCES inquiry(inquiry_id),
    CONSTRAINT pk_employee_response PRIMARY KEY (employee_id, inquiry_id)
);

-- Create the shipping table
CREATE TABLE shipping(
    `package_obtained_date` DATE,
    `delivery_date` DATE,
    `package_id` VARCHAR(30),
    CONSTRAINT pk_shipping PRIMARY KEY (package_id, package_obtained_date),
    CONSTRAINT fk_shipping FOREIGN KEY (package_id) REFERENCES package(package_id) ON DELETE CASCADE
);

-- Create the billing table
CREATE TABLE billing(
    `billing_id` VARCHAR(30),
    `customer_id` VARCHAR(30),
    `package_id` VARCHAR(30),
    `amount_due` DECIMAL(10,2),
    `payment_date` DATE,
    CONSTRAINT pk_billing PRIMARY KEY (billing_id),
    CONSTRAINT fk_billing_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_billing_package FOREIGN KEY (package_id) REFERENCES package(package_id)
);

-- Create the total_cost table
CREATE TABLE total_cost(
    `cost_id` VARCHAR(50),
    `package_id` VARCHAR(30),
    `weight` DECIMAL(10,2),
    `dimensions` VARCHAR(30),
    `distance` DECIMAL(10,2),
    `computed_cost` DECIMAL(10,2),
    CONSTRAINT pk_total_cost PRIMARY KEY (cost_id),
    CONSTRAINT fk_total_cost FOREIGN KEY (package_id) REFERENCES package(package_id) ON DELETE CASCADE
);

DROP PROCEDURE IF EXISTS calculate_total_cost;
-- Procedure to calculate total cost
DELIMITER $$
CREATE PROCEDURE calculate_total_cost (
    IN pkg_id VARCHAR(30),
    IN weight DECIMAL(10,2),
    IN dimensions VARCHAR(30),
    IN distance DECIMAL(10,2)
)
BEGIN
    DECLARE base_cost DECIMAL(10,2);
    DECLARE dimension_multiplier DECIMAL(10,2);
    DECLARE distance_multiplier DECIMAL(10,2);
    DECLARE total DECIMAL(10,2);
    DECLARE length DECIMAL(10,2);
    DECLARE width DECIMAL(10,2);
    DECLARE height DECIMAL(10,2);
    DECLARE volume DECIMAL(10,2);

    -- Parse dimensions (e.g., "10x5x3")
    SET length = CAST(SUBSTRING_INDEX(dimensions, 'x', 1) AS DECIMAL(10,2));
    SET width = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(dimensions, 'x', 2), 'x', -1) AS DECIMAL(10,2));
    SET height = CAST(SUBSTRING_INDEX(dimensions, 'x', -1) AS DECIMAL(10,2));
    SET volume = length * width * height;

    -- Define cost components
    SET base_cost = 10.00;
    SET dimension_multiplier = 0.5;
    SET distance_multiplier = 0.1;

    -- Compute total cost
    SET total = base_cost + (weight * 2) + (dimension_multiplier * volume) + (distance * distance_multiplier);

    -- Insert into total_cost table
    INSERT INTO total_cost (cost_id, package_id, weight, dimensions, distance, computed_cost)
    VALUES (UUID(), pkg_id, weight, dimensions, distance, total);
END $$
DELIMITER ;

-- Insert data into customer table
INSERT INTO customer (customer_id, first_name, last_name, phone_number, email, address)
VALUES 
('CUST001', 'John', 'Doe', '1234567890', 'john.doe@example.com', '123 Main St'),
('CUST002', 'Jane', 'Smith', '0987654321', 'jane.smith@example.com', '456 Elm St'),
('CUST003', 'Alice', 'Johnson', '1112223333', 'alice.johnson@example.com', '789 Pine Rd'),
('CUST004', 'Ethan', 'Estatico', '192837292', 'ethan.estatico@example.com', '997 Oakland St'),
('CUST005', 'Robert', 'Brown', '3334445555', 'robert.brown@example.com', '101 Maple St'),
('CUST006', 'Emily', 'Davis', '4445556666', 'emily.davis@example.com', '202 Oak St'),
('CUST007', 'Michael', 'Wilson', '5556667777', 'michael.wilson@example.com', '303 Birch Rd'),
('CUST008', 'Sarah', 'Martinez', '6667778888', 'sarah.martinez@example.com', '404 Cedar Ave'),
('CUST009', 'David', 'Taylor', '7778889999', 'david.taylor@example.com', '505 Cherry St'),
('CUST010', 'Jessica', 'Anderson', '8889990000', 'jessica.anderson@example.com', '606 Willow Ln'),
('CUST011', 'Daniel', 'Thomas', '9990001111', 'daniel.thomas@example.com', '707 Spruce Dr'),
('CUST012', 'Sophia', 'White', '0001112222', 'sophia.white@example.com', '808 Aspen Pl'),
('CUST013', 'William', 'Harris', '1112223333', 'william.harris@example.com', '909 Magnolia St'),
('CUST014', 'Olivia', 'Clark', '2223334444', 'olivia.clark@example.com', '1010 Dogwood Ct'),
('CUST015', 'James', 'Lewis', '3334445555', 'james.lewis@example.com', '1111 Sycamore Rd'),
('CUST016', 'Isabella', 'Young', '4445556666', 'isabella.young@example.com', '1212 Poplar St'),
('CUST017', 'Benjamin', 'Hill', '5556667777', 'benjamin.hill@example.com', '1313 Cypress Ln'),
('CUST018', 'Mia', 'Scott', '6667778888', 'mia.scott@example.com', '1414 Palm Dr'),
('CUST019', 'Alexander', 'Adams', '7778889999', 'alexander.adams@example.com', '1515 Redwood St'),
('CUST020', 'Charlotte', 'Campbell', '8889990000', 'charlotte.campbell@example.com', '1616 Sequoia Ave'),
('CUST021', 'Noah', 'Parker', '9990001111', 'noah.parker@example.com', '1717 Fir Pl'),
('CUST022', 'Amelia', 'Evans', '0001112222', 'amelia.evans@example.com', '1818 Hemlock Ln'),
('CUST023', 'Lucas', 'Rivera', '1112223333', 'lucas.rivera@example.com', '1919 Holly Ct'),
('CUST024', 'Grace', 'Collins', '2223334444', 'grace.collins@example.com', '2020 Beech St'),
('CUST025', 'Elijah', 'King', '3334445555', 'elijah.king@example.com', '2121 Alder Rd'),
('CUST026', 'Ava', 'Morgan', '4445556666', 'ava.morgan@example.com', '2222 Cottonwood Ln'),
('CUST027', 'Liam', 'Garcia', '5556667777', 'liam.garcia@example.com', '2323 Mahogany Ave'),
('CUST028', 'Emma', 'Rodriguez', '6667778888', 'emma.rodriguez@example.com', '2424 Cherry Blossom Rd'),
('CUST029', 'Jackson', 'Perez', '7778889999', 'jackson.perez@example.com', '2525 Hawthorn Ln'),
('CUST030', 'Aria', 'Stewart', '8889990000', 'aria.stewart@example.com', '2626 Elderberry St');

-- Insert data into package table
INSERT INTO package (package_id, customer_id, status, cost)
VALUES 
('PKG001', 'CUST001', 'Delivered', 29.99),
('PKG002', 'CUST002', 'In Transit', 49.50),
('PKG003', 'CUST003', 'Pending', 15.75),
('PKG004', 'CUST004', 'Delivered', 16.99),
('PKG005', 'CUST005', 'In Transit', 35.50),
('PKG006', 'CUST006', 'Pending', 42.00),
('PKG007', 'CUST007', 'Delivered', 55.20),
('PKG008', 'CUST008', 'In Transit', 12.75),
('PKG009', 'CUST009', 'Pending', 27.30),
('PKG010', 'CUST010', 'Delivered', 33.99),
('PKG011', 'CUST011', 'In Transit', 20.15),
('PKG012', 'CUST012', 'Pending', 18.90),
('PKG013', 'CUST013', 'Delivered', 25.60),
('PKG014', 'CUST014', 'In Transit', 40.75),
('PKG015', 'CUST015', 'Pending', 30.40),
('PKG016', 'CUST016', 'Delivered', 22.85),
('PKG017', 'CUST017', 'In Transit', 37.95),
('PKG018', 'CUST018', 'Pending', 29.60),
('PKG019', 'CUST019', 'Delivered', 41.25),
('PKG020', 'CUST020', 'In Transit', 34.50),
('PKG021', 'CUST021', 'Pending', 28.99),
('PKG022', 'CUST022', 'Delivered', 19.75),
('PKG023', 'CUST023', 'In Transit', 31.20),
('PKG024', 'CUST024', 'Pending', 24.50),
('PKG025', 'CUST025', 'Delivered', 39.99),
('PKG026', 'CUST026', 'In Transit', 26.70),
('PKG027', 'CUST027', 'Pending', 32.40),
('PKG028', 'CUST028', 'Delivered', 44.85),
('PKG029', 'CUST029', 'In Transit', 36.99),
('PKG030', 'CUST030', 'Pending', 21.55);

-- Insert data into employee_info table
INSERT INTO employee_info (employee_id, first_name, last_name, email)
VALUES 
('EMP001', 'Michael', 'Brown', 'michael.brown@company.com'),
('EMP002', 'Sarah', 'Davis', 'sarah.davis@company.com'),
('EMP003', 'Emily', 'Wilson', 'emily.wilson@company.com'),
('EMP004', 'James', 'Taylor', 'james.taylor@company.com'),
('EMP005', 'Olivia', 'Martin', 'olivia.martin@company.com'),
('EMP006', 'Liam', 'Anderson', 'liam.anderson@company.com'),
('EMP007', 'Emma', 'Thomas', 'emma.thomas@company.com'),
('EMP008', 'Noah', 'Harris', 'noah.harris@company.com'),
('EMP009', 'Sophia', 'Clark', 'sophia.clark@company.com'),
('EMP010', 'Isabella', 'Lewis', 'isabella.lewis@company.com'),
('EMP011', 'Mason', 'Young', 'mason.young@company.com'),
('EMP012', 'Ava', 'Walker', 'ava.walker@company.com'),
('EMP013', 'Ethan', 'Hall', 'ethan.hall@company.com'),
('EMP014', 'Charlotte', 'Allen', 'charlotte.allen@company.com'),
('EMP015', 'Lucas', 'King', 'lucas.king@company.com'),
('EMP016', 'Amelia', 'Scott', 'amelia.scott@company.com'),
('EMP017', 'Benjamin', 'Adams', 'benjamin.adams@company.com'),
('EMP018', 'Mia', 'Baker', 'mia.baker@company.com'),
('EMP019', 'Elijah', 'Turner', 'elijah.turner@company.com'),
('EMP020', 'Harper', 'Carter', 'harper.carter@company.com'),
('EMP021', 'Logan', 'Perez', 'logan.perez@company.com'),
('EMP022', 'Evelyn', 'Ramirez', 'evelyn.ramirez@company.com'),
('EMP023', 'Oliver', 'Gonzalez', 'oliver.gonzalez@company.com'),
('EMP024', 'Abigail', 'Bryant', 'abigail.bryant@company.com'),
('EMP025', 'Henry', 'Rivera', 'henry.rivera@company.com'),
('EMP026', 'Ella', 'Gray', 'ella.gray@company.com'),
('EMP027', 'Alexander', 'Cruz', 'alexander.cruz@company.com'),
('EMP028', 'Avery', 'Reed', 'avery.reed@company.com'),
('EMP029', 'Sebastian', 'Flores', 'sebastian.flores@company.com'),
('EMP030', 'Scarlett', 'Hughes', 'scarlett.hughes@company.com');


-- Insert data into inquiry table
INSERT INTO inquiry (inquiry_id, employee_id, customer_id, inquiry_date, inquiry_information, inquiry_status)
VALUES 
('INQ001', 'EMP001', 'CUST001', '2024-11-01', 'Package delayed', 'Resolved'),
('INQ002', 'EMP002', 'CUST002', '2024-11-02', 'Address change request', 'Pending'),
('INQ003', 'EMP003', 'CUST003', '2024-11-03', 'Package lost', 'In Progress'),
('INQ004', 'EMP001', 'CUST004', '2024-11-04', 'Request for expedited shipping', 'Resolved'),
('INQ005', 'EMP002', 'CUST005', '2024-11-05', 'Billing issue', 'Pending'),
('INQ006', 'EMP003', 'CUST006', '2024-11-06', 'Tracking number not updated', 'In Progress'),
('INQ007', 'EMP004', 'CUST007', '2024-11-07', 'Damaged package', 'Resolved'),
('INQ008', 'EMP005', 'CUST008', '2024-11-08', 'Incorrect delivery address', 'Pending'),
('INQ009', 'EMP001', 'CUST009', '2024-11-09', 'Package stuck in transit', 'In Progress'),
('INQ010', 'EMP002', 'CUST010', '2024-11-10', 'Request for delivery confirmation', 'Resolved'),
('INQ011', 'EMP003', 'CUST011', '2024-11-11', 'Delayed delivery due to weather', 'Pending'),
('INQ012', 'EMP004', 'CUST012', '2024-11-12', 'Customer needs invoice copy', 'Resolved'),
('INQ013', 'EMP005', 'CUST013', '2024-11-13', 'Package delivered to wrong address', 'In Progress'),
('INQ014', 'EMP001', 'CUST014', '2024-11-14', 'Refund request for lost package', 'Pending'),
('INQ015', 'EMP002', 'CUST015', '2024-11-15', 'Inquiry about customs charges', 'Resolved'),
('INQ016', 'EMP003', 'CUST016', '2024-11-16', 'Change delivery date request', 'Pending'),
('INQ017', 'EMP004', 'CUST017', '2024-11-17', 'Package delivered late', 'Resolved'),
('INQ018', 'EMP005', 'CUST018', '2024-11-18', 'Duplicate billing issue', 'In Progress'),
('INQ019', 'EMP001', 'CUST019', '2024-11-19', 'Request to update phone number', 'Pending'),
('INQ020', 'EMP002', 'CUST020', '2024-11-20', 'Inquiry about international shipping', 'Resolved'),
('INQ021', 'EMP003', 'CUST021', '2024-11-21', 'Package not delivered', 'In Progress'),
('INQ022', 'EMP004', 'CUST022', '2024-11-22', 'Re-schedule for missed delivery', 'Pending'),
('INQ023', 'EMP005', 'CUST023', '2024-11-23', 'Wrong package received', 'Resolved'),
('INQ024', 'EMP001', 'CUST024', '2024-11-24', 'Address validation for delivery', 'Pending'),
('INQ025', 'EMP002', 'CUST025', '2024-11-25', 'Request for delivery proof', 'In Progress'),
('INQ026', 'EMP003', 'CUST026', '2024-11-26', 'Request to cancel package', 'Resolved'),
('INQ027', 'EMP004', 'CUST027', '2024-11-27', 'Lost package refund inquiry', 'Pending'),
('INQ028', 'EMP005', 'CUST028', '2024-11-28', 'Request for package photo at delivery', 'In Progress'),
('INQ029', 'EMP001', 'CUST029', '2024-11-29', 'Delayed due to incorrect labeling', 'Resolved'),
('INQ030', 'EMP002', 'CUST030', '2024-11-30', 'Package size mismatch', 'Pending');



-- Insert data into employee_response table
INSERT INTO employee_response (employee_id, inquiry_id)
VALUES 
('EMP001', 'INQ001'),
('EMP002', 'INQ002'),
('EMP003', 'INQ003'),
('EMP004', 'INQ004'),
('EMP005', 'INQ005'),
('EMP006', 'INQ006'),
('EMP007', 'INQ007'),
('EMP008', 'INQ008'),
('EMP009', 'INQ009'),
('EMP010', 'INQ010'),
('EMP011', 'INQ011'),
('EMP012', 'INQ012'),
('EMP013', 'INQ013'),
('EMP014', 'INQ014'),
('EMP015', 'INQ015'),
('EMP016', 'INQ016'),
('EMP017', 'INQ017'),
('EMP018', 'INQ018'),
('EMP019', 'INQ019'),
('EMP020', 'INQ020'),
('EMP021', 'INQ021'),
('EMP022', 'INQ022'),
('EMP023', 'INQ023'),
('EMP024', 'INQ024'),
('EMP025', 'INQ025'),
('EMP026', 'INQ026'),
('EMP027', 'INQ027'),
('EMP028', 'INQ028'),
('EMP029', 'INQ029'),
('EMP030', 'INQ030');

-- Insert data into shipping table
INSERT INTO shipping (package_obtained_date, delivery_date, package_id)
VALUES 
('2024-10-20', '2024-10-25', 'PKG001'),
('2024-10-21', NULL, 'PKG002'),
('2024-10-22', NULL, 'PKG003'),
('2024-10-23', '2024-10-28', 'PKG004'),
('2024-10-24', '2024-10-30', 'PKG005'),
('2024-10-25', NULL, 'PKG006'),
('2024-10-26', '2024-11-01', 'PKG007'),
('2024-10-27', '2024-11-02', 'PKG008'),
('2024-10-28', NULL, 'PKG009'),
('2024-10-29', '2024-11-03', 'PKG010'),
('2024-10-30', '2024-11-04', 'PKG011'),
('2024-10-31', NULL, 'PKG012'),
('2024-11-01', '2024-11-05', 'PKG013'),
('2024-11-02', '2024-11-06', 'PKG014'),
('2024-11-03', NULL, 'PKG015'),
('2024-11-04', '2024-11-08', 'PKG016'),
('2024-11-05', '2024-11-09', 'PKG017'),
('2024-11-06', NULL, 'PKG018'),
('2024-11-07', '2024-11-12', 'PKG019'),
('2024-11-08', '2024-11-13', 'PKG020'),
('2024-11-09', NULL, 'PKG021'),
('2024-11-10', '2024-11-14', 'PKG022'),
('2024-11-11', '2024-11-15', 'PKG023'),
('2024-11-12', NULL, 'PKG024'),
('2024-11-13', '2024-11-17', 'PKG025'),
('2024-11-14', '2024-11-18', 'PKG026'),
('2024-11-15', NULL, 'PKG027'),
('2024-11-16', '2024-11-20', 'PKG028'),
('2024-11-17', '2024-11-21', 'PKG029'),
('2024-11-18', NULL, 'PKG030');

-- Insert data into billing table
INSERT INTO billing (billing_id, customer_id, package_id, amount_due, payment_date)
VALUES 
('BILL001', 'CUST001', 'PKG001', 29.99, '2024-10-26'),
('BILL002', 'CUST002', 'PKG002', 49.50, NULL),
('BILL003', 'CUST003', 'PKG003', 15.75, NULL),
('BILL004', 'CUST004', 'PKG004', 16.99, '2024-10-29'),
('BILL005', 'CUST005', 'PKG005', 32.50, '2024-10-31'),
('BILL006', 'CUST006', 'PKG006', 45.75, NULL),
('BILL007', 'CUST007', 'PKG007', 28.00, '2024-11-02'),
('BILL008', 'CUST008', 'PKG008', 12.40, '2024-11-03'),
('BILL009', 'CUST009', 'PKG009', 60.00, NULL),
('BILL010', 'CUST010', 'PKG010', 75.99, '2024-11-05'),
('BILL011', 'CUST011', 'PKG011', 89.50, '2024-11-06'),
('BILL012', 'CUST012', 'PKG012', 40.00, NULL),
('BILL013', 'CUST013', 'PKG013', 22.30, '2024-11-07'),
('BILL014', 'CUST014', 'PKG014', 34.80, '2024-11-08'),
('BILL015', 'CUST015', 'PKG015', 18.25, NULL),
('BILL016', 'CUST016', 'PKG016', 50.00, '2024-11-10'),
('BILL017', 'CUST017', 'PKG017', 65.99, '2024-11-12'),
('BILL018', 'CUST018', 'PKG018', 48.60, NULL),
('BILL019', 'CUST019', 'PKG019', 30.00, '2024-11-13'),
('BILL020', 'CUST020', 'PKG020', 27.50, '2024-11-15'),
('BILL021', 'CUST021', 'PKG021', 15.00, NULL),
('BILL022', 'CUST022', 'PKG022', 25.80, '2024-11-16'),
('BILL023', 'CUST023', 'PKG023', 19.99, '2024-11-17'),
('BILL024', 'CUST024', 'PKG024', 29.00, NULL),
('BILL025', 'CUST025', 'PKG025', 33.33, '2024-11-19'),
('BILL026', 'CUST026', 'PKG026', 41.25, '2024-11-20'),
('BILL027', 'CUST027', 'PKG027', 50.99, NULL),
('BILL028', 'CUST028', 'PKG028', 60.00, '2024-11-21'),
('BILL029', 'CUST029', 'PKG029', 55.55, '2024-11-22'),
('BILL030', 'CUST030', 'PKG030', 20.75, NULL);

-- Call procedure for total cost
CALL calculate_total_cost('PKG001', 5.00, '10x5x3', 100.00);
CALL calculate_total_cost('PKG002', 3.50, '8x4x2', 150.00);
CALL calculate_total_cost('PKG003', 2.00, '12x6x4', 200.00);

-- Show tables
SHOW TABLES;

-- Test queries
SELECT c.first_name, c.last_name, p.package_id, p.status
FROM customer c
JOIN package p ON c.customer_id = p.customer_id;

SELECT * FROM customer;
SELECT * FROM employee_info;
SELECT * FROM package;
SELECT * FROM inquiry;
SELECT * FROM employee_response;
SELECT * FROM shipping;
SELECT * FROM billing;
SELECT * FROM total_cost;

SHOW TABLES;

CREATE INDEX idx_customer_id ON customer(last_name);
CREATE INDEX idx_inquiry_date ON inquiry(inquiry_date);
CREATE INDEX idx_package_id ON package(package_id);
CREATE INDEX idx_shipping_package_id ON shipping(package_id);
CREATE INDEX idx_employee_response_emp_id ON employee_response(employee_id);
CREATE INDEX idx_employee_info_last_name ON employee_info(last_name);
CREATE INDEX idx_total_cost_package_id ON total_cost(package_id);

EXPLAIN SELECT * FROM customer WHERE last_name = 'Doe';

