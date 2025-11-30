-- Number of properties that offer each luxury type in LuxuryRentals

SET SEARCH_PATH TO luxuryRentals, public;
DROP TABLE IF EXISTS q1 cascade;

CREATE TABLE q1(
    num_hot_tub INTEGER,
    num_sauna INTEGER,
    num_laundry INTEGER,
    num_daily_cleaning_service INTEGER,
    num_daily_breakfast INTEGER,
    num_concierge INTEGER
);

Insert into q1
Select 
    SUM(CASE WHEN hot_tub THEN 1 ELSE 0 END) AS num_hot_tub,
    SUM(CASE WHEN sauna THEN 1 ELSE 0 END) AS num_sauna,
    SUM(CASE WHEN laundry THEN 1 ELSE 0 END) AS num_laundry,
    SUM(CASE WHEN daily_cleaning THEN 1 ELSE 0 END) AS num_daily_cleaning_service,
    SUM(CASE WHEN daily_breakfast THEN 1 ELSE 0 END) AS num_daily_breakfast,
    SUM(CASE WHEN concierge THEN 1 ELSE 0 END) AS num_concierge
From Luxuries;