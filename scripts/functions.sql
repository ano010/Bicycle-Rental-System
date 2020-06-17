DROP FUNCTION IF EXISTS get_rental_amount_for_rental;

# get rental amount for given rental id
DELIMITER $$
CREATE FUNCTION get_rental_amount_for_rental(
    rental_id INT
)
RETURNS FLOAT
READS SQL DATA
BEGIN
    DECLARE rental_amount FLOAT;
    DECLARE number_of_days INT;
    DECLARE daily_rental_rate FLOAT;

    SELECT DATEDIFF(returnDate, rentalDate), dailyRentalDate
    INTO  number_of_days, daily_rental_rate
    FROM rental r
    WHERE r.id = rental_id;

    SET rental_amount = number_of_days * daily_rental_rate;

    RETURN IFNULL(rental_amount, 0);
END $$
DELIMITER ;