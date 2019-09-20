spool C:\GRM\myresultsDDL3.txt
 
--Set echo on so that you can see the input as well in the spool file
set echo on;
 
--Garth Mortensen

--MILESTONE 1---------------------------------------------------------
--DROP ASSIGNMENT 1---------------------------------------------------
alter TABLE ACCOUNT
   drop constraint FK_ACCOUNT_CONTAINS_BRANCH;
alter TABLE ACCOUNT
   drop constraint FK_ACCOUNT_OWNS_CUSTOMER;
alter TABLE LOAN
   drop constraint FK_LOAN_HAS_CUSTOMER;
alter TABLE LOAN
   drop constraint FK_LOAN_IS_LOCATE_BRANCH;
drop index CONTAINS_FK;
drop index OWNS_FK;
drop TABLE ACCOUNT cascade constraints;
drop TABLE BRANCH cascade constraints;
drop TABLE CUSTOMER cascade constraints;
drop index IS_LOCATED_AT_FK;
drop index HAS_FK;
drop TABLE LOAN cascade constraints;
 
--DROP PROJECT CONSTRAINTS------------------------------------------------
-- alter TABLE Person
-- drop constraint FK_ACCOUNT_CONTAINS_BRANCH;
 
--DROP TABLES-----------------------------------------------------------------
--This allows us to clear any possible conflicts with other assignments
--Could not re-create TABLE Person until this was done
--not all of these may be necassary, but at least everything is being flushed
drop TABLE Person cascade constraints;
drop TABLE College cascade constraints;
drop TABLE Department cascade constraints;
drop TABLE Student cascade constraints;
drop TABLE Gradstudent cascade constraints;
drop TABLE Tutor cascade constraints;
drop TABLE WorksOn cascade constraints;
drop TABLE Faculty cascade constraints;
drop TABLE Course cascade constraints;
drop TABLE Section cascade constraints;
drop TABLE Own cascade constraints;
drop TABLE Project cascade constraints;
drop TABLE Contains cascade constraints;
drop TABLE Declare cascade constraints;
drop TABLE Grades cascade constraints;
drop TABLE Register cascade constraints;
 
--CREATE TABLES AND PKs--------------------------------------------------------------
 
CREATE TABLE Person
(
	pkssn VARCHAR(11) NOT NULL,
	dob DATE NOT NULL,
	sex CHAR(1),
	address VARCHAR(99), --we need to create street, city, zip, state
	name VARCHAR(73) NOT NULL, --we need to create first name, mi, last name
	fksupssn VARCHAR(11) NOT NULL,
	CONSTRAINT PK_Person PRIMARY KEY (pkssn)
);
 
CREATE TABLE College
(
	pkclname VARCHAR(30) NOT NULL,			
	dean VARCHAR(30) NOT NULL,
	CONSTRAINT PK_College PRIMARY KEY (pkclname) --worked in Oracle for me
);
 
CREATE TABLE Department
(
	pkdname VARCHAR(30) NOT NULL,
	office VARCHAR(30),
	dphone NUMBER(15),
	fkclname VARCHAR(30) NOT NULL, --not dependent, bc not null
	fkfacssn VARCHAR(11) NOT NULL, --faculty chair
	CONSTRAINT PK_Department PRIMARY KEY (pkdname)
);
 
CREATE TABLE Student
(
	pkstudssn VARCHAR(11) NOT NULL references Person (pkssn), --Is-a
	class VARCHAR(30),
	fkdname VARCHAR(30) NOT NULL,
	fksssn VARCHAR(11) NOT NULL,
	CONSTRAINT PK_Student PRIMARY KEY (pkstudssn)
);
 
CREATE TABLE Gradstudent
(
	pkgradstudssn VARCHAR(11) NOT NULL references Student (pkstudssn), --Is-a
	degree VARCHAR(30),
	fkfacssn VARCHAR(11) NOT NULL, --faculty advisor
	CONSTRAINT PK_Gradstudent PRIMARY KEY (pkgradstudssn)
);
 
CREATE TABLE Faculty
(
	pkfacssn VARCHAR(11) NOT NULL references Person (pkssn), --Is-a
	fphone NUMBER(15),
	foffice VARCHAR(30),
	rank VARCHAR(30),
	salary NUMBER(8,2) NOT NULL,
	fkdname VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Faculty PRIMARY KEY (pkfacssn)
);
		
CREATE TABLE Course
(
	pkcnum VARCHAR(10) NOT NULL,
	cname VARCHAR(30) NOT NULL,
	fkdname VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Course PRIMARY KEY (pkcnum)
);
 
CREATE TABLE Project
(
	pkpid CHAR(30) NOT NULL,
	pdate DATE,
	amount NUMBER(8,2),
	fkpid CHAR(30) NOT NULL,
	CONSTRAINT PK_Project PRIMARY KEY (pkpid)
);
 
 
--Confirmed that this works in Oracle below (did not need to move PK statement after all)
 
CREATE TABLE Section
(
	year NUMBER(4) NOT NULL,
	semester VARCHAR(12) NOT NULL,	
	secnum NUMBER(3) NOT NULL,
	fkcnum VARCHAR(10) NOT NULL,
    fkfacssn VARCHAR(11) NOT NULL, --Missing comma after fkfacssn
	CONSTRAINT PK_Section PRIMARY KEY (fkcnum, year, semester, secnum)
);
 
CREATE TABLE Contains
(
	fkyear NUMBER(4) NOT NULL,
	fksemester VARCHAR(12) NOT NULL,
	fksecnum NUMBER(3) NOT NULL,
	fkfacssn VARCHAR(11) NOT NULL,
	fkcnum VARCHAR(10) NOT NULL,
	CONSTRAINT PK_Contains PRIMARY KEY (fkcnum, fkyear, fksemester, fksecnum)
);
 
CREATE TABLE Declare
(
	major VARCHAR(30),
	fkstudssn VARCHAR(11) NOT NULL, --this can refer to pkstudssn, maybe student or person. try
	fkdname VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Declare PRIMARY KEY (fkstudssn, fkdname)
);
 
CREATE TABLE WorksOn
(
	fkgradstudssn VARCHAR(11) NOT NULL, --this can refer to pkgradstudssn, maybe student or person. try
	fkpid CHAR(30) NOT NULL,
	CONSTRAINT PK_WorksOn PRIMARY KEY (fkgradstudssn, fkpid)
);
 
CREATE TABLE Own
(
	fkfacssn VARCHAR(11) NOT NULL,
	fkpid CHAR(30) NOT NULL,
	CONSTRAINT PK_Own PRIMARY KEY (fkfacssn, fkpid)
);
 
CREATE TABLE Grades
(
	grade CHAR(2),
	fkstudssn VARCHAR(11) NOT NULL, --maybe not null
	fkyear NUMBER(4) NOT NULL,
	fksemester VARCHAR(12) NOT NULL,	
	fksecnum NUMBER(3) NOT NULL,
	fkcnum VARCHAR(10) NOT NULL,
	CONSTRAINT PK_Grades PRIMARY KEY (fkstudssn, fkyear, fksemester, fksecnum, fkcnum)
);
 
CREATE TABLE Tutor
(
  fkgradstudssn VARCHAR(11) NOT NULL, --this can refer to pkgradstudssn, maybe student or person.
  fkyear NUMBER(4) NOT NULL,
  fksemester VARCHAR(12) NOT NULL,
  fksecnum NUMBER(3) NOT NULL,
  fkcnum VARCHAR(10) NOT NULL,
  CONSTRAINT PK_Tutor PRIMARY KEY (fkgradstudssn, fkyear, fksemester, fksecnum, fkcnum)
);
 
CREATE TABLE Register
(
	fkstudssn VARCHAR(11) NOT NULL,
	fkyear NUMBER(4) NOT NULL,
	fksemester VARCHAR(12) NOT NULL,	
	fksecnum NUMBER(3) NOT NULL,
	fkcnum VARCHAR(10) NOT NULL,
	CONSTRAINT PK_Register PRIMARY KEY (fkstudssn, fkyear, fksemester, fksecnum, fkcnum)
);
 
--FOREIGN KEYS------------------------------------------------------------------
--ONE TO MANY------------------------------------------------------------------
 
-- Section depends on Course. A course may have many sections.
ALTER TABLE Section
ADD CONSTRAINT Contains FOREIGN KEY (fkcnum) REFERENCES Course (pkcnum);
 
-- A professor may teach many course sections.
-- A course section must have one professor as the instructor.
ALTER TABLE Section
ADD CONSTRAINT Teach FOREIGN KEY (fkfacssn) REFERENCES Faculty (pkfacssn);
 
-- A professor may advise many GradStudents.
-- A GradStudent must have a professor as the advisor.
ALTER TABLE Gradstudent
ADD CONSTRAINT Advise FOREIGN KEY (fkfacssn) REFERENCES Faculty (pkfacssn);
 
-- A professor may be a department chair.
-- A department must have one professor as its chair.
ALTER TABLE Department
ADD CONSTRAINT Chair FOREIGN KEY (fkfacssn) REFERENCES Faculty (pkfacssn);
 
-- Many professors may work in a department.
-- A professor only works for one department.
ALTER TABLE Faculty
ADD CONSTRAINT Works FOREIGN KEY (fkdname) REFERENCES Department (pkdname);
 
-- A department may have many major students.
-- A student must have only one major.
ALTER TABLE Student
ADD CONSTRAINT Declare FOREIGN KEY (fkdname) REFERENCES Department (pkdname);
 
-- A department may offer many course.
-- A course must be offered by only one department.
ALTER TABLE Course
ADD CONSTRAINT Offer FOREIGN KEY (fkdname) REFERENCES Department (pkdname);
 
-- A college may have many departments within it.
-- A department must be within only one college.
ALTER TABLE Department
ADD CONSTRAINT Have FOREIGN KEY (fkclname) REFERENCES College (pkclname);
 
--MANY TO MANY------------------------------------------------------------------
-- A GradStudent may work on many Projects.
ALTER TABLE WorksOn
ADD CONSTRAINT GradStudWorks FOREIGN KEY (fkgradstudssn) REFERENCES GradStudent (pkgradstudssn);
-- A Project may have many GradStudent participants.
ALTER TABLE WorksOn
ADD CONSTRAINT ProjectWorkedOn FOREIGN KEY (fkpid) REFERENCES Project (pkpid);
 
-- A professor may own many Projects.
ALTER TABLE Own
ADD CONSTRAINT ProfessorOwns FOREIGN KEY (fkfacssn) REFERENCES Faculty (pkfacssn);
-- A project may be owned by many professors.
ALTER TABLE Own
ADD CONSTRAINT ProjectOwned FOREIGN KEY (fkpid) REFERENCES Project (pkpid);
 
-- A student may register for many different course sections.
ALTER TABLE Register
ADD CONSTRAINT StudentsRegisterIn FOREIGN KEY (fkstudssn) REFERENCES Student (pkstudssn);
-- A course section may have many students. THIS IS STRANGE===============
ALTER TABLE Register
ADD CONSTRAINT HasRegisteredStudents FOREIGN KEY (fkcnum, fkyear, fksemester, fksecnum) REFERENCES Section (fkcnum, year, semester, secnum);
  
-- A student may earn grade from many course sections.
ALTER TABLE Grades
ADD CONSTRAINT EarnGrades FOREIGN KEY (fkstudssn) REFERENCES Student (pkstudssn);
-- A course section may give grades to many students.
ALTER TABLE Grades
ADD CONSTRAINT GiveGrades FOREIGN KEY (fkcnum, fkyear, fksemester, fksecnum) REFERENCES Section (fkcnum, year, semester, secnum);
 
-- A GradStudent may tutor many course sections.
ALTER TABLE Tutor
ADD CONSTRAINT GradStudentTutors FOREIGN KEY (fkgradstudssn) REFERENCES GradStudent (pkgradstudssn);
-- A course section may have many tutors.
ALTER TABLE Tutor
ADD CONSTRAINT SectionTutoredBy FOREIGN KEY (fkcnum, fkyear, fksemester, fksecnum) REFERENCES Section (fkcnum, year, semester, secnum);
 

--MILESTONE 2---------------------------------------------------------
--CREATE VIEWS--
--0 format columns so they display properly in views, for question 7
set wrap off
column table_name format a10
column column_name format a10
column data_type format a10
set linesize 100
set long 20000
--drop the old views
DROP VIEW EntitynameView;
DROP VIEW AttributenameView;
DROP VIEW KeynameView;
DROP VIEW EntitynameAttributenameView;
DROP VIEW RelationshipnameEntitynameView;
DROP VIEW AttributenameAttributetypeView;
DROP VIEW EntitynameKeynameView;

--1 show all entity names
CREATE VIEW EntitynameView AS
SELECT table_name Entityname
FROM user_tables;
SELECT * FROM EntitynameView;

--2 show all attribute names
CREATE VIEW AttributenameView AS
SELECT column_name Attributename
FROM user_tab_columns;
SELECT * FROM AttributenameView;

--3 show all key names
CREATE VIEW KeynameView AS
SELECT user_cons_columns.column_name Keyname
FROM user_constraints, user_cons_columns
WHERE user_constraints.constraint_type = 'P'
AND user_constraints.constraint_name = user_cons_columns.constraint_name
AND user_constraints.owner = user_cons_columns.owner;
SELECT * FROM KeynameView;

--4 show all entity names, attribute names
CREATE VIEW EntitynameAttributenameView AS
SELECT table_name Entityname, column_name Attributename
FROM user_tab_columns;

SELECT * FROM EntitynameAttributenameView;

--5 show all relationshipname, entityname
CREATE VIEW RelationshipnameEntitynameView AS
SELECT a.constraint_name Relationshipname, a.table_name Entityname
FROM all_cons_columns a
  JOIN user_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN user_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R'
UNION
SELECT a.constraint_name,
       c_pk.table_name r_table_name
  FROM all_cons_columns a
  JOIN user_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN user_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R';
SELECT * FROM RelationshipnameEntitynameView;

--6 show all attributename, attributetype
CREATE VIEW AttributenameAttributetypeView AS
SELECT column_name Attributename, data_type Attributetype
FROM user_tab_columns;
SELECT * FROM AttributenameAttributetypeView;

--7 show all entityname, keyname
CREATE VIEW EntitynameKeynameView AS
SELECT table_name Entityname, column_name Keyname
FROM user_cons_columns;

SELECT * FROM EntitynameKeynameView;

--MILESTONE 3---------------------------------------------------------

--1. Print the name of all relationships and the two entities they relate and the cardinality for each side of the relationship.

--Suggested changes: 1) ‘U’ to ‘R’, 2) add count to make it case count and 3) add numbers to when like when 1 then ‘1’? Have not tried or tested those yet):

Column T_NAME format a10
Column cons format a15
Column cardinality format a5
Column r_T_NAME format a10
Column r_cons format a15
Column ref_cardinality format a5
SELECT a.table_name T_NAME, a.constraint_name CONS, 
	   case 
			when 'U' in 
			(--check other constraint type on this column
				select c_other.constraint_type 
				from all_cons_columns a2, all_constraints c_other 
				where a.table_name=a2.table_name AND
					  a.column_name=a2.column_name AND
					  a2.constraint_name=c_other.constraint_name
			) 
			then '1'
			else 'M'
	   end cardinality,	   
       c_ref.table_name r_t_name, c_ref.constraint_name r_cons,
	   case
			when c_ref.constraint_type in ('P','U') then '1'
			else 'M'
	   end ref_cardinality
FROM all_cons_columns a, all_constraints c, all_constraints c_ref
WHERE a.constraint_name = c.constraint_name AND
        c.r_constraint_name = c_ref.constraint_name AND
		a.owner = c.owner AND
		c.owner = c_ref.owner AND
		lower(a.owner) = 'EIB' AND
		c.constraint_type = 'R' ; 

--2. Print the name of all relationships that have a cardinality of 1-to-1.
--All constraints/relationships with foreign key R,  count = 1
COLUMN constraint_name FORMAT A25
SELECT UCC.CONSTRAINT_NAME AS Relationship
FROM USER_CONS_COLUMNS UCC, USER_CONSTRAINTS UC
WHERE UCC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
AND UC.constraint_type = 'R'
ORDER BY UCC.CONSTRAINT_NAME;
	--”GROUP BY a.constraint_name
	--HAVING COUNT (a.constraint_name)=1;”

--3. Print the name of all relationships that have a cardinality of 1-to-M.
--All constraints/relationships with foreign key R, count > 1
COLUMN constraint_name FORMAT A25
SELECT UCC.CONSTRAINT_NAME AS Relationship
FROM USER_CONS_COLUMNS UCC, USER_CONSTRAINTS UC
WHERE UCC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
AND UC.constraint_type = 'R'
ORDER BY UCC.CONSTRAINT_NAME;
	--”GROUP BY a.constraint_name
	--HAVING COUNT (a.constraint_name)>1;”

--4. Print the name of all relationships that have a cardinality of many-to-many.
--All constraints/relationships with foreign key R, count > 1
COLUMN constraint_name FORMAT A25
SELECT UCC.CONSTRAINT_NAME AS Relationship
FROM USER_CONS_COLUMNS UCC, USER_CONSTRAINTS UC
WHERE UCC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
AND UC.constraint_type = 'R'
ORDER BY UCC.CONSTRAINT_NAME;
	--”GROUP BY a.constraint_name
	--HAVING COUNT (a.constraint_name)>1;”

--5. Print the name of all relationships that have attribute(s) as well as the name(s) of the attribute(s).
SELECT UNIQUE table_name, column_name
FROM user_tab_columns, RelationshipnameEntitynameView re
WHERE table_name LIKE re.Entityname;

--6. Print the name of all relationships that do not have attribute(s).
Select distinct re.Relationshipname
FROM user_tab_columns, RelationshipnameEntitynameView re
WHERE table_name NOT LIKE re.Entityname;

--7. Print the names of all attributes that have a date data type.
SELECT column_name
FROM user_tab_columns
WHERE data_type = 'DATE';

--8. Print the names of all entities that are directly related to entity Student (directly means via only one relationship).
SELECT UNIQUE table_name
FROM user_tab_columns
WHERE column_name = 'FKSTUDSSN' OR
	column_name = 'PKSTUDSSN' OR
	column_name LIKE '%FK%' AND
	table_name = 'STUDENT';

--9. Print the names of all entities that are indirectly related to the entity Student (related via two relationships).
SELECT UNIQUE table_name
FROM user_tab_columns
WHERE Table_name <> 'STUDENT'
MINUS
SELECT UNIQUE table_name
FROM user_tab_columns
WHERE column_name = 'FKSTUDSSN' OR
	column_name = 'PKSTUDSSN' OR
	column_name LIKE '%FK%' AND
	table_name = 'STUDENT';

--10. Print the names of attributes for entities College and Department (just the attribute names).
SELECT column_name
FROM user_tab_columns
WHERE table_name = 'COLLEGE'
OR table_name = 'DEPARTMENT';

--11. Print the names of all entities that are participating in any relationship that Section participates.
SELECT UNIQUE table_name
FROM user_tab_columns
WHERE table_name = 'COURSE'
OR table_name = 'FACULTY'
OR table_name = 'GRADSTUDENT'
OR table_name = 'STUDENT';

--12. Print the name of all entities that have exactly three attributes in the picture.
SELECT table_name
FROM user_tab_columns
GROUP BY table_name 
HAVING COUNT(column_name) = 3;

--13. Print label ‘Parent’ followed by the name of the parent entity and the label ‘Child’ followed by the name of the child entities for each disjoint type-sub-type relationship.
select a1.table_name AS Child_Table, a3.table_name AS Parent_Table
from user_cons_columns a1, user_constraints a2, user_cons_columns a3, user_constraints a4
where a1.table_name = a2.table_name AND
a1.constraint_name = a2.constraint_name AND
a1.owner = a2.owner AND
a2.constraint_type  = 'R' AND
a4.constraint_type = 'P' AND
a4.constraint_name = a2.r_constraint_name AND
a4.owner= a2.R_owner AND
a4.table_name = a3.table_name AND
a4.constraint_name = a3.constraint_name;

--14. Print the name of each table and the columns within that table- by printing the table name once followed by each column within that table on a separate line.
SELECT table_name
FROM user_tab_columns
UNION
SELECT column_name
FROM user_tab_columns;

spool off;



