CREATE TABLE gamelog (
game_date DATE,
num VARCHAR(1), 
day_of_week VARCHAR(3),
v_team VARCHAR,
v_league VARCHAR,
v_game_num SMALLINT,
h_team VARCHAR,
h_league VARCHAR,
h_game_num SMALLINT,
v_score SMALLINT, --field 10
h_score SMALLINT,
length SMALLINT,
day_or_night VARCHAR(1),
completion_info VARCHAR,
forfeit VARCHAR(1),
protest VARCHAR(1),
park_id VARCHAR(5) REFERENCES ballpark(parkid),
attendance INT,
game_time SMALLINT,
v_line_score VARCHAR, --field 20
h_line_score VARCHAR,
--visiting team offensive stats
v_ab SMALLINT,
v_h SMALLINT,
v_2b SMALLINT,
v_3b SMALLINT,
v_hr SMALLINT,
v_rbi SMALLINT,
v_sac_h SMALLINT,
v_sac_f SMALLINT,
v_hbp SMALLINT,  --field 30
v_bb SMALLINT,
v_int_bb SMALLINT,
v_k SMALLINT,
v_sb SMALLINT,
v_cs SMALLINT,
v_gdp SMALLINT,
v_ctchr_int SMALLINT,
v_lob SMALLINT,
--visiting team pitching statistics
v_pitchers_used SMALLINT,
v_indiv_er SMALLINT, --field 40
v_team_er SMALLINT,
v_wild_pitches SMALLINT,
v_balks SMALLINT,
--visiting team defensive statistics
v_putouts SMALLINT,
v_assists SMALLINT,
v_errors SMALLINT,
v_passed_balls SMALLINT,
v_dbl_plays SMALLINT,
v_trp_plays SMALLINT,
--home team offensive statistics
h_ab SMALLINT, --field 50
h_h SMALLINT,
h_2b SMALLINT,
h_3b SMALLINT,
h_hr SMALLINT,
h_rbi SMALLINT,
h_sac_h SMALLINT,
h_sac_f SMALLINT,
h_hbp SMALLINT,
h_bb SMALLINT,
h_int_bb SMALLINT,
h_k SMALLINT,
h_sb SMALLINT,
h_cs SMALLINT,
h_gdp SMALLINT,
h_ctcher_int SMALLINT,
h_lob SMALLINT,

--home team pitching statistics
h_pitchers_used SMALLINT,
h_indiv_er SMALLINT,
h_team_er SMALLINT,
h_wild_pitches SMALLINT,
h_balks SMALLINT,

--home team defensive statistics
h_putouts SMALLINT, --field 72
h_assists SMALLINT,
h_errors SMALLINT,
h_passed_balls SMALLINT,
h_dbl_plays SMALLINT,
h_trp_plays SMALLINT,

--umpires
umpire_hp_id VARCHAR(8) REFERENCES person(id), --field 78
umpire_hp_name VARCHAR,
umpire_1b_id VARCHAR(8) REFERENCES person(id),
umpire_1b_name VARCHAR,
umpire_2b_id VARCHAR(8) REFERENCES person(id),
umpire_2b_name VARCHAR,
umpire_3b_id VARCHAR(8) REFERENCES person(id),
umpire_3b_name VARCHAR,
umpire_lf_id VARCHAR(8) REFERENCES person(id),
umpire_lf_name VARCHAR,
umpire_rf_id VARCHAR(8) REFERENCES person(id),
umpire_rf_name VARCHAR,

v_team_manager_id VARCHAR(8) REFERENCES person(id), --field 90
v_team_manager_name VARCHAR,
h_team_manager_id VARCHAR(8) REFERENCES person(id),
h_team_manager_name VARCHAR,
winning_pitcher_id VARCHAR(8) REFERENCES person(id),
winning_pitcher_name VARCHAR,
losing_pitcher_id VARCHAR(8) REFERENCES person(id),
losing_pitcher_name VARCHAR,
saving_pitcher_id VARCHAR(8) REFERENCES person(id),
saving_pitcher_name VARCHAR,
winning_rbi_batter_id VARCHAR(8) REFERENCES person(id),
winning_rbi_batter_name VARCHAR,
v_starting_pitcher_id VARCHAR(8) REFERENCES person(id),
v_starting_pitcher_name VARCHAR,
h_starting_pitcher_id VARCHAR(8) REFERENCES person(id),
h_starting_pitcher_name VARCHAR,

--visiting starters
v_starter_id_1 VARCHAR(8) REFERENCES person(id),
v_starter_name_1 VARCHAR,
v_starter_pos_1 SMALLINT,

v_starter_id_2 VARCHAR(8) REFERENCES person(id),
v_starter_name_2 VARCHAR,
v_starter_pos_2	 SMALLINT,

v_starter_id_3 VARCHAR(8) REFERENCES person(id),
v_starter_name_3 VARCHAR,
v_starter_pos_3	 SMALLINT,

v_starter_id_4 VARCHAR(8) REFERENCES person(id),
v_starter_name_4 VARCHAR,
v_starter_pos_4	 SMALLINT,

v_starter_id_5 VARCHAR(8) REFERENCES person(id),
v_starter_name_5 VARCHAR,
v_starter_pos_5 SMALLINT,

v_starter_id_6 VARCHAR(8) REFERENCES person(id),
v_starter_name_6 VARCHAR,
v_starter_pos_6	 SMALLINT,

v_starter_id_7 VARCHAR(8) REFERENCES person(id),
v_starter_name_7 VARCHAR,
v_starter_pos_7	 SMALLINT,

v_starter_id_8 VARCHAR(8) REFERENCES person(id),
v_starter_name_8 VARCHAR,
v_starter_pos_8	 SMALLINT,

v_starter_id_9 VARCHAR(8) REFERENCES person(id),
v_starter_name_9 VARCHAR,
v_starter_pos_9	 SMALLINT,

--home starters
h_starter_id_1 VARCHAR(8) REFERENCES person(id),
h_starter_name_1 VARCHAR,
h_starter_pos_1	 SMALLINT,

h_starter_id_2 VARCHAR(8) REFERENCES person(id),
h_starter_name_2 VARCHAR,
h_starter_pos_2  SMALLINT,

h_starter_id_3 VARCHAR(8) REFERENCES person(id),
h_starter_name_3 VARCHAR,
h_starter_pos_3  SMALLINT,

h_starter_id_4 VARCHAR(8) REFERENCES person(id),
h_starter_name_4 VARCHAR,
h_starter_pos_4  SMALLINT,

h_starter_id_5 VARCHAR(8) REFERENCES person(id),
h_starter_name_5 VARCHAR,
h_starter_pos_5 SMALLINT,

h_starter_id_6 VARCHAR(8) REFERENCES person(id),
h_starter_name_6 VARCHAR,
h_starter_pos_6  SMALLINT,

h_starter_id_7 VARCHAR(8) REFERENCES person(id),
h_starter_name_7 VARCHAR,
h_starter_pos_7  SMALLINT,

h_starter_id_8 VARCHAR(8) REFERENCES person(id),
h_starter_name_8 VARCHAR,
h_starter_pos_8  SMALLINT,

h_starter_id_9 VARCHAR(8) REFERENCES person(id),
h_starter_name_9 VARCHAR,
h_starter_pos_9  SMALLINT,

additional_info VARCHAR,
acquisition VARCHAR(1),

CHECK (num IN ('0', '1', '2', '3', 'A', 'B')),
CHECK (day_of_week IN ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')),
CHECK (day_or_night IN ('D', 'N')),
CHECK (forfeit IN ('V', 'H', 'T')),
CHECK (protest IS NULL OR protest IN ('P', 'V', 'H', 'X', 'Y')),
CHECK (acquisition IN ('Y', 'N', 'D', 'P'))
);
