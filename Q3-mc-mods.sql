/* FIT9132 2019 S2 Assignment 3 Q3 ANSWERS

   Student Name: Anmol Bagati
    Student ID: 30535808

   Comments to your marker:
   
*/
/* (i)*/

ALTER TABLE booking
ADD booking_status CHAR(1) DEFAULT 'F' NOT NULL
ADD CONSTRAINT check_booking_status CHECK (booking_status IN ('P', 'C', 'F','D'));

UPDATE booking
SET booking_status = 'C'
WHERE sysdate > booking_to;

UPDATE booking
SET booking_status = 'F'
WHERE sysdate < booking_from;

UPDATE booking
SET booking_status = 'P'
WHERE sysdate > booking_from AND sysdate < booking_to;
  
/* (ii)*/

ALTER TABLE guest
ADD (number_of_completed_bookings NUMBER(3) NULL);
UPDATE guest 
SET number_of_completed_bookings = (SELECT COUNT (*) from booking
WHERE booking_status = 'C' AND guest.guest_no = guest_no);


/* (iii)*/

DROP TABLE manager_role;
CREATE TABLE manager_role (
     manager_role_name varchar(50) NOT NULL,
        manager_role_abbreviation char(2) NOT NULL,
       CONSTRAINT manager_role_pk PRIMARY KEY (manager_role_abbreviation));
       
COMMENT ON COLUMN manager_role.manager_role_name IS 
    'manager_role_name is the name of manager role at resort';  

COMMENT ON COLUMN manager_role.manager_role_abbreviation IS 
    'manager_role_abbreviation is role name abbreviated to exactly 2 characters';  

DROP TABLE position;
CREATE TABLE position (
    position_role_abbreviation CHAR(2) NOT NULL,
    resort_id NUMBER(4) NOT NULL,
    manager_id NUMBER(4) NOT NULL,
    CONSTRAINT position_pk PRIMARY KEY ( resort_id, manager_id ));

COMMENT ON COLUMN position.position_role_abbreviation IS 
    'position_role_abbreviation is position of manager in that particular resort';  

COMMENT ON COLUMN position.resort_id IS 
    'resort_id is the unique identifier of resort where manager has a particular position mentioned in psition_role_abbreviation';  

COMMENT ON COLUMN position.manager_id IS 
    'manager_id is unique identifier of the manager';  
    
ALTER TABLE resort
    DROP CONSTRAINT manager_resort;

ALTER TABLE resort 
    DROP COLUMN manager_id;

ALTER TABLE position
    ADD CONSTRAINT resort_position FOREIGN KEY (resort_id)
        REFERENCES resort (resort_id);

ALTER TABLE position
    ADD CONSTRAINT manager_position FOREIGN KEY ( manager_id )
        REFERENCES manager ( manager_id );

ALTER TABLE position
    ADD CONSTRAINT role_position FOREIGN KEY ( position_role_abbreviation )
        REFERENCES manager_role ( manager_role_abbreviation );                                        

INSERT INTO manager_role VALUES ('Bookings Manager','BM');
INSERT INTO manager_role VALUES ('Cleaning Manager','CM');
INSERT INTO manager_role VALUES ('Maintenance Manager','MM');

INSERT INTO resort VALUES (11,'Byron Bay Exclusive Resort','1 Karma Road','2481',4.6,'Y',
                (select town_id from town where town_lat = -28.6474 and town_long =  153.6020)
                ); 

INSERT into position VALUES ((SELECT manager_role_abbreviation FROM manager_role WHERE manager_role_name = 'Bookings Manager'),
                            (SELECT resort_id FROM resort WHERE resort_name = 'Byron Bay Exclusive Resort'),
                            (SELECT manager_id FROM MANAGER WHERE manager_name = 'Lowrance Sellman' AND manager_phone =  '1378452642'));


INSERT into position VALUES ((SELECT manager_role_abbreviation FROM manager_role WHERE manager_role_name = 'Cleaning Manager'),
                            (SELECT resort_id FROM resort WHERE resort_name = 'Byron Bay Exclusive Resort'),
                            (SELECT manager_id FROM manager WHERE manager_name = 'Garrott Gooch' and manager_phone = '6002318099'));
                            
INSERT into position VALUES ((SELECT manager_role_abbreviation FROM manager_role WHERE manager_role_name = 'Maintenance Manager'),
                            (SELECT resort_id FROM resort WHERE resort_name = 'Byron Bay Exclusive Resort'),
                            (SELECT manager_id FROM manager WHERE manager_name = 'Fonsie Tillard' and manager_phone =  '9636535741'));


commit;
