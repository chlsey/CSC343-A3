-- Host/ Hosts with the highest average host rating in LuxuryRentals
SET SEARCH_PATH TO luxuryRentals;
DROP TABLE IF EXISTS q3 cascade;

CREATE TABLE q3(
    email_address VARCHAR,
    num_host_ratings INTEGER,
    avg_host_rating FLOAT,
    highest_price INTEGER
);

-- Intermediate steps. 
DROP VIEW IF EXISTS HostRatings CASCADE;
DROP VIEW IF EXISTS HostAvgRatings CASCADE;
DROP VIEW IF EXISTS PropertyPrices CASCADE;
DROP VIEW IF EXISTS ValidHosts CASCADE;

-- Hosts with Ratings.
CREATE VIEW HostRatings AS
SELECT h.host_id, h.email_address, rh.star_rating
From RatingHost rh
JOIN Stay s ON rh.stay_id = s.stay_id
JOIN Reservation r ON s.reservation_id = r.reservation_id
JOIN Property p ON r.property_id = p.property_id
JOIN Host h ON p.host_id = h.host_id;

-- Hosts with their average ratings and number of ratings.
CREATE VIEW HostAvgRatings AS
SELECT hr.host_id, hr.email_address, 
       COUNT(*) AS num_host_ratings,
       AVG(h*) AS avg_host_rating
FROM HostRatings hr
GROUP BY hr.host_id, hr.email_address
HAVING COUNT(*) >= 10;

-- Prices of properties and their respective hosts
CREATE VIEW PropertyPrices AS
SELECT pr.host_id, pr.rates, p.property_id
FROM Property pr
JOIN Prices p ON pr.property_id = p.property_id;

-- Valid Hosts with their highest property price
CREATE VIEW ValidHosts AS
SELECT har.host_id, har.email_address, har.num_host_ratings, har.avg_host_rating,
       MAX(pp.rates) AS highest_price
FROM HostAvgRatings har
JOIN PropertyPrices pp ON har.host_id = pp.host_id
GROUP BY har.host_id, har.email_address, har.num_host_ratings, har.avg_host_rating;

INSERT INTO q3
Select *
FROM ValidHosts
WHERE avg_host_rating = (
    SELECT MAX(avg_host_rating)
    FROM ValidHosts
);