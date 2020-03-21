CREATE DATABASE link "Remote_Essex" connect to sfadmin_essex identified by admin123
using '192.168.1.4:1521/xe';

SELECT * from sfadmin_essex.venue@"Remote_Essex" ;

SELECT * from sfadmin_essex.employee@"Remote_Essex" ;


CREATE SYNONYM remote_venue FOR sfadmin_essex.venue@"Remote_Essex" ;
CREATE SYNONYM remote_employee FOR sfadmin_essex.employee@"Remote_Essex" ;

select * from remote_venue;

CREATE VIEW GLOBAL_EMPLOYEE_VIEW AS(

Select re.employeeId,re.firstname,re.gender,rv.venueId,rv.Name,rv.addressNo,rv.street,rv.city from  remote_venue rv 
inner join remote_employee re
On rv.venueId=re.venueid

UNION 

Select re.employeeId,re.firstname,re.gender,rv.venueId,rv.Name,rv.addressNo,rv.street,rv.city from  SFADMIN_MAIN.sf_venue rv 
inner join sfadmin_main.sf_employee re
On rv.venueId=re.venueid
);

SELECT * FROM GLOBAL_EMPLOYEE_VIEW




