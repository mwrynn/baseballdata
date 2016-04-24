CREATE TABLE roster (
  year INT,
  retrosheet_id VARCHAR(8),
  last VARCHAR(50),
  first VARCHAR(50),
  bats VARCHAR(1),
  throws VARCHAR(1),
  team VARCHAR(3),
  position VARCHAR(2),
  PRIMARY KEY (year, retrosheet_id, team)
);
