# Views

# retrieve all rental status
CREATE OR REPLACE VIEW rental_status AS
SELECT
    rental.id,
    CONCAT(fname, ' ', lname) AS full_name,
    phone,
    email,
    s1.location AS rent_from,
    s2.location AS return_to,
    rentalDate,
    returnDate,
    IF(status = 'PAID', 'Closed', 'Pending') AS status
FROM rental
JOIN payment_status ps on rental.payment_status_id = ps.id
JOIN customer c on rental.customer_nic = c.nic
JOIN user u on c.nic = u.nic
JOIN store s1 on rental.rent_from = s1.id
JOIN store s2 on rental.return_to = s2.id;

# mostly popular bicycle model among customers
CREATE OR REPLACE VIEW popular_bicycle_model AS
SELECT
    model,
    COUNT(*) AS number_of_rentals
FROM bicycle
JOIN rental r on bicycle.id = r.bicycle_id
GROUP BY model;

# rental balance for each customers
CREATE OR REPLACE VIEW rental_balance_by_customers AS
SELECT
    customer_nic,
    CONCAT(fname, ' ', lname) AS customer,
    phone,
    email,
    SUM(dailyRentalDate * DATEDIFF(returnDate, rentalDate)) AS rental_balance
FROM rental
JOIN payment_status ps on rental.payment_status_id = ps.id
JOIN customer c on rental.customer_nic = c.nic
JOIN user u on c.nic = u.nic
WHERE status = 'NOT PAID'
GROUP BY customer_nic;

# customer details
CREATE OR REPLACE VIEW customer_details AS
SELECT
    customer.nic,
    fname,
    lname,
    dob,
    sex,
    phone,
    email,
    street
    city,
    district,
    country,
    registrationDate,
    lastRentalDate
FROM customer
JOIN user u on customer.nic = u.nic
LEFT JOIN address a on u.nic = a.user_nic;