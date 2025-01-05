-- Create a table for the uni_professors
CREATE TABLE uni_professors (
    firstname TEXT,
    lastname TEXT,
    university TEXT,
    university_shortname TEXT,
    university_city TEXT,
    function TEXT,
    organisation TEXT,
    organisation_sector TEXT
);
-- We simpliy alter-table to rename of organisation to organization 
ALTER TABLE uni_professors
RENAME COLUMN organisation TO organization;
-- We simpliy alter-table to rename of organisation_sector to organization_sector 
ALTER TABLE uni_professors
RENAME COLUMN organisation_sector TO organization_sector;

-- print all the records in uni_professors
select * from uni_professors ;

-- Create a table for the professors 
CREATE TABLE professors (
    firstname TEXT,
    lastname TEXT,
    university_shortname TEXT
);


-- Insert unique professors into the new table
INSERT INTO professors (firstname, lastname, university_shortname)
SELECT DISTINCT firstname, lastname, university_shortname
FROM uni_professors;

-- Print the contents of this table
SELECT * FROM professors
limit 5;

-- Create a table for the organization
CREATE TABLE organizations (
    organization TEXT,
    organization_sector TEXT
);

-- Insert unique organization into the new table
INSERT INTO organizations (organization, organization_sector)
SELECT DISTINCT organization, organization_sector
FROM uni_professors;

-- Print the contents of this table
SELECT * FROM organizations
limit 5;


-- Create a table for the universities
CREATE TABLE universities (
    university TEXT,
    university_shortname TEXT,
    university_city TEXT
);

-- Insert unique universities into the new table
INSERT INTO universities (university, university_shortname, university_city)
SELECT DISTINCT university, university_shortname, university_city
FROM uni_professors;

-- Print the contents of this table
SELECT * FROM universities
limit 5;

-- Create a table for the affiliation
CREATE TABLE affiliations (
firstname text,
lastname text,
university_shortname text,
function text,
organization text
);


-- Insert unique affiliations into the new table
INSERT INTO affiliations (firstname, lastname, university_shortname, function, organization)
SELECT DISTINCT firstname, lastname, university_shortname, function, organization
FROM uni_professors;

-- Print the contents of this table
SELECT * FROM affiliations
limit 5;

-- Delete the university_shortname column
ALTER TABLE affiliations
DROP COLUMN university_shortname;


-- Delete the uni_professors table
DROP TABLE uni_professors;


-- Specify the correct fixed-length character type
ALTER TABLE professors
ALTER COLUMN university_shortname
TYPE char(3);

-- Change the type of firstname
ALTER TABLE professors
ALTER COLUMN firstname
TYPE varchar(64);

-- Disallow NULL values in firstname
ALTER TABLE professors 
ALTER COLUMN firstname SET NOT NULL;

-- Disallow NULL values in lastname
ALTER TABLE professors 
ALTER COLUMN lastname SET NOT NULL;

-- Make universities.university_shortname unique
ALTER TABLE universities
ADD CONSTRAINT university_shortname_unq UNIQUE(university_shortname);

-- Make organizations.organization unique
ALTER TABLE organizations
ADD CONSTRAINT organization_unq UNIQUE(organization)


-- Rename the organization column to id
ALTER TABLE organizations
RENAME COLUMN organization TO id;

-- Make id a primary key
ALTER TABLE organizations
ADD CONSTRAINT organization_pk PRIMARY KEY (id);

-- Rename the university_shortname column to id
ALTER TABLE universities
RENAME COLUMN university_shortname TO id;

-- Make id a primary key
ALTER TABLE universities
ADD CONSTRAINT university_pk PRIMARY KEY (id);

-- Add the new column to the table
ALTER TABLE professors 
ADD COLUMN id serial;

-- Make id a primary key
ALTER TABLE professors
ADD CONSTRAINT professors_pkey PRIMARY KEY (id);

SELECT * FROM professors
LIMIT 10;

-- Rename the university_shortname column
ALTER TABLE professors
RENAME COLUMN university_shortname to university_id;

-- Add a foreign key on professors referencing universities
ALTER TABLE professors 
ADD CONSTRAINT professors_fkey FOREIGN KEY (university_id) REFERENCES universities (id);

-- Select all professors working for universities in the city of Zurich
SELECT prof.lastname, uni.id, uni.university_city
FROM professors AS prof
INNER JOIN universities AS uni
ON prof.university_id = uni.id
WHERE uni.university_city = 'Zurich';

-- Add a professor_id column
ALTER TABLE affiliations
ADD COLUMN professor_id integer REFERENCES professors (id);

-- Rename the organization column to organization_id
ALTER TABLE affiliations
RENAME COLUMN organization TO organization_id;

-- Add a foreign key on organization_id
ALTER TABLE affiliations
ADD CONSTRAINT affiliations_organization_fkey FOREIGN KEY (organization_id) REFERENCES organizations (id);

-- Have a look at the 10 first rows of affiliations
SELECT * FROM affiliations
LIMIT 10;


-- Set professor_id to professors.id where firstname, lastname correspond to rows in professors
UPDATE affiliations
SET professor_id = professors.id
FROM professors
WHERE affiliations.firstname = professors.firstname AND affiliations.lastname = professors.lastname;

-- Have a look at the 10 first rows of affiliations again
SELECT * FROM affiliations
LIMIT 10;

-- using join we find name of professors across professor_id so making a smart move we can also drop firstname and lastname 
--from affiliations table
select distinct prof.firstname,prof.lastname,function
From professors AS prof
inner join affiliations
on prof.id = affiliations.professor_id
Where prof.id = '56';

-- Drop the firstname & lastname column
ALTER TABLE affiliations
DROP COLUMN firstname;

ALTER TABLE affiliations
DROP COLUMN lastname;

-- Have a look at the 10 first rows of affiliations again
SELECT * FROM affiliations
LIMIT 10;

-- Drop the right foreign key constraint
ALTER TABLE affiliations
DROP CONSTRAINT affiliations_organization_fkey;

ALTER TABLE affiliations
ADD CONSTRAINT affiliations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations (id) ON DELETE CASCADE;

-- check table name column name and data type name
SELECT table_name, column_name , data_type
FROM information_schema.columns
WHERE table_name = 'affiliations';
 
 -- check table_name , constraint_name and constraint_type
SELECT table_name, constraint_name , constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'affiliations';


-- Count the total number of affiliations per university
SELECT COUNT(*), professors.university_id 
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
-- Group by the ids of professors
GROUP BY professors.id 
ORDER BY count DESC;


-- Join all tables
SELECT *
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
JOIN organizations
ON affiliations.organization_id = organizations.id
JOIN universities
ON professors.university_id = universities.id;


-- Group the table by organization sector, professor and university city
SELECT COUNT(*), organizations.organization_sector, professors.id, universities.university_city
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
JOIN organizations
ON affiliations.organization_id = organizations.id
JOIN universities
ON professors.university_id = universities.id
GROUP BY organizations.organization_sector, professors.id, universities.university_city;


-- Filter the table and sort it
SELECT COUNT(*), organizations.organization_sector, 
professors.id, universities.university_city
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
JOIN organizations
ON affiliations.organization_id = organizations.id
JOIN universities
ON professors.university_id = universities.id
WHERE organizations.organization_sector = 'Media & communication'
GROUP BY organizations.organization_sector, 
professors.id, universities.university_city
ORDER BY count DESC;

