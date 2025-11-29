
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
-- <luxury> denotes the list of luxuries a property has (hot tub, sauna, laundry, daily cleaning, daily breakfast, concierge)
CREATE TABLE Property (
    property_id INTEGER,
    host_id INTEGER,
    num_bedroom INTEGER,
    num_bathroom INTEGER,
    capacity INTEGER,
    address VARCHAR,
    luxury --some list?,
    PRIMARY KEY (property_id, host_id)
); -- capacity >= num_bedroom

-- A city property and it's features.
-- <property_id> denotes the id of the property
-- <transit> denotes type of transit closest to the properties (bus, LRT, subway or none)
-- <walkability_score> denotes how walkable property is (range from 0-100) 
CREATE TABLE CityType (
    property_id INTEGER PRIMARY KEY REFERENCES Property,
    transit VARCHAR,
    walkability_score INTEGER,
);

-- A water property and it's features.
-- <property_id> denotes the id of the property.
-- <water_type> denotes the type for water properties (beach, lake or pond)
-- <lifeguard> denotes wehther water type property has a lifeguard.
CREATE TABLE WaterType (
    property_id INTEGER REFERENCES Property,
    water_type VARCHAR, --list?
    lifeguard BOOL,
    PRIMARY KEY (property_id, water_type)
);

-- A reservation made for a property
-- <reservation_id> denotes if the reservation.
-- <property_id> denotes the id of the property.
-- <guest_id> denotes the id of the guest, who is the official renter.
-- <rental> denotes the number of weeks the property is rented for.
-- <start_date> denotes the start date of the rental.
-- <end_date> denotes the end date of the rental.
CREATE TABLE Reservation (
    reservation_id INTEGER PRIMARY KEY,
    property_id INTEGER,
    renter_id INTEGER,
    rental INTEGER,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
);

-- Guest registered to stay at a property.
-- <guest_id> denotes the id of the guest.
-- <age> denotes age of the guest.
-- <guest_name> denotes name of the guest.
-- <address> denotes the adress of the guest.
-- <birth_date> denotes the birth date of the guest.
CREATE TABLE Guest (
    guest_id INTEGER PRIMARY KEY,
    age INTEGER,
    guest_name VARCHAR,
    address VARCHAR,
    birth_date TIMESTAMP,
);

-- The official renter registered to stay at a property.
-- <guest_id> denotes the id of the guest.
-- <num_guest> denotes the number fo guest registered with this guest.
-- <registered_guests> denotes the list of guests who are registered 
-- with the renter for this reservation.
-- <reservation_id> denotes the reservation_id for this renter.
CREATE TABLE OfficialRenter (
    renter_id INTEGER REFERENCES Guest,
    num_guest INTEGER,
    registered_guests INTEGER --list?,
    reservation_id INTEGER,
)
-- num_guest cannot exceeed capcacity of property of property_id in reservation_id


-- The Host of the property.
-- <host_id> denotes the id of the host.
-- <property_id> denotes the property owned by the host.
-- <email_address> denotes the email address of the host.
CREATE TABLE Host (
    host_id INTEGER,
    property_id INTEGER,
    email_address VARCHAR,
);

-- The rating of the host for a stay.
-- <guest_id> denotes the id of the renter.
-- <reservation_id> denotes the id of the reservation.
-- <host_id> denotes the id of the host.
-- <star_rating> denotes the rating of the host out of 5.
CREATE TABLE RatingHost(
    guest_id INTEGER REFERENCES OfficialRenter;
    reservation_id INTEGER PRIMARY KEY REFERENCES Reservation;
    host_id INTEGER REFERENCES Host;
    star_rating INTEGER;
    PRIMARY KEY(guest_id, reservation_id)
)

-- The rating of the property for a stay.
-- <guest_id> denotes the id of the renter.
-- <reservation_id> denotes the id of the reservation.
-- <star_rating> denotes the rating of the host out of 5.
-- <comment> denotes the comment left by guests who have rated the property
CREATE TABLE RatingProperty(
    guest_id INTEGER;
    reservation_id INTEGER REFERENCES Reservation;
    star_rating INTEGER;
    comment VARCAHR; -- can only leave comment if star_rating !NULL
    PRIMARY KEY(guest_id, reservation_id)
)


