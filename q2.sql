-- At Capacity

SET SEARCH_PATH TO luxuryRentals;
DROP TABLE IF EXISTS q2 cascade;

-- Table should just have two rows where one is for 'at capacity' 
-- and another for 'below'.
CREATE TABLE q2(
    capacity VARCHAR CHECK (capacity IN ('at', 'below')),
    average_rating REAL CHECK (average_rating >= 0 AND average_rating <= 5),
    num_rentals INTEGER
);


-- Finding the number of guests per reservation 
-- (with reservation_id and property_id and property capacity)
DROP VIEW IF EXISTS NumGuestsPerReservation CASCADE;

CREATE VIEW NumGuestsPerReservation AS
SELECT r.reservation_id, count(s.stay_id) AS num_guests, AVG(p.capacity)
FROM Reservation r
JOIN Stay s ON r.reservation_id = s.reservation_id
JOIN Property p ON r.property_id = p.property_id
GROUP BY r.reservation_id;



-- Finding all at capacity rentals/reservations (num_guests = capacity)
DROP VIEW IF EXISTS AtCapacity CASCADE;

CREATE VIEW AtCapacity AS
SELECT n.reservation_id, n.capacity 
FROM NumGuestsPerReservation n
WHERE n.num_guests = n.capacity;


-- Finding all below capacity rentals/reservations
DROP VIEW IF EXISTS BelowCapacity CASCADE;

CREATE VIEW BelowCapacity AS
SELECT n.reservation_id, n.capacity 
FROM NumGuestsPerReservation n
WHERE n.num_guests < n.capacity;


-- Finding the average ratings of per reservation (reservation_id)
DROP VIEW IF EXISTS RentalRatings CASCADE;

CREATE VIEW RentalRatings AS
SELECT s.reservation_id, AVG(r.star_rating) AS average_rate
FROM RatingProperty r
JOIN Stay s ON r.stay_id = s.stay_id
GROUP BY s.reservation_id;


-- Finding the average of at and below capacity rentals
DROP VIEW IF EXISTS AllAverages CASCADE;

CREATE VIEW AllAverages AS
(SELECT 'at' AS capacity, AVG(r.average_rate) AS average_rating, 
    count(reservation_id) AS num_rentals
    FROM AtCapacity a
    JOIN RentalRatings r ON a.reservation_id = r.reservation_id
)

UNION

(SELECT 'below' AS capacity, AVG(r.average_rate) AS average_rating, 
    count(reservation_id) AS num_rentals
    FROM BelowCapacity a
    JOIN RentalRatings r ON a.reservation_id = r.reservation_id
);


-- Answer: The average property rating for rentals that are at 
-- and below capacity.
INSERT INTO q2
SELECT capacity, average_rating, num_rentals
FROM AllAverages;
