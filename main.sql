USE final_project_1500;

DROP TABLE IF EXISTS total_cost;
DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS shipping;
DROP TABLE IF EXISTS inquiry;
DROP TABLE IF EXISTS employee_info;
DROP TABLE IF EXISTS employee_response;
DROP TABLE IF EXISTS package;
DROP TABLE IF EXISTS customer;

CREATE TABLE customer(
	`first_name` VARCHAR(30),
    `last_name` VARCHAR(30), 
    `phone_number` CHAR(10),
    `email` VARCHAR(30),
    `address` VARCHAR(50),
	`customer_id` VARCHAR(30),
    constraint pk_customer primary key(customer_id)
);

CREATE TABLE package(
	`package_id` VARCHAR(30),
    `customer_id` VARCHAR(30),
    `status` CHAR(10),
    `cost` DECIMAL(10,2),
    
    constraint fk_package foreign key(customer_id) references customer(customer_id),
    constraint pk_package primary key(package_id)

);

CREATE TABLE employee_response(
	`employee_id` VARCHAR(50),
	`inquiry_id` VARCHAR(30),

	constraint pk_employee_response primary key(employee_id)
);

CREATE TABLE inquiry(
	`inquiry_id` VARCHAR(30),
    `employee_id` VARCHAR(50),
    `customer_id`VARCHAR(30),
    `inquiry_date` DATE,
    `inquiry_information` VARCHAR(255),
    `inquiry_status` CHAR(10),
    
	constraint fk_inquiry_one foreign key(customer_id) references customer(customer_id),
    constraint fk_inquiry_two foreign key(employee_id) references employee_response(employee_id),
    constraint pk_inquiry primary key(inquiry_id)
);

Alter table employee_response
ADD constraint inquiry_id
foreign key(inquiry_id)
REFERENCES inquiry(inquiry_id);

CREATE TABLE employee_info(
	`employee_id` VARCHAR(50),
    `first_name` VARCHAR(30),
    `last_name` VARCHAR(30),
    `email` VARCHAR(30),
	
    constraint pk_employee_info primary key(employee_id,email),
	constraint fk_employee_info foreign key(employee_id) references employee_response(employee_id) ON DELETE CASCADE
);

CREATE TABLE shipping(
	`package_obtained_date` DATE,
	`delivery_date` DATE,
	`package_id` VARCHAR(30),
    
    constraint pk_shipping primary key(package_id,package_obtained_date),
	constraint fk_shipping foreign key(package_id) references package(package_id) ON DELETE CASCADE
);

CREATE TABLE billing(
	`billing_id` VARCHAR(30),
    `customer_id` VARCHAR(50),
	`package_id` VARCHAR(30),
    `amount_due` DECIMAL(10,2),
	`payment_date` DATE,
    
    
    constraint pk_billing primary key(billing_id),
	constraint fk_billing_one foreign key(customer_id) references customer(customer_id),
	constraint fk_billing_two foreign key(package_id) references package(package_id)

);

CREATE TABLE total_cost(
    `cost_id` VARCHAR(30),
    `package_id` VARCHAR(30),
    `weight` DECIMAL(10,2), -- Weight of the package
    `dimensions` VARCHAR(30), -- Dimensions (e.g., "10x5x3")
    `distance` DECIMAL(10,2), -- Distance in miles or kilometers
    `computed_cost` DECIMAL(10,2), -- Total calculated cost
    constraint pk_total_cost primary key(cost_id),
    constraint fk_total_cost foreign key(package_id) references package(package_id) ON DELETE CASCADE
);

/*
ETHAN CAN YOU TAKE A LOOK AT THIS...ITS LIKE HOW THE CALCULATION HAPPENS (use chat)
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

    -- Define cost components
    SET base_cost = 10.00; -- Base cost in USD
    SET dimension_multiplier = 0.5; -- Cost per cubic unit
    SET distance_multiplier = 0.1; -- Cost per mile or kilometer

    -- Compute total cost
    SET total = base_cost + (weight * 2) + (dimension_multiplier * CHAR_LENGTH(dimensions)) + (distance * distance_multiplier);

    -- Insert into total_cost table
    INSERT INTO total_cost (cost_id, package_id, weight, dimensions, distance, computed_cost)
    VALUES (UUID(), pkg_id, weight, dimensions, distance, total);
END $$

DELIMITER ;

*/



