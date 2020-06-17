# Procedures

DROP PROCEDURE IF EXISTS get_users;
DROP PROCEDURE IF EXISTS get_customer_by_nic;
DROP PROCEDURE IF EXISTS get_managers;
DROP PROCEDURE IF EXISTS insert_user;
DROP PROCEDURE IF EXISTS update_daily_rental_rate;
DROP PROCEDURE IF EXISTS get_rental_amount_for_rental;
DROP PROCEDURE IF EXISTS get_rentals_for_current_year;
DROP PROCEDURE IF EXISTS get_rentals_not_closed;
DROP PROCEDURE IF EXISTS get_top_customers;
DROP PROCEDURE IF EXISTS get_cashires;
DROP PROCEDURE IF EXISTS get_pending_rentals_for_customer;
DROP PROCEDURE IF EXISTS get_total_pending_payment_for_customers;
DROP PROCEDURE IF EXISTS get_customers_spent_more_than_average;
DROP PROCEDURE IF EXISTS get_cutomers_never_made_rental;
DROP PROCEDURE IF EXISTS get_bicycles_never_taken;
DROP PROCEDURE IF EXISTS insert_rental;
DROP PROCEDURE IF EXISTS insert_customer;
DROP PROCEDURE IF EXISTS update_rental;
DROP PROCEDURE IF EXISTS delete_rental;
DROP PROCEDURE IF EXISTS update_store_bicycle_count;
DROP PROCEDURE IF EXISTS get_rental_status;
DROP PROCEDURE IF EXISTS get_popular_bicycle_models;

# get user details
DELIMITER $$
CREATE PROCEDURE get_users()
BEGIN
    SELECT * FROM user;
END$$
DELIMITER ;

# get customer by nic
DELIMITER  $$
CREATE PROCEDURE get_customer_by_nic(nic CHAR(10))
BEGIN
        SELECT * FROM customer_details
            WHERE customer_details.nic = IFNULL(nic, customer_details.nic);
END$$
DELIMITER ;

# get all managers
DELIMITER $$
CREATE PROCEDURE get_managers()
BEGIN
    SELECT
        store_manager.nic,
        fname,
        lname,
        dob,
        sex,
        phone,
        email,
        street,
        city,
        district,
        country,
        from_date,
        to_date
    FROM store_manager
    JOIN user u on store_manager.nic = u.nic
    JOIN address a on u.nic = a.user_nic
    ORDER BY fname, lname;
END $$
DELIMITER ;

# insert a user into user table
DELIMITER $$
CREATE PROCEDURE insert_user(
    nic CHAR(10),
    fname VARCHAR(50),
    lname VARCHAR(50),
    dob DATE,
    sex ENUM('M', 'F'),
    phone INT(10),
    email VARCHAR(255)
)
BEGIN
    INSERT INTO user
    VALUES (nic, fname, lname, dob,sex,phone,email);
END$$
DELIMITER ;

# update daily rental for a rental
DELIMITER $$
CREATE PROCEDURE update_daily_rental_rate(
    id INT,
    dailyRentalRate FLOAT
)
BEGIN
    IF dailyRentalRate <= 0 THEN
        SIGNAL SQLSTATE '22003'
            SET MESSAGE_TEXT = 'Invalid daily rental rate';
    END IF;

    UPDATE rental r
    SET r.dailyRentalDate = dailyRentalRate
    WHERE r.id = id;
END$$
DELIMITER ;

# get rental amount for all rental
DELIMITER $$
CREATE PROCEDURE get_rental_amount_for_all_rentals()
BEGIN
    SELECT
        id,
        payment_status_id,
        customer_nic,
        get_rental_amount_for_rental(id) as amount
    FROM rental;
END $$
DELIMITER ;

# get all rental for current year
DELIMITER $$
CREATE PROCEDURE get_rentals_for_current_year()
BEGIN
    SELECT *
    FROM rental
    WHERE YEAR(rentalDate) = YEAR(NOW());
END $$
DELIMITER ;

# get all rental not closed
DELIMITER $$
CREATE PROCEDURE get_rentals_not_closed()
BEGIN
    SELECT *
    FROM rental
    WHERE store_cashier_nic IS NULL OR payment_status_id !=1;
END $$
DELIMITER ;

# get top customers
DELIMITER $$
CREATE PROCEDURE get_top_customers()
BEGIN
    SELECT customer_nic, COUNT(customer_nic) as count
    FROM rental
    GROUP BY customer_nic
    ORDER BY count
    LIMIT 1000;
END $$
DELIMITER ;

# get all cashiers
DELIMITER $$
CREATE PROCEDURE get_cashires()
BEGIN
    SELECT sc.nic,
       from_date,
       to_date,
       fname,
       lname,
       dob,
       sex,
       phone,
       email,
       street,
       city,
       district,
       country,
       store_id,
       location AS store_location,
       manager AS store_manager
    FROM store_cashier sc
    JOIN user u on sc.nic = u.nic
    JOIN store s on sc.store_id = s.id
    JOIN address a on u.nic = a.user_nic;
END $$
DELIMITER ;

# get pending rentals for a customer
DELIMITER $$
CREATE PROCEDURE get_pending_rentals_for_customer(
    customer_nic VARCHAR(10)
)
BEGIN
    SELECT *
    FROM rental
    JOIN payment_status ps on rental.payment_status_id = ps.id
    WHERE rental.customer_nic = customer_nic AND payment_status_id != 1;
END $$
DELIMITER ;

# get total pending payment for customers
DELIMITER $$
CREATE PROCEDURE get_total_pending_payment_for_customers()
BEGIN
    SELECT * FROM rental_balance_by_customers;
END $$
DELIMITER ;

# get customers who spent more than average
DELIMITER $$
CREATE PROCEDURE get_customers_spent_more_than_average()
BEGIN
    SELECT DISTINCT
    customer_nic,
    fname,
    lname,
    registrationDate,
    lastRentalDate,
    dailyRentalDate * DATEDIFF(returnDate, rentalDate) AS total_rental_amount
    FROM rental
    JOIN customer c on rental.customer_nic = c.nic
    JOIN user u on c.nic = u.nic
    WHERE dailyRentalDate * DATEDIFF(returnDate, rentalDate) > (
        SELECT AVG( dailyRentalDate * DATEDIFF(returnDate, rentalDate))
            FROM rental
        );
END $$
DELIMITER ;

# get customers who never has made rental
DELIMITER $$
CREATE PROCEDURE get_cutomers_never_made_rental()
BEGIN
    SELECT
    customer.nic,
    registrationDate,
    fname,
    lname,
    phone,
    email
    FROM customer
    JOIN user u on customer.nic = u.nic
    WHERE customer.nic NOT IN (
        SELECT DISTINCT
            customer_nic
            FROM rental
        );
END $$
DELIMITER ;

# get bicycles which have been never rented
DELIMITER $$
CREATE PROCEDURE get_bicycles_never_taken()
BEGIN
    SELECT *
FROM bicycle b
WHERE NOT EXISTS(
    SELECT DISTINCT bicycle_id
    FROM rental
    WHERE bicycle_id = b.id
    );
END $$
DELIMITER ;

# insert rental
DELIMITER $$
CREATE PROCEDURE insert_rental(
    rental_date DATE,
    s_from INT,
    b_id  INT,
    c_nic VARCHAR(10),
    ps_id INT,
    sc_nic VARCHAR(10)
)
BEGIN
    INSERT INTO rental (rentalDate, rent_from, bicycle_id, customer_nic, payment_status_id,store_cashier_nic)
    VALUES (rental_date, s_from, b_id, c_nic, ps_id, sc_nic);
END $$
DELIMITER ;

# insert customer
DELIMITER $$
CREATE PROCEDURE insert_customer(
    customer_nic VARCHAR(10),
    registration_date DATE
)
BEGIN
    INSERT INTO customer
    VALUES (customer_nic, registration_date, NULL);
END $$
DELIMITER ;

# update rental
DELIMITER $$
CREATE PROCEDURE update_rental(
    r_id INT,
    return_date DATE,
    daily_rental_rate FLOAT,
    s_to INT(3),
    ps_id INT(1),
    sc_nic VARCHAR(10)
)
BEGIN
    UPDATE rental
    SET
        returnDate = return_date,
        dailyRentalDate = daily_rental_rate,
        return_to = s_to,
        payment_status_id = ps_id,
        store_cashier_nic = sc_nic
    WHERE rental.id = r_id;

END $$
DELIMITER ;

# delete a rental
DELIMITER $$
CREATE PROCEDURE delete_rental(
    r_id INT
)
BEGIN
    DELETE FROM rental
    WHERE rental.id = r_id;
END $$
DELIMITER ;

# update number of bicycle in store
DELIMITER $$
CREATE PROCEDURE update_store_bicycle_count(
    s_id INT
)
BEGIN
    UPDATE store
     SET number_of_bicycles = (
        SELECT COUNT(*) FROM bicycle
            WHERE store_id = s_id AND status = 'IN'
        )
    WHERE id = s_id;
END $$
DELIMITER ;

# get all rental status
DELIMITER $$
CREATE PROCEDURE get_rental_status(
)
BEGIN
   SELECT * FROM rental_status;
END $$
DELIMITER ;

# get all most popular bicycle models
DELIMITER $$
CREATE PROCEDURE get_popular_bicycle_models(
)
BEGIN
   SELECT * FROM popular_bicycle_model;
END $$
DELIMITER ;