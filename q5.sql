-- Price ranges for each property listed in LuxuryRentals
SET SEARCH_PATH TO luxuryRentals, public;
DROP TABLE IF EXISTS q5 cascade;

CREATE TABLE q5(
    property_id INTEGER,
    highest_price REAL,
    lowest_price REAL,
    price_range REAL,
    largest_range VARCHAR
);

-- Intermediate steps. 
DROP VIEW IF EXISTS PropertyPrices CASCADE;
DROP VIEW IF EXISTS PropertyPriceBreakdown CASCADE;
DROP VIEW IF EXISTS MaxPriceRange CASCADE;

-- Prices of properties for every reservation made there
CREATE VIEW PropertyPrices AS
SELECT r.property_id, b.price
FROM Reservation r
JOIN Billing b ON b.reservation_id = r.reservation_id;

-- A price breakdown for each property
CREATE VIEW PropertyPriceBreakdown AS
SELECT
    property_id,
    MAX(price) AS highest_price,
    MIN(price) AS lowest_price,
    MAX(price) - MIN(price) AS price_range
FROM PropertyPrices
GROUP BY property_id;

-- The max price range for all properties
CREATE VIEW MaxPriceRange AS
SELECT MAX(price_range) AS max_price_range
FROM PropertyPriceBreakdown;

INSERT INTO q5
SELECT
    property_id,
    highest_price,
    lowest_price,
    price_range,
    CASE
        WHEN price_range = (SELECT max_price_range FROM MaxPriceRange) THEN '*'
        ELSE ''
    END AS largest_range,
FROM PropertyPriceBreakdown;