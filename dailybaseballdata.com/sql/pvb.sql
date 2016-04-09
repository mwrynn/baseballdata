CREATE TABLE baseball.pvb (
  mlb_id INT,
  espn_id INT,
  hitter_lastfirst VARCHAR NOT NULL,
  hitter_firstlast VARCHAR NOT NULL,
  team VARCHAR(3) NOT NULL,
  h_a VARCHAR(1) NOT NULL,
  bats VARCHAR(1) NOT NULL,
  fdpos SMALLINT,
  dspos SMALLINT,
  djpos SMALLINT,
  sspos SMALLINT,
  ab SMALLINT,
  h SMALLINT,
  "2b" SMALLINT,
  "3b" SMALLINT,
  hr SMALLINT,
  rbi SMALLINT,
  bb SMALLINT,
  so SMALLINT,
  sb SMALLINT,
  cs SMALLINT,
  avg NUMERIC,
  obp NUMERIC,
  slg NUMERIC,
  ops NUMERIC,
  pitcher_mlb_id INT,
  pitcher_espn_id INT,
  pitcher_lastfirst VARCHAR,
  pitcher_firstlast VARCHAR,
  p_team VARCHAR(3) NOT NULL,
  throws VARCHAR(1) NOT NULL,
  game_time VARCHAR,
  PRIMARY KEY(mlb_id, pitcher_mlb_id)
);