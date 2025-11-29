
DROP SCHEMA IF EXISTS luxuryRentals cascade;
CREATE SCHEMA luxuryRentals;
SET search_path TO luxuryRentals, public;

-- A property that is listed on LuxuryRentals.com 
-- <property_id> denotes the id of the property
-- <host_id> denotes the host of the property
-- <num_bedroom> denotes the number of bedrooms in the property
-- <num_bathroom> denotes the number of bathrooms in the property
-- <capacity> denotes the maximum number of people that can sleep at the property
-- <address> denotes the address of the property
CREATE TABLE Property (
    property_id INTEGER NOT NULL,
    host_id INTEGER NOT NULL,
    num_bedroom INTEGER NOT NULL, 
    num_bathroom INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    address VARCHAR NOT NULL,
    PRIMARY KEY (property_id, host_id)
); -- capacity >= num_bedroom

-- A city property and it's features.
-- <property_id> denotes the id of the property
-- <transit> denotes type of transit closest to the properties (bus, LRT, subway or none)
-- <walkability_score> denotes how walkable property is (range from 0-100) 
CREATE TABLE CityType (
    property_id INTEGER PRIMARY KEY REFERENCES Property,
    transit VARCHAR CHECK transit IN ('bus', 'LRT', 'subway') DEFAULT NULL,
    walkability_score INTEGER NOT NULL,
);

-- A water property and it's features.
-- <property_id> denotes the id of the property.
-- <water_type> denotes the type for water properties (beach, lake or pond)
-- <lifeguard> denotes wehther water type property has a lifeguard.
CREATE TABLE WaterType (
    property_id INTEGER NOT NULL REFERENCES Property,
    water_type VARCHAR NOT NULL, 
    lifeguard BOOL NOT NULL,
    PRIMARY KEY (property_id, water_type)
);


-- A property's list of luxuries
-- <property_id> denotes the id of the property.
-- <hot tub>
-- , sauna, laundry, daily cleaning, daily breakfast, concierge
CREATE TABLE Luxuries (
    property_id INTEGER PRIMARY KEY REFERENCES Property,
    hot_tub BOOL NOT NULL,
    sauna BOOL NOT NULL,
    laundry BOOL NOT NULL,
    daily_cleaning BOOL NOT NULL,
    daily_breakfast BOOL NOT NULL,
    concierge BOOL NOT NULL
);


-- A reservation made for a property
-- <reservation_id> denotes id of the reservation.
-- <property_id> denotes the id of the property.
-- <guest_id> denotes the id of the guest, who is the official renter.
-- <rental> denotes the number of weeks the property is rented for.
-- <start_date> denotes the start date of the rental.
-- <end_date> denotes the end date of the rental.
-- <num_guests> denotes how many guests are under this reservation.
CREATE TABLE Reservation (
    reservation_id INTEGER PRIMARY KEY,
    property_id INTEGER NOT NULL,
    renter_id INTEGER NOT NULL,
    rental INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL
    num_guests INTEGER NOT NULL,
    CONSTRAINT num_guests CHECK Property(property_id, capacity) 
);

-- Guest registered to stay at a property.
-- <guest_id> denotes the id of the guest.
-- <age> denotes age of the guest.
-- <guest_name> denotes name of the guest.
-- <address> denotes the address of the guest.
-- <birth_date> denotes the birth date of the guest.
-- <reservation_id> denotes id of the reservation.
CREATE TABLE Guest (
    guest_id INTEGER PRIMARY KEY,
    age INTEGER NOT NULL,
    guest_name VARCHAR NOT NULL,
    address VARCHAR NOT NULL,
    birth_date TIMESTAMP NOT NULL,
    reservation_id INTEGER NOT NULL REFERENCES Reservation
);

-- The official renter registered to stay at a property.
-- <guest_id> denotes the id of the guest.
-- with the renter for this reservation.
-- <reservation_id> denotes the reservation_id for this renter.
CREATE TABLE OfficialRenter (
    reservation_id INTEGER PRIMARY KEY REFERENCES Reservation,
    renter_id INTEGER NOT NULL REFERENCES Guest
)
-- num_guest cannot exceeed capcacity of property of property_id in reservation_id


-- The Host of the property.
-- <host_id> denotes the id of the host.
-- <property_id> denotes the property owned by the host.
-- <email_address> denotes the email address of the host.
CREATE TABLE Host (
    host_id INTEGER PRIMARY KEY,
    property_id INTEGER NOT NULL,
    email_address VARCHAR NOT NULL
);

-- The rating of the host for a stay.
-- <guest_id> denotes the id of the renter.
-- <reservation_id> denotes the id of the reservation.
-- <host_id> denotes the id of the host.
-- <star_rating> denotes the rating of the host out of 5.
CREATE TABLE RatingHost(
    guest_id INTEGER REFERENCES OfficialRenter,
    reservation_id INTEGER PRIMARY KEY REFERENCES Reservation,
    host_id INTEGER NOT NULL REFERENCES Host,
    star_rating INTEGER NOT NULL CHECK (star_rating <= 5 AND star_rating >= 0),
    PRIMARY KEY(guest_id, reservation_id),
)

-- The rating of the property for a stay.
-- <guest_id> denotes the id of the renter.
-- <reservation_id> denotes the id of the reservation.
-- <star_rating> denotes the rating of the host out of 5, can be NULL if no one has rated it.
-- <comment> denotes the comment left by guests who have rated the property
CREATE TABLE RatingProperty(
    guest_id INTEGER NOT NULL,
    reservation_id INTEGER NOT NULL REFERENCES Reservation,
    star_rating INTEGER, 
    comment VARCHAR, -- can only leave comment if star_rating !NULL
    PRIMARY KEY(guest_id, reservation_id)
)


