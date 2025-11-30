/*
Task 2:

==Could not==
We couldn't enforce the following constraints:
- The constraint that every property must have at least one luxury 
    (by enforcing that each property_id in Property is in Luxuries). 

- The constraint that the number of guests for a reservation is less than
    the capacity of the property that is reserved (in table Reservation).

- The constraint that the age of the renter of the property/reservation
     is 18 by the start date of the reservation.

- The constraint that reservations dates for the same property cannot overlap.

-- The constraint that there must be one entry in the OfficialRenter table for 
    each reservation (reservation_id).



==Did not==
- We did not do any implementations w.r.t. the fact that a week starts on
    a Saturday since it's unclear whether a reservation should always 
    start on a Saturday, or end on a Friday. 

- We did not implement anything to ensure that the renter is in charge of 
    taking care of the property since the instruction was too vague.



==Extra Constraints==
- The renter cannot leave a comment on a host, only a rating. We enforced this
    because the guest can just leave a comment on the host in the property 
    comment rating.


==Assumptions==
We made the following assumptions:
- The end date of the rental does not have to end on a Friday 
    (last day of the week).

- The start date of a rental period does not have to start on a Saturday.

- We only keep track of billed prices by the week, so prices for properties 
    cannot change in the middle of a week.

- A property does not have to be a City Property or a Water Property.

- Guests can give a rating of 0.

- The renter does not need to leave a comment on a host.

*/



DROP SCHEMA IF EXISTS luxuryRentals cascade;
CREATE SCHEMA luxuryRentals;
SET search_path TO luxuryRentals, public;


-- The Host of the property.
-- <host_id> denotes the id of the host.
-- <email_address> denotes the email address of the host.
CREATE TABLE Host (
    host_id INTEGER PRIMARY KEY,
    email_address VARCHAR NOT NULL
);


-- A property that is listed on LuxuryRentals.com 
-- <property_id> denotes the id of the property
-- <host_id> denotes the id of the host.
-- <num_bedroom> denotes the number of bedrooms in the property
-- <num_bathroom> denotes the number of bathrooms in the property
-- <capacity> denotes the maximum number of people that can sleep at the property
-- <address> denotes the address of the property
CREATE TABLE Property (
    property_id INTEGER PRIMARY KEY,
    host_id INTEGER REFERENCES Host,
    num_bedroom INTEGER NOT NULL, 
    num_bathroom INTEGER NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity >= num_bedroom),
    address VARCHAR NOT NULL
);

-- ADDITIONAL CONSTRAINT: property_id must be in Luxuries.


-- A city property and its features.
-- <property_id> denotes the id of the property
-- <transit> denotes type of transit closest to the properties.
-- <transit> must be in (bus, LRT, subway or none/NULL).
-- <walkability_score> denotes how walkable property is (range from 0-100) 
CREATE TABLE CityType (
    property_id INTEGER PRIMARY KEY REFERENCES Property,
    transit VARCHAR CHECK (transit IN ('bus', 'LRT', 'subway')) DEFAULT NULL,
    walkability_score INTEGER NOT NULL 
    CHECK (walkability_score >= 0 AND walkability_score <= 100)
);


-- A water property and its features.
-- <property_id> denotes the id of the property.
-- <water_type> denotes the type for water properties (beach, lake or pond).
-- <lifeguard> denotes wehther water type property has a lifeguard.
CREATE TABLE WaterType (
    property_id INTEGER NOT NULL REFERENCES Property,
    water_type VARCHAR NOT NULL 
    CHECK (water_type IN ('beach', 'lake', 'pool')), 
    lifeguard BOOL NOT NULL,
    PRIMARY KEY (property_id, water_type)
);


-- A property's list of luxuries
-- <property_id> denotes the id of the property.
-- <hot tub> denotes whether the property has a hot tub.
-- <sauna> denotes whether the property has a sauna.
-- <laundry> denotes whether the property has a laundry.
-- <daily_cleaning> denotes whether the property has daily cleaning.
-- <daily_breakfast> denotes whether the property has daily breakfast delivery.
-- <concierge> denotes whether the property has concierge service.
CREATE TABLE Luxuries (
    property_id INTEGER PRIMARY KEY REFERENCES Property,
    hot_tub BOOL NOT NULL,
    sauna BOOL NOT NULL,
    laundry BOOL NOT NULL,
    daily_cleaning BOOL NOT NULL,
    daily_breakfast BOOL NOT NULL,
    concierge BOOL NOT NULL, 
    CONSTRAINT luxuries_at_least_one CHECK (
        hot_tub OR sauna OR laundry OR daily_cleaning 
        OR daily_breakfast OR concierge
    )
);



-- A reservation made for a property
-- <reservation_id> denotes id of the reservation.
-- <property_id> denotes the id of the property.
-- <rental_weeks> denotes the number of weeks the property is rented for.
-- <start_date> denotes the start date of the rental.
-- <rental_weeks> denotes the number of weeks for the rental.
-- <num_guests> denotes how many guests are under this reservation.
CREATE TABLE Reservation (
    reservation_id INTEGER PRIMARY KEY,
    property_id INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    rental_weeks INTEGER NOT NULL,
    num_guests INTEGER NOT NULL CHECK (num_guests >= 0),
);

-- ADDITIONAL CONSTRAINTS: num_guests <= capacity of the property
-- Reservations for the same property cannot overlap in time.
-- There must be one entry in the OfficialRenter table for reservation_id.


-- A table for the current prices of a property.
-- <property_id> denotes the id of the property.
-- <rates> denotes the per week rental price of the property.
CREATE TABLE Prices (
    property_id INTEGER PRIMARY KEY REFERENCES Property,
    rates REAL NOT NULL,
);


-- A table for the billing details of a reservation.
-- <billing_id> denotes the unique identifier for each billing record.
-- <reservation_id> denotes the reservation this billing entry belongs to.
-- <week_start> denotes the start date of the billed week.
-- <week_end> denotes the end date of the billed week.
-- <price> denotes the price charged for this specific week.
CREATE TABLE Billing (
    billing_id INTEGER PRIMARY KEY,
    reservation_id INTEGER REFERENCES Reservation,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    price REAL NOT NULL CHECK (price >= 0)
);


-- Guest registered with luxuryRentals.
-- <guest_id> denotes the id of the guest.
-- <guest_name> denotes name of the guest.
-- <address> denotes the address of the guest.
-- <birth_date> denotes the birth date of the guest.
CREATE TABLE Guest (
    guest_id INTEGER PRIMARY KEY,
    guest_name VARCHAR NOT NULL,
    address VARCHAR NOT NULL,
    birth_date TIMESTAMP NOT NULL
);


-- Guest registered with a reservation.
-- <stay_id> denotes id of a stay (a guest stayed at a reservation).
-- <guest_id> denotes the id of the guest.
-- <reservation_id> denotes id of the reservation.
CREATE TABLE Stay (
    stay_id INTEGER PRIMARY KEY,
    guest_id INTEGER NOT NULL REFERENCES Guest,
    reservation_id INTEGER NOT NULL REFERENCES Reservation
);


-- The official renter registered to stay at a property.
-- <stay_id> denotes id of a stay.
-- <card_num> the credit card info of the renter.
CREATE TABLE OfficialRenter (
    stay_id INTEGER PRIMARY KEY REFERENCES Stay,
    card_num INTEGER NOT NULL
);
-- ADDITIONAL CONSTRAINT: age of (stay_id in Stay) renter must be 18 by 
-- the start date of the reservation (stay_id in Stay)



-- To do with Ratings

-- The possible values of a rating.
DROP DOMAIN IF EXISTS rating;
CREATE DOMAIN rating AS smallint 
    DEFAULT NULL
    CHECK (VALUE >= 0 AND VALUE <= 5);


-- The rating of the host for a stay.
-- <stay_id> denotes id of a stay.
-- <star_rating> denotes the rating of the host out of 5.
CREATE TABLE RatingHost(
    stay_id INTEGER PRIMARY KEY REFERENCES OfficialRenter,
    star_rating rating NOT NULL
);


-- The rating of the property for a stay.
-- <stay_id> denotes id of a stay.
-- <rating_id> denotes the rating id of the rating.
-- <star_rating> denotes the rating of the host out of 5.
CREATE TABLE RatingProperty(
    stay_id INTEGER PRIMARY KEY REFERENCES Stay,
    rating_id INTEGER NOT NULL UNIQUE,
    star_rating rating NOT NULL
);


-- The comments of the property for a rating.
-- <rating_id> denotes the rating id of the rating.
-- <comment> denotes the comment left by guests who have already rated.
CREATE TABLE CommentProperty(
    rating_id INTEGER PRIMARY KEY REFERENCES RatingProperty,
    comment VARCHAR NOT NULL
);