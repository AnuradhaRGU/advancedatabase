ALTER SESSION SET CONTAINER = xepdb1;

--Creating the Permanant Table Space To Store Database
CREATE BIGFILE TABLESPACE TBS_SPACEFORMANCE_PERM_ORM
DATAFILE 'tbs_spaceformance_perm_03_OR.dat'
SIZE 10M
AUTOEXTEND ON;

--Create The Temporry Table Space to Store the Session Data
CREATE TEMPORARY TABLESPACE TBS_SPACEFORMANCE_ORM
TEMPFILE 'tbs_spaceformance_temp_03_OR.dbf'
SIZE 8M
AUTOEXTEND ON;

--Create User set the  Tablespaces  
CREATE USER sf_admin IDENTIFIED BY admin123
  DEFAULT TABLESPACE TBS_SPACEFORMANCE_PERM_ORM
  TEMPORARY TABLESPACE TBS_SPACEFORMANCE_ORM
  QUOTA 3M on TBS_SPACEFORMANCE_PERM_ORM;
  
  -- Grant Permission to the  new user
GRANT CREATE SESSION TO sf_admin;
GRANT CREATE TABLE TO sf_admin;
GRANT CREATE VIEW TO sf_admin;
GRANT CREATE ANY TRIGGER TO sf_admin;
GRANT CREATE ANY PROCEDURE TO sf_admin;
GRANT CREATE SEQUENCE TO sf_admin;
GRANT CREATE SYNONYM TO sf_admin;

--set current Schema to the session 
/*in Oracle, users and schemas are essentially the same thing. 
You can consider that a user is the account you use to connect to a database, 
and a schema is the set of objects (tables, views, etc.) */

ALTER SESSION SET current_schema = sf_admin

---*******Table Object Creation  
--Creating the Sequencenumber for venue
CREATE SEQUENCE venue_tele_seq MINVALUE 1 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE SEQUENCE venue_eventartist_seq MINVALUE 1 START WITH 1 INCREMENT BY 1 CACHE 20;

CREATE TYPE sf_phonelist AS VARRAY(5) OF NUMBER(10);

--Create Address Object Venue
CREATE TYPE sf_address_obj AS OBJECT (
AddressNo VARCHAR(24),
Street VARCHAR2(100),
City VARCHAR2 (10)
);

---Event Type Creation
CREATE TYPE SF_EVENT_TYPE AS OBJECT (
   EventId VARCHAR2(10),
   EventName VARCHAR2(50),
   StartDateTime DATE,
   EndDateTime DATE,
   EventType char(1),
   NOFTickets Number(4),
   
   MAP MEMBER FUNCTION get_eventId RETURN NUMBER, 
   MEMBER PROCEDURE display_event_details ( SELF IN OUT NOCOPY SF_EVENT_TYPE )
)

---Event Type Method Creation
CREATE TYPE BODY SF_EVENT_TYPE AS
  MAP MEMBER FUNCTION get_eventId RETURN NUMBER IS
  BEGIN
    RETURN EventId;
  END;
  MEMBER PROCEDURE display_event_details ( SELF IN OUT NOCOPY SF_EVENT_TYPE ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(EventId) || ' ' || EventName || ' ' || StartDateTime || ' ' || EndDateTime);
    DBMS_OUTPUT.PUT_LINE(NOFTickets || '');
  END;
END;

-----Creating the Event TypeTable
CREATE TABLE  SF_EVENT OF SF_EVENT_TYPE (
   EventId PRIMARY KEY
)  

---Create Events Collections
CREATE TYPE SF_EVENTS_TYPE AS TABLE OF SF_EVENT_TYPE

-----------------------------------------------------------------------


---------Employee Type Object
CREATE TYPE SF_EMPLOYEE_TYPE AS Object (
   EmployeeId VARCHAR2(10),
   Gender CHAR(1) ,
   FirstName VARCHAR2(50),
   LastName VARCHAR2(50) ,
   MiddleName VARCHAR2(50),
   Address sf_address_obj,
   ContactNumber VARCHAR2(30),
   Salary NUMBER(8,2),
   
   MAP MEMBER FUNCTION get_employheeId RETURN NUMBER, 
   MEMBER PROCEDURE display_employee_details ( SELF IN OUT NOCOPY SF_EMPLOYEE_TYPE )
);

-------Emplyeee Type Body
CREATE TYPE BODY SF_EMPLOYEE_TYPE AS
  MAP MEMBER FUNCTION get_employheeId RETURN NUMBER IS
  BEGIN
    RETURN EmployeeId;
  END;
  MEMBER PROCEDURE display_employee_details ( SELF IN OUT NOCOPY SF_EMPLOYEE_TYPE ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(EmployeeId) || ' ' || FirstName || ' ' || LastName || ' ' || MiddleName);
    DBMS_OUTPUT.PUT_LINE(ContactNumber || '');
  END;
END;

CREATE TABLE  SF_EMPLOYEE OF SF_EMPLOYEE_TYPE (
   PRIMARY KEY(EmployeeId)
);


----------SF_EMPLOYEE_TYPE----------------------
CREATE TYPE SF_EMPLOYEES_TYPE AS TABLE OF SF_EMPLOYEE_TYPE


-------------------------------------------------------------------------------------------
------------------------Meal-------------------------------------

CREATE TYPE SF_MEAL_TYPE AS OBJECT (
   MealId VARCHAR2(10),
   Description VARCHAR2(200),
   StartDateTime DATE ,
   EndDateTime DATE ,
   NOFTickets Number(4)
);

CREATE TABLE SF_MEAL OF SF_MEAL_TYPE (
   MealId PRIMARY KEY
);

CREATE TYPE SF_MEALS_TYPE AS TABLE OF SF_MEAL_TYPE

-----------------------------------------------------------------------
-----------Create Venu Type Object

CREATE TYPE SF_VENUE_TYPE AS OBJECT (
     VenueId VARCHAR2(6),
     Name VARCHAR2(6),
     Email VARCHAR2(30),
     ContactPerson VARCHAR2(50),
     Address sf_address_obj,
     Telephone sf_phonelist,
     Events SF_EVENTS_TYPE,
     Employees SF_EMPLOYEES_TYPE,
     Meals SF_MEALS_TYPE,
     
     MAP MEMBER FUNCTION get_venueId RETURN NUMBER, 
     MEMBER PROCEDURE display_venue_details ( SELF IN OUT NOCOPY SF_VENUE_TYPE )
    );


---VenuType Method Cretion

CREATE TYPE BODY SF_VENUE_TYPE AS
  MAP MEMBER FUNCTION get_venueId RETURN NUMBER IS
  BEGIN
    RETURN VenueId;
  END;
  MEMBER PROCEDURE display_venue_details ( SELF IN OUT NOCOPY SF_VENUE_TYPE ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(VenueId) || ' ' || Name || ' ' || ContactPerson);
    DBMS_OUTPUT.PUT_LINE(Email || '');
  END;
END;

-----Creating the Event TypeTable
CREATE TABLE  SF_VENUE OF SF_VENUE_TYPE (
   VenueId PRIMARY KEY
)  
NESTED TABLE Events STORE AS venue_events
NESTED TABLE Employees STORE AS employees_events
NESTED TABLE Meals STORE AS meals_events;


CREATE TYPE SF_VENUES_TYPE AS TABLE OF SF_VENUE_TYPE

----------------------------------------------------------------------------------

---Create Type SF Aritist Type
CREATE TYPE SF_ARTIST_TYPE  AS OBJECT (
  ArtistId VARCHAR2(10),
  Title VARCHAR(5),
  FirstName VARCHAR2(50),
  LastName VARCHAR2(50) ,
  MiddleName VARCHAR2(50),
  Gender CHAR(1),
  DOB DATE,
  DateJoined DATE,
  ArtistType CHAR(1),
  PaymentType VARCHAR2(20),
  IsDirector NUMBER(1),
  RoleDescription VARCHAR2(200),
  ContactNumber VARCHAR2(10),
  Payment NUMBER(8,2),

  MAP MEMBER FUNCTION get_artistId RETURN NUMBER, 
  MEMBER PROCEDURE display_artist_details ( SELF IN OUT NOCOPY SF_ARTIST_TYPE )
);


CREATE TYPE BODY SF_ARTIST_TYPE AS
  MAP MEMBER FUNCTION get_artistId RETURN NUMBER IS
  BEGIN
    RETURN ArtistId;
  END;
  MEMBER PROCEDURE display_artist_details ( SELF IN OUT NOCOPY SF_ARTIST_TYPE ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(ArtistId) || ' ' || FirstName || ' ' || LastName || ' ' || MiddleName);
    DBMS_OUTPUT.PUT_LINE(ArtistType || '');
  END;
END;

--====================================================================================================

CREATE TABLE  SF_ARTISTS OF SF_ARTIST_TYPE (
   ArtistId PRIMARY KEY
) 

CREATE TYPE SF_ARTISTS_TYPE AS TABLE OF SF_ARTIST_TYPE

--------------------------------------------------------------------------------------

-----------------------------Event Artist -------------------

CREATE TYPE SF_EVENT_ARTIST_TYPE AS OBJECT (
   EventArtistId VARCHAR2(10),
   Event SF_EVENT_TYPE,
   Artist SF_ARTIST_TYPE,
   Employee SF_EMPLOYEE_TYPE,
   Comments VARCHAR(4000),

   MAP MEMBER FUNCTION get_eventartistId RETURN NUMBER, 
   MEMBER PROCEDURE display_eventartist_details ( SELF IN OUT NOCOPY SF_EVENT_ARTIST_TYPE )
)

CREATE TYPE BODY SF_EVENT_ARTIST_TYPE AS
  MAP MEMBER FUNCTION get_eventartistId RETURN NUMBER IS
  BEGIN
    RETURN EventArtistId;
  END;
  MEMBER PROCEDURE display_eventartist_details ( SELF IN OUT NOCOPY SF_EVENT_ARTIST_TYPE ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details--
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(EventArtistId) || ' ' || Event.EventName || ' ' || Event.StartDateTime || ' ' || Event.EndDateTime);
    DBMS_OUTPUT.PUT_LINE(Artist.FirstName || ' ' || Employee.FirstName);
  END;
END;

CREATE TABLE  SF_EVENT_ARTIST OF SF_EVENT_ARTIST_TYPE (
   EventArtistId PRIMARY KEY
) 

CREATE TYPE SF_EVENT_ARTISTS_TYPE AS TABLE OF SF_EVENT_ARTIST_TYPE

----------------------------------------------------------------------------------------

-----------------------------Event Talks------------------- 

CREATE TYPE SF_EVENT_TALK_TYPE AS OBJECT (
   EventTalkId VARCHAR2(10),
   Event SF_EVENT_TYPE,
   Artist SF_ARTIST_TYPE,
   Descriptions VARCHAR(4000),

   MAP MEMBER FUNCTION get_eventtalkId RETURN NUMBER, 
   MEMBER PROCEDURE display_eventtalk_details ( SELF IN OUT NOCOPY SF_EVENT_TALK_TYPE )
)


CREATE TYPE BODY SF_EVENT_TALK_TYPE AS
  MAP MEMBER FUNCTION get_eventtalkId RETURN NUMBER IS
  BEGIN
    RETURN EventTalkId;
  END;
  MEMBER PROCEDURE display_eventtalk_details ( SELF IN OUT NOCOPY SF_EVENT_TALK_TYPE ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details--
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(EventTalkId) || ' ' || Event.EventName || ' ' || Event.StartDateTime || ' ' || Event.EndDateTime);
    DBMS_OUTPUT.PUT_LINE(Artist.FirstName || ' ' );
  END;
END;

CREATE TABLE  SF_EVENT_TALK OF SF_EVENT_TALK_TYPE (
   EventTalkId PRIMARY KEY
) 

CREATE TYPE SF_EVENT_TALKS_TYPE AS TABLE OF SF_EVENT_TALK_TYPE

-------------------------------------------------------------------------------------------


-------------------EVENT PAYMENT---------------------------
CREATE TYPE SF_EVENT_PAYMENT_TYPE AS OBJECT (
   EventPayymentId VARCHAR2(10),
   EventArtist SF_EVENT_ARTIST_TYPE,
   PaymentStatus VARCHAR2(20)
);

CREATE TABLE  SF_EVENT_PAYMENT OF SF_EVENT_PAYMENT_TYPE (
   EventPayymentId PRIMARY KEY
);

CREATE TYPE SF_EVENT_PAYMENTS_TYPE AS TABLE OF SF_EVENT_PAYMENT_TYPE

-----------------------------------------------------------------

----------------------Customer Type
CREATE TYPE SF_CUSTOMER_TYPE  AS OBJECT (
   CustomerId VARCHAR2(10),
   SSN VARCHAR2(20),
   Title VARCHAR(5),
   Gender CHAR(1),
   FirstName VARCHAR2(50),
   LastName VARCHAR2(50) ,
   MiddleName VARCHAR2(50),
   Address sf_address_obj,
   ContactNumber VARCHAR2(10),
   DOB DATE
 );
 
CREATE TABLE SF_CUSTOMER OF SF_CUSTOMER_TYPE (
   CustomerId PRIMARY KEY
);

CREATE TYPE SF_CUSTOMERS_TYPE AS TABLE OF SF_CUSTOMER_TYPE

---------------------------------------------------------------------------------------

---------------------------------------------TICKET-----------------------------------------

CREATE TYPE SF_TICKET_TYPE AS OBJECT (
    TicketId VARCHAR2(10),
    Price NUMBER(8,2),  
    ExpireDate DATE,
    SerialNumber VARCHAR2(50),
    Customer SF_CUSTOMER_TYPE,
    Meal SF_MEAL_TYPE,
    Event SF_EVENT_TYPE,
    MelaFlag NUMBER(1),
    EventFlag NUMBER(1),
    Description VARCHAR2(100),
        
    MAP MEMBER FUNCTION get_ticketId RETURN NUMBER, 
    MEMBER PROCEDURE display_ticketId_details ( SELF IN OUT NOCOPY SF_TICKET_TYPE ) 
);


CREATE TYPE BODY SF_TICKET_TYPE AS
  MAP MEMBER FUNCTION get_ticketId RETURN NUMBER IS
  BEGIN
    RETURN TicketId;
  END;
  MEMBER PROCEDURE display_ticketId_details ( SELF IN OUT NOCOPY SF_TICKET_TYPE ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details--
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(TicketId) || ' ' || Event.EventName || ' ' || Customer.FirstName || ' ' || Customer.LastName);
    DBMS_OUTPUT.PUT_LINE(Meal.Description || ' ' );
  END;
END;

CREATE TABLE SF_TICKET OF SF_TICKET_TYPE (
   TicketId PRIMARY KEY
);

-------------------------------------------------------------------------------------------

