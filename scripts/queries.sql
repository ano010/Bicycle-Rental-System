USE brs;

## Retrieving Data

# retrieve all users
SELECT *
    FROM user;

# retrieve a customer with nic
SELECT *
    FROM customer
    JOIN user u on customer.nic = u.nic
    WHERE customer.nic = '962112293V';

# retrieve managers details
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

# retrieve rental amount for all rentals
SELECT
    id,
    payment_status_id,
    customer_nic,
    get_rental_amount_for_rental(id) as amount
FROM rental;


# retrieve all rental made by the customer in current year
SELECT *
    FROM rental
    WHERE YEAR(rentalDate) = YEAR(NOW());

# retrieve all rental which are not closed
SELECT *
    FROM rental
    WHERE store_cashier_nic IS NULL OR payment_status_id !=1;

# retrieve top customers
# no need to select all the customers limiting the customers when selecting improve
# query performance
SELECT customer_nic, COUNT(customer_nic) as count
    FROM rental
    GROUP BY customer_nic
    ORDER BY count
    LIMIT 1000;

# retrieve store_cashier details
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

# retrieve all rental for a customer that is pending (not paid)
SELECT *
    FROM rental
    JOIN payment_status ps on rental.payment_status_id = ps.id
    WHERE customer_nic = '962112293V' AND payment_status_id != 1;

# retrieve total pending payment amount for a customer
SELECT
    customer_nic,
    SUM(dailyRentalDate * DATEDIFF(returnDate, rentalDate)) as amount
    FROM rental
    WHERE payment_status_id != 1
    GROUP BY customer_nic;

# find customers who spent more than average
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

# find the customers who never has rented
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

# if the sub query after the IN operator produces a large result set it is more efficient
# to use EXIST operator because when we use the it the sub query does not actually return
# a result set to the outer query. instead  it will return an indication of whether any rows
# in the sub query matches the condition in the inner query. as soon as it finds the that
# matches the criteria it will return true to the EXIST operator.

SELECT
    customer.nic,
    registrationDate,
    fname,
    lname,
    phone,
    email
    FROM customer
    JOIN user u on customer.nic = u.nic
    WHERE NOT EXISTS(
        SELECT DISTINCT
            customer_nic
            FROM rental
            WHERE customer_nic = customer.nic

        );

# find the bicycles that have never been rented
SELECT *
FROM bicycle b
WHERE NOT EXISTS(
    SELECT DISTINCT bicycle_id
    FROM rental
    WHERE bicycle_id = b.id
    );

# Modify Data

# insert rental
INSERT into rental(
                   rentalDate,
                   rent_from,
                   bicycle_id,
                   customer_nic,
                   payment_status_id,
                   store_cashier_nic
                   )
VALUES ('2020-04-20', 5, 10, '962112293V', 2, '947112293V');

# insert a user
INSERT INTO user
    VALUES ('938575739V','Berni', 'Facello', '95-04-20', 'M',0775438923,'berni@gmail.com');

# insert a customer
INSERT INTO customer
    VALUES ('938575739V', '2000-03-29', NULL);

# update rental
UPDATE rental
    SET
        returnDate = '20-03-21',
        dailyRentalDate=75,
        return_to=5,
        payment_status_id=1,
        store_cashier_nic = '947112293V'
    WHERE id = 5;

# delete a rental
DELETE FROM rental
    WHERE id = 5;

# update number of bicycle in store
UPDATE store
    SET number_of_bicycles = (
        SELECT COUNT(*) FROM bicycle
            WHERE store_id = 1 AND status = 'IN'
        )
    WHERE id =1;