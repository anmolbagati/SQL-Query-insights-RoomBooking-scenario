/* FIT9132 2019 S2 Assignment 3 Q1-Part B ANSWERS

   Student Name: Anmol Sanjay Bagati
    Student ID: 30535808

   Comments to your marker:
   
*/

/* (i)*/

DROP SEQUENCE resort_sequence; /* To drop sequence before running the query */

CREATE SEQUENCE resort_sequence
START WITH 100
INCREMENT BY 1;

/* (ii)*/

INSERT INTO resort VALUES (resort_sequence.NEXTVAL, 'Awesome Resort','50 Awesome Road','4830',NULL,'N',
( 
SELECT town_id 
FROM town
WHERE town_long = 139.4927 and town_lat = -20.7256
),
(
SELECT manager_id
FROM manager
WHERE manager_name = 'Garrott Gooch' and manager_phone = '6002318099'
)
);

/* (iii)*/

DROP SEQUENCE awesome_cabin_sequence;  /* To drop sequence before running the query */
CREATE SEQUENCE awesome_cabin_sequence
START WITH 1
INCREMENT BY 1;

INSERT INTO cabin VALUES (awesome_cabin_sequence.NEXTVAL,
(
SELECT resort_id
FROM resort
WHERE resort_name = 'Awesome Resort'
),
3,6,'Free wi-Fi. kitchen with 400 ltr refrigerator, stove, microwave, pots, pans, silverware, toaster, electric kettle, TV and utensils');

INSERT INTO cabin VALUES (awesome_cabin_sequence.NEXTVAL,
(SELECT resort_id
FROM resort
WHERE resort_name = 'Awesome Resort'
),
2,4,'Free wi-Fi. kitchen with 280 ltr refrigerator, stove, pots, pans, silverware, toaster, electric kettle, TV and utensils');

UPDATE resort
SET resort_livein_manager = 'N'
WHERE manager_id = 
(
SELECT  manager_id
FROM manager
WHERE manager_name ='Fonsie Tillard' and manager_phone ='9636535741'
);

UPDATE resort
SET manager_id = 
( 
SELECT manager_id
FROM manager
WHERE manager_name = 'Fonsie Tillard' and manager_phone ='9636535741'
) ,
resort_livein_manager = 'Y' 
WHERE resort_name = 'Awesome Resort'; 
   
/* (iv)*/

/* ASSUMPTION : Not deleting any entry from the review table even though its a child table, because the resort has had no bookings so its assumed that no bookings led to no reviews */

DELETE FROM cabin
WHERE resort_id =
(
SELECT resort_id
FROM resort
WHERE resort_name = 'Awesome Resort');

DELETE FROM resort

WHERE resort_name = 'Awesome Resort';

commit;






