CREATE TABLE ballpark (
parkid VARCHAR(5) PRIMARY KEY,
name VARCHAR,
aka VARCHAR,
city VARCHAR,
state VARCHAR(3), --Canadian provinces too e.g. QUE
startdate DATE,
enddate DATE,
league VARCHAR(2),
notes VARCHAR
);

