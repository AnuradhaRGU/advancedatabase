--ALTER SESSION SET CONTAINER = CDB$ROOT;

--SELECT name, pdb
--FROM   v$services
--ORDER BY name;
--alter session set "_ORACLE_SCRIPT"=true;
--DROP TABLESPACE TBS_SPACEFORMANCE_PERM_ESSEX INCLUDING CONTENTS AND DATAFILES;
--Creating the Permanant Table Space To Store Database
CREATE BIGFILE TABLESPACE TBS_SPACEFORMANCE_PERM_ESSEX
DATAFILE 'tbs_spaceformance_perm_ESSEX.dat'
SIZE 10M
AUTOEXTEND ON;
    
--DROP TABLESPACE TBS_SPACEFORMANCE_ESSEX INCLUDING CONTENTS AND DATAFILES;
--Create The Temporry Table Space to Store the Session Data
CREATE TEMPORARY TABLESPACE TBS_SPACEFORMANCE_ESSEX
TEMPFILE 'tbs_spaceformance_temp_ESSEX.dbf'
SIZE 8M
AUTOEXTEND ON;


--Drop user sfadmin_essex
--Create User set the  Tablespaces  
CREATE USER sfadmin_essex IDENTIFIED BY admin123
  DEFAULT TABLESPACE TBS_SPACEFORMANCE_PERM_ESSEX
  TEMPORARY TABLESPACE TBS_SPACEFORMANCE_ESSEX
  QUOTA 3M on TBS_SPACEFORMANCE_PERM_ESSEX;
  
-- Grant Permission to the  new user
GRANT CREATE SESSION TO sfadmin_essex;
GRANT CREATE TABLE TO sfadmin_essex;
GRANT CREATE VIEW TO sfadmin_essex;
GRANT CREATE ANY TRIGGER TO sfadmin_essex;
GRANT CREATE ANY PROCEDURE TO sfadmin_essex;
GRANT CREATE SEQUENCE TO sfadmin_essex;
GRANT CREATE SYNONYM TO sfadmin_essex;



--set current Schema to the session 
/*in Oracle, users and schemas are essentially the same thing. 
You can consider that a user is the account you use to connect to a database, 
and a schema is the set of objects (tables, views, etc.) */

ALTER SESSION SET current_schema = sfadmin_essex;


CREATE TABLE SF_VENUE (
VenueId VARCHAR2(6) NOT NULL,
Name VARCHAR2(60) NOT NULL,
AddressNo VARCHAR(24) NULL,
Street VARCHAR2(100) NULL,
City VARCHAR2 (40) NULL,
Email VARCHAR2(30) NOT NULL,
ContactPerson VARCHAR2(50) NOT NULL,
CONSTRAINT venue_pk PRIMARY KEY (VenueId)
);


CREATE TABLE SF_VENUE_TELEPHONE (
Id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
VenueId VARCHAR2(8) NOT NULL,
TelephoneNo NUMBER(10),
CONSTRAINT telephone_ck CHECK (LENGTH(TelephoneNo) = 10),
CONSTRAINT fk_VenueId
    FOREIGN KEY (VenueId)
    REFERENCES SF_VENUE(VenueId)
     ON DELETE CASCADE
);

CREATE TABLE SF_EVENT (
EventId VARCHAR2(10) NOT NULL,
VenueId VARCHAR2(6) NOT NULL,
EventName VARCHAR2(50) NOT NULL,
StartDateTime DATE NOT NULL,
EndDateTime DATE NOT NULL,
EventType char(1)  DEFAULT 'M',
NOFTickets Number(4) DEFAULT 0,
CONSTRAINT event_pk PRIMARY KEY (EventId),
CONSTRAINT datetime_ck CHECK (StartDateTime >= EndDateTime),
CONSTRAINT EventType_ck CHECK (EventType IN ('C', 'M')),
CONSTRAINT fk_ev_VenueId  FOREIGN KEY (VenueId) REFERENCES SF_VENUE(VenueId)
);

CREATE TABLE SF_EMPLOYEE (
EmployeeId VARCHAR2(10) NOT NULL,
VenueId VARCHAR2(6) NOT NULL,
Gender CHAR(1) NOT NULL,
FirstName VARCHAR2(50) NOT NULL,
LastName VARCHAR2(50) ,
MiddleName VARCHAR2(50),
AddressNo VARCHAR(24),
Street VARCHAR2(100),
City VARCHAR2 (40),
ContactNumber VARCHAR2(30),
Salary NUMBER(8,2),
CONSTRAINT employee_pk PRIMARY KEY (EmployeeId),
CONSTRAINT fk_emp_VenueId  FOREIGN KEY (VenueId) REFERENCES SF_VENUE(VenueId),
CONSTRAINT gender_emp_ck CHECK (Gender IN ('M', 'F'))
);

CREATE TABLE SF_ARTIST (
ArtistId VARCHAR2(10) NOT NULL,
Title VARCHAR(5),
FirstName VARCHAR2(50) NOT NULL,
LastName VARCHAR2(50) ,
MiddleName VARCHAR2(50),
Gender CHAR(1) NOT NULL,
DOB DATE,
DateJoined DATE DEFAULT SYSDATE,
ArtistType CHAR(1) DEFAULT 'S',
PaymentType VARCHAR2(20) DEFAULT 'CASH',
IsDirector NUMBER(1) DEFAULT 0,
RoleDescription VARCHAR2(200),
ContactNumber VARCHAR2(10),
Payment NUMBER(8,2),
CONSTRAINT artist_pk PRIMARY KEY (ArtistId),
CONSTRAINT gender_artist_ck CHECK (Gender IN ('M', 'F')),
CONSTRAINT dob_Aritis_ck CHECK (DOB > DATE '1900-01-01'),
CONSTRAINT ArtistType_ar_ck CHECK (ArtistType IN ('S', 'A')),
CONSTRAINT PaymentType_ar_ck CHECK (PaymentType IN ('CASH', 'CREADIT CARD','DEBIT CARD')),
CONSTRAINT telephone_ar_ck CHECK (LENGTH(ContactNumber) = 10)
);

CREATE TABLE EVENT_ARTIST (
EventArtistId NUMBER(10) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
EventId VARCHAR2(10) NOT NULL,
ArtistId VARCHAR2(10) NOT NULL,
EmployeeId VARCHAR2(10),
Comments VARCHAR(20),
CONSTRAINT ea_pk PRIMARY KEY (EventArtistId),
CONSTRAINT fk_ea_EventId   FOREIGN KEY (EventId) REFERENCES SF_EVENT(EventId),
CONSTRAINT fk_ea_ArtistId  FOREIGN KEY (ArtistId) REFERENCES SF_ARTIST(ArtistId),
CONSTRAINT fk_ea_EmployeeId  FOREIGN KEY (EmployeeId) REFERENCES SF_EMPLOYEE(EmployeeId)
);

CREATE TABLE EVENT_TALK(
EventTalkId NUMBER(10) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
EventId VARCHAR2(10) NOT NULL,
ArtistId VARCHAR2(10) NOT NULL,
Description VARCHAR(20),
CONSTRAINT fk_et_EventId   FOREIGN KEY (EventId) REFERENCES SF_EVENT(EventId),
CONSTRAINT fk_et_ArtistId  FOREIGN KEY (ArtistId) REFERENCES SF_ARTIST(ArtistId)
);

CREATE TABLE EVENT_PAYMENT(
EventPayentId NUMBER(10) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
EventArtistId NUMBER(10) NOT NULL,
PaymentStatus VARCHAR2(20)  DEFAULT 'PENDING',
CONSTRAINT fk_ep_EventArtistId  FOREIGN KEY (EventArtistId) REFERENCES EVENT_ARTIST(EventArtistId),
CONSTRAINT PaymentTStatus_ep_ck CHECK (PaymentStatus IN ('PENDING', 'PAID','SUSPENDED'))
);

CREATE TABLE SF_MEAL (
MealId VARCHAR2(10) NOT NULL,
VenueId VARCHAR2(6) NOT NULL,
Description VARCHAR2(200),
StartDateTime DATE NOT NULL,
EndDateTime DATE NOT NULL,
NOFTickets Number(4) DEFAULT 0,
CONSTRAINT meal_pk PRIMARY KEY (MealId),
CONSTRAINT datetime_meal_ck CHECK (StartDateTime >= EndDateTime),
CONSTRAINT fk_meal_VenueId  FOREIGN KEY (VenueId) REFERENCES SF_VENUE(VenueId)
);

CREATE TABLE SF_CUSTOMER (
CustomerId VARCHAR2(10) NOT NULL,
SSN VARCHAR2(20) NOT NULL,
Title VARCHAR(5),
Gender CHAR(1) NOT NULL,
FirstName VARCHAR2(50) NOT NULL,
LastName VARCHAR2(50) ,
MiddleName VARCHAR2(50),
AddressNo VARCHAR(24),
Street VARCHAR2(100),
City VARCHAR2 (10),
ContactNumber VARCHAR2(10),
DOB DATE,
CONSTRAINT customer_pk PRIMARY KEY (CustomerId),
CONSTRAINT dob_cus_ck CHECK (DOB > DATE '1920-01-01'),
CONSTRAINT gender_cus_ck CHECK (Gender IN ('M', 'F')),
CONSTRAINT telephone_cus_ck CHECK (LENGTH(ContactNumber) = 10)
);



CREATE TABLE SF_TICKET (
TicketId VARCHAR2(10) NOT NULL,
Price NUMBER(8,2),  
ExpireDate DATE,
SerialNumber VARCHAR2(50) NOT NULL,
CustomerId VARCHAR2(10) NOT NULL,
MealId VARCHAR2(10) NOT NULL,
EventId VARCHAR2(10) NOT NULL,
MelaFlag NUMBER(1) DEFAULT 0,
EventFlag NUMBER(1) DEFAULT 1,
Description VARCHAR2(100),
CONSTRAINT ticket_pk PRIMARY KEY (TicketId),
CONSTRAINT fk_ticket_CustomerId  FOREIGN KEY (CustomerId) REFERENCES SF_CUSTOMER(CustomerId),
CONSTRAINT fk_ticket_MealId  FOREIGN KEY (MealId) REFERENCES SF_MEAL(MealId),
CONSTRAINT fk_ticket_EventId  FOREIGN KEY (EventId) REFERENCES SF_EVENT(EventId)
);



-----------------------------------
INSERT INTO SF_VENUE (VenueId,Name,AddressNo,Street,City,Email,ContactPerson ) 
VALUES ('V00006','West Che''s Hill','RWT 2','Perth and Kinross','Wales','west@gmail.com','Raman Chaudray');
--
INSERT INTO SF_VENUE (VenueId,Name,AddressNo,Street,City,Email,ContactPerson ) 
VALUES ('V00007','West Glamorgan','QWS 0','Castell-nedd Port Talbot','Wales','ess32@yahoo.com','Peter Writes');
--
INSERT INTO SF_VENUE (VenueId,Name,AddressNo,Street,City,Email,ContactPerson ) 
VALUES ('V00008','Sir Fynwy','3671 2','Leeds District','Wales','setd@yahoo.com','Morgan Freeman');

INSERT INTO SF_VENUE (VenueId,Name,AddressNo,Street,City,Email,ContactPerson ) 
VALUES ('V00009','West Glamorgan','WET81 2','Stirling','Wales','redaa@yahoo.com','Tatiayata Wenst');

INSERT INTO SF_VENUE (VenueId,Name,AddressNo,Street,City,Email,ContactPerson ) 
VALUES ('V000010','Gwynedd','WGD 2','Perth and Kinross','Wales','errs@yahoo.com','Glen Macgrath');

INSERT INTO SF_EMPLOYEE VALUES ('E000008','V00006','M','Suffolk','Kent','Ealing','SY9 5','West Midlands','Tyron','7855411112','914')
INSERT INTO SF_EMPLOYEE VALUES ('E000009','V00007','M','Acres','Nook','Wales','BH19 3','Folkestone','Hythe','74524582452','800')

INSERT INTO SF_EMPLOYEE VALUES ('E000010','V00007','M','Rick','Ponting','Breat','E$RW','Suburban Area','Ashford','65851254524','784')
INSERT INTO SF_EMPLOYEE VALUES ('E000011','V00008','M','Cheril','Mark','Clwyd','EW65','Newcastle-under-Lyme District','East','65422212214','656')
INSERT INTO SF_EMPLOYEE VALUES ('E000012','V00008','F','Clwyd','Adabroc','Abington','W3 6','Cheshire East','Bottom','9665544522233','210')

INSERT INTO SF_EMPLOYEE VALUES ('E000013','V00009','F','South Glamorgan','Poll','Abingdon-on-Thames','SY24 5','Sir Ddinbych','Bottom','8556223563','4500')
INSERT INTO SF_EMPLOYEE VALUES ('E000014','V00010','F','Adam''s Green','Dorset','Ceredigion','EH54 9','Vale of White Horse District','Pigotts','89966333','550')

