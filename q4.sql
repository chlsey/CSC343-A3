-- Lure them back

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO luxuryRentals;
DROP TABLE IF EXISTS q4 cascade;

CREATE TABLE q4(
    type VARCHAR CHECK (transit IN ('water', 'city', 'other')),
    extra_guests INTEGER CHECK (extra_guests >= 0)
);


-- Finding the number of extra guests per rental (reservation_id)
DROP VIEW IF EXISTS ExtraGuestsRental CASCADE;

CREATE VIEW ExtraGuestsRental AS
SELECT r.reservation_id, r.property_id, count(s.stay_id) - 1 AS num_extra
FROM Reservation r
JOIN Stay s ON r.reservation_id = s.reservation_id
JOIN Property p ON r.property_id = p.property_id
GROUP BY r.reservation_id;



-- Finding all water type properties
DROP VIEW IF EXISTS WaterProp CASCADE;

CREATE VIEW WaterProp AS
SELECT w.property_id
FROM WaterType w;

-- Finding all city type properties
DROP VIEW IF EXISTS CityProp CASCADE;

CREATE VIEW CityProp AS
SELECT c.property_id
FROM CityType c;


-- Finding all other type properties (not city or water)
DROP VIEW IF EXISTS OtherProp CASCADE;

CREATE VIEW OtherProp AS
((SELECT property_id FROM Property)

EXCEPT (
    SELECT property_id FROM WaterProp
)) 

EXCEPT (
    SELECT property_id FROM CityProp
);



-- averages

-- Finding averages of rentals for water, city, and other property types
DROP VIEW IF EXISTS TypePropAvg CASCADE;

CREATE VIEW TypePropAvg AS
(SELECT 'water' AS type, AVG(r.num_extra) AS extra_guests
FROM ExtraGuestsRental r JOIN WaterProp w ON r.property_id = w.property_id)

UNION

(SELECT 'city' AS type, AVG(r.num_extra) AS extra_guests
FROM ExtraGuestsRental r JOIN CityProp w ON r.property_id = w.property_id)

UNION
(SELECT 'other' AS type, AVG(r.num_extra) AS extra_guests
FROM ExtraGuestsRental r JOIN OtherProp w ON r.property_id = w.property_id));



-- Answer: 
INSERT INTO q4
SELECT type, extra_guests
FROM TypePropAvg;
