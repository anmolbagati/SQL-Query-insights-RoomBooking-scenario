/* FIT9132 2019 S2 Assignment 3 Q4 ANSWERS

   Student Name: Anmol sanjay Bagati
    Student ID: 30535808

   Comments to your marker:
   
*/

/* (i)*/


CREATE OR REPLACE TRIGGER INSERT_BOOKING_TRIGGER
AFTER INSERT OR UPDATE ON booking
FOR EACH ROW
BEGIN
IF :NEW.booking_status = 'C'
THEN
UPDATE guest 
SET number_of_completed_bookings = number_of_completed_bookings + 1
WHERE guest_no = :NEW.guest_no;
END IF;
END;
/*Test Cases*/
/
INSERT INTO booking VALUES (33,TO_DATE('06/04/2019','dd/mm/yyyy'),TO_DATE('09/04/2019','dd/mm/yyyy'),3,1,530,3,1,5,'C');

DELETE FROM booking WHERE booking_id = 33;


/* (ii)*/

CREATE OR REPLACE TRIGGER review_trigger
BEFORE
INSERT
ON review
FOR EACH ROW
DECLARE
resul number;
BEGIN
SELECT COUNT(*)
INTO resul
FROM
(SELECT
    review.review_id
FROM
    review
    JOIN guest 
    ON review.guest_no  = guest.guest_no
    JOIN resort
    ON resort.resort_id = review.resort_id
    LEFT OUTER JOIN booking
    ON booking.resort_id = review.resort_id AND booking.guest_no = guest.guest_no
    WHERE guest.guest_no = : NEW.guest_no AND review.resort_id = : NEW.resort_id
    MINUS
    SELECT
    review.review_id
    FROM 
     review
    JOIN guest  ON review.guest_no  = guest.guest_no
    JOIN resort  ON review.resort_id = review.resort_id
    JOIN booking  ON booking.resort_id = review.resort_id AND booking.guest_no = guest.guest_no);
IF resul = 0
THEN
RAISE_APPLICATION_ERROR(-20998, 'Cant add record as given user hasnt completed a booking in the selected resort');
END IF;
END;


/* Negative Test */
/
INSERT INTO review VALUES (16,'Horrible staff and rude back-answering room service. Nightmare stay. ',TO_DATE('02/03/2019','dd/mm/yyyy'),1,7,1);




/* (iii)*/
DROP TRIGGER Overlap_trigger;
CREATE OR REPLACE TRIGGER Overlap_trigger
BEFORE
INSERT ON booking
FOR EACH ROW
DECLARE
    resu NUMBER;
BEGIN
SELECT COUNT(booking_id) INTO resu
FROM booking
WHERE NOT ((booking_from > : NEW.booking_from
AND booking_from > : NEW.booking_to)
OR
(booking_to < : NEW.booking_to
AND  booking_to < : NEW.booking_from))
AND cabin_no=: NEW.cabin_no
AND resort_id=: NEW.resort_id;

/* When someone checks out on the day of someone else booking the cabin, it will not be allowed */

IF resu > 0 THEN

RAISE_APPLICATION_ERROR(-20997, 'Booking has overlapped! Cannot proceed further');
END IF;
END;


/* Test Case */
DELETE FROM booking WHERE booking_id= 26;
DELETE FROM booking WHERE booking_id= 27;

/
/* negative test case */  INSERT INTO booking VALUES (26,TO_DATE('04/04/2019','dd/mm/yyyy'),TO_DATE('07/04/2019','dd/mm/yyyy'),3,1,530,3,1,5,'C');
/* positive test case */ INSERT INTO booking VALUES (27,TO_DATE('09/04/2020','dd/mm/yyyy'),TO_DATE('11/04/2020','dd/mm/yyyy'),3,1,530,3,1,5,'C');


commit;



