--"MLB ID","Name","Team","Game","Game#","Result","H/P","starter","AB","H","2B","3B","HR","R","RBI","BB","IBB","HBP","SO","SB","CS","Picked Off","Sac","SF","E","PB","LOB","GIDP","IP","Hits allowed","Runs allowed","ER","Walk","Intl Walk","K","HB","Pickoffs","HR allowed","WP","Win","Loss","Save","BS","Hold","Position(s)","CG"

CREATE TABLE player_stats (
  mlb_id INT NOT NULL,
  name VARCHAR,
  team VARCHAR(3),
  game VARCHAR(5), --e.g. "@ oak" or "v lad"
  game_num SMALLINT, --usually 1
  result VARCHAR(8), --?
  h_or_p VARCHAR(1), --H or P (hitter/pitcher)
  starter SMALLINT, --?
  ab SMALLINT,
  h SMALLINT,
  "2b" SMALLINT,
  "3b" SMALLINT,
  hr SMALLINT,
  r SMALLINT,
  rbi SMALLINT,
  bb SMALLINT,
  ibb SMALLINT,
  hbp SMALLINT,
  so SMALLINT,
  sb SMALLINT,
  cs SMALLINT,
  picked_off SMALLINT,
  sac SMALLINT,
  sf SMALLINT,
  e SMALLINT,
  pb SMALLINT,
  lob SMALLINT,
  gidp SMALLINT,
  ip FLOAT,
  hits_allowed SMALLINT,
  runs_allowed SMALLINT,
  er SMALLINT,
  walk SMALLINT,
  intl_walk SMALLINT,
  k SMALLINT,
  hb SMALLINT,
  pickoffs SMALLINT,
  hr_allowed SMALLINT,
  wp SMALLINT,
  win SMALLINT,
  loss SMALLINT,
  save SMALLINT,
  bs SMALLINT,
  hold SMALLINT,
  positions VARCHAR,
  cg SMALLINT,
  game_date DATE
);