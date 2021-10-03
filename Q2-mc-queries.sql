/* FIT9132 2019 S2 Assignment 3 Q2 ANSWERS

   Student Name: Anmol Sanjay Bagati
    Student ID: 30535808

   Comments to your marker:
   
*/

/* (i)*/

SELECT resort_name, resort_street_address ||' ' || town_name ||' ' || resort_pcode as "RESORT ADDRESS", manager_name, manager_phone
FROM resort
INNER JOIN town
ON resort.town_id = town.town_id
INNER JOIN manager
ON resort.manager_id = manager.manager_id
WHERE resort_star_rating is NULL AND resort_livein_manager ='Y'
ORDER BY resort_pcode DESC, resort_name;

/* (ii)*/

SELECT resort.resort_id, resort.resort_street_address, town.town_name, town.town_state, resort.resort_pcode, '    $' || SUM(booking.booking_charge) as TOTAL_BOOKING_CHARGES
FROM booking
INNER JOIN resort
ON resort.resort_id = booking.resort_id
INNER JOIN town
ON resort.town_id = town.town_id
GROUP BY resort.resort_id, resort.resort_street_address, town.town_name, town.town_state, resort.resort_pcode
HAVING SUM(booking.booking_charge) > (SELECT AVG(booking_charge) FROM booking)
ORDER BY resort_id;

/* (iii)*/

SELECT review.review_id, guest.guest_no, guest.guest_name, resort.resort_id, resort.resort_name, review.review_comment, review.review_date AS "DATE REVIEWED"
FROM review
INNER JOIN booking
ON booking.guest_no = review.guest_no
INNER JOIN resort
ON booking.resort_id = resort.resort_id
LEFT OUTER JOIN guest
ON booking.guest_no = guest.guest_no AND booking.resort_id = resort.resort_id
MINUS
    (SELECT review.review_id, review.guest_no, guest.guest_name, resort.resort_id, resort.resort_name, review.review_comment, review.review_date AS "DATE_REVIEWED"
    FROM review    
    INNER JOIN guest ON review.guest_no = guest.guest_no
   INNER JOIN resort ON review.resort_id = resort.resort_id
    INNER JOIN booking ON booking.resort_id = resort.resort_id AND booking.guest_no = guest.guest_no);
/* (iv)*/

SELECT DISTINCT resort.resort_id, resort.resort_name, 
'Has ' || (SELECT COUNT(cabin.cabin_no)
           FROM cabin 
           WHERE cabin.resort_id = resort.resort_id) 
           || ' cabins in total with ' || 
            COUNT(cabin.cabin_no)
             || ' having more than 2 bedrooms' as "Accomodation avialable" 
FROM cabin
INNER JOIN resort
ON cabin.resort_id = resort.resort_id
WHERE  cabin.cabin_bedrooms > 2
GROUP BY resort.resort_id, resort.resort_name
ORDER BY resort.resort_name;

/* (v)*/

SELECT DISTINCT resort.resort_id, resort.resort_name,
    (CASE
    WHEN resort.resort_livein_manager = 'Y'
    THEN 'Yes'
    WHEN resort.resort_livein_manager = 'N'
    THEN 'No'

    END) as "LIVE_IN_MANAGER",
    (CASE
    WHEN resort.resort_star_rating is NULL
    THEN 'No Rating'
    ELSE (''||resort.resort_star_rating)
    END) as "STAR RATING", manager.manager_name, manager.manager_phone, NUMBER_OF_BOOKING
FROM resort
INNER JOIN manager
ON resort.manager_id = manager.manager_id
INNER JOIN (SELECT resort_id, COUNT(booking_id) as "NUMBER_OF_BOOKING"
                                                     FROM booking
                                                     GROUP BY resort_id) t
ON t.resort_id = resort.resort_id
WHERE number_of_booking = (SELECT MAX(number_of_booking)
                            FROM 
                                  (SELECT resort_id, COUNT(booking_id) as "NUMBER_OF_BOOKING"
                                   FROM booking
                                   GROUP BY resort_id)) 
                            ORDER BY resort.resort_id;
                                   
/* (vi)*/

SELECT resort.resort_id, resort.resort_name, point_of_interest.poi_name, point_of_interest.poi_street_address, town.town_name, town.town_state,
    (CASE
        WHEN TO_CHAR(point_of_interest.poi_open_time, 'HH24:MI') IS NULL 
        THEN 'Not applicable'
        WHEN TO_CHAR(point_of_interest.poi_open_time, 'HH24:MI') IS NOT NULL 
        THEN TO_CHAR(point_of_interest.poi_open_time, 'HH24:MI')
    END) AS poi_opening_time, 
    (geodistance(town.town_lat, town.town_long,
        (SELECT town.town_lat
         FROM town
         WHERE town.town_id = point_of_interest.town_id),
            (SELECT town.town_long
             FROM town
             WHERE town.town_id = point_of_interest.town_id))) as separation_in_kms
         FROM point_of_interest
         INNER JOIN town
         ON point_of_interest.town_id = town.town_id
         INNER JOIN resort
         ON town.town_id = resort.town_id 
         WHERE (geodistance(town.town_lat, town.town_long,
                (SELECT town.town_lat
                FROM town
                WHERE town.town_id = point_of_interest.town_id),
                    (SELECT town.town_long
                     FROM town
                     WHERE town.town_id = point_of_interest.town_id))) <= 100
ORDER BY resort.resort_name;
