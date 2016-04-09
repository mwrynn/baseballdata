--creates all views, regular and materialized
CREATE OR REPLACE VIEW current_season AS SELECT '20150405'::date AS year;
CREATE OR REPLACE VIEW play_h_v AS
SELECT hometeam, visteam, gamedate, gamenum, inning, batter, pitcher, result, pchr.throws, 
COALESCE(badj, 
  CASE WHEN btr.bats='B' AND pchr.throws='L' THEN 'R'
       WHEN btr.bats='B' AND pchr.throws='R' THEN 'L' 
       ELSE btr.bats END) bats,
  CASE WHEN result LIKE 'K%' THEN 0
       WHEN result ~   '^[0-9]+.*' THEN 0
       WHEN result LIKE 'S%' THEN 1
       WHEN result LIKE 'D%' THEN 1
       WHEN result LIKE 'T%' THEN 1
       WHEN result LIKE 'W%' THEN 0
       WHEN result  =   'DGR' THEN 1
       WHEN result LIKE 'FC%' THEN 1
       WHEN result  =   'H'  THEN 1
       WHEN result  =   'HR' THEN 1
       WHEN result  =   'C'  THEN 0
       WHEN result LIKE 'E%' THEN 0
       WHEN result LIKE 'FLE%' THEN 0
       WHEN result LIKE 'I%' THEN 0
  ELSE null
  END AS pa_is_hit
FROM play p
/* these distinct on subqueries necessary to avoid duplicate results in the event that a player was on many teams in one year -
   they select a single arbitrary row for year, retrosheet_id, which may not be correct; team name and other cols not used so it's ok in this context;
   only problem I see is if a player throws or bats differently from one team or another which seems unlikely (confirmed this does not happen in at least our current data set)
*/
JOIN (SELECT DISTINCT ON (year, retrosheet_id) year, retrosheet_id, team, throws FROM roster ORDER BY year, retrosheet_id, team) pchr ON 
p.pitcher=pchr.retrosheet_id AND extract(year from gamedate)=pchr.year
JOIN (SELECT DISTINCT ON (year, retrosheet_id) year, retrosheet_id, team, bats FROM roster ORDER BY year, retrosheet_id, team) btr ON 
p.batter=btr.retrosheet_id AND extract(year from gamedate)=btr.year
;


DROP VIEW IF EXISTS batter_agg_v CASCADE;
DROP MATERIALIZED VIEW IF EXISTS batter_agg_mv;

/* per batter+game, gets whether player got a hit, the number of hits, and the number of plate appearances
batter,20140501,1,1,...,...
*/
create or replace view batter_game_v as
  select distinct on (batter, gamedate, gamenum) extract (year from gamedate) as yr, batter, gamedate, gamenum, hit_in_game, sum(pa_is_hit) num_hits, count(pa_is_hit) num_pa 
  from
    (select batter, gamedate, gamenum, pa_is_hit, max(pa_is_hit) over (partition by batter, gamedate, gamenum) as hit_in_game from play_h_v) sub
  group by batter, gamedate, gamenum, hit_in_game
;

create materialized view batter_game_mv as select * from batter_game_v;

create or replace view batter_agg_v as
/* roll the batter_game data up to get us hpa, aloh */
select batter, yr, sum(num_hits)::float/sum(num_pa)::float as hpa, sum(hit_in_game)::float/count(*)::float as aloh, count(*) as num_games, sum(num_pa) total_pa
from batter_game_v
group by batter, yr
;
/*
SELECT batter, sum(yr_wt*num_hits)::float/sum(yr_wt*b.num_pa)::float as hpa,
  sum(yr_wt*hit_in_game)::float/sum(yr_wt)::float as aloh,
  count(*) as num_games,
  sum(num_pa) total_pa
FROM (SELECT batter, num_hits, num_pa, hit_in_game, 1-.15*(extract(year from (select year from current_season)) - extract(year from gamedate)) AS yr_wt FROM batter_game) b
GROUP BY batter
;
*/

CREATE MATERIALIZED VIEW batter_agg_mv as select * from batter_agg_v;

DROP VIEW IF EXISTS batter_pitcher_hist_v CASCADE;

CREATE OR REPLACE VIEW batter_aloh_per_game_v AS
SELECT batter, pitcher, hometeam, bats, throws, gamedate, gamenum,
       extract (year from gamedate) as yr,
       max(1-.15*(extract(year from (select year from current_season)) - extract(year from gamedate))) as yr_wt,
       count(pa_is_hit) AS num_pa, 
       sum(pa_is_hit) AS num_hits,
       max(pa_is_hit) AS hit_against_pitcher
       FROM play_h_v
     GROUP BY batter, pitcher, hometeam, bats, throws, gamedate, gamenum, yr
;

/* record of each batter's historical data, including weighted by year, grouped by pitcher/hometeam/bats/throws */
CREATE OR REPLACE VIEW batter_pitcher_hist_v AS
SELECT batter, pitcher, hometeam, bats, throws,
  sum(num_hits) AS total_hits,
  CASE WHEN sum(num_pa) = 0 THEN null ELSE sum(num_hits)::float/sum(num_pa)::float END AS hpa,
  CASE WHEN sum(yr_wt::float*num_pa::float) = 0 THEN null ELSE sum(yr_wt::float*num_hits::float)/sum(yr_wt::float*num_pa::float) END AS hpa_yrwtd,
  CASE WHEN count(*) = 0 THEN null ELSE sum(hit_against_pitcher)::float/count(*)::float END AS aloh,
  CASE WHEN count(*) = 0 THEN null ELSE sum(yr_wt::float*hit_against_pitcher::float)/(sum(yr_wt::float)/**count(*)::float*/) END AS aloh_yrwtd,
  sum(num_pa) AS total_pa,
  max(yr) AS last_yr,
  count(distinct gamedate::varchar || gamenum::varchar) AS num_games
  --sum(yr_wt::float)/sum(num_pa::float) AS yr_wt
FROM batter_aloh_per_game_v
WHERE yr_wt > 0 --please don't count 0 or negatives
GROUP BY batter, pitcher, hometeam, bats, throws
;

DROP MATERIALIZED VIEW IF EXISTS batter_pitcher_hist_mv;
CREATE MATERIALIZED VIEW batter_pitcher_hist_mv AS SELECT * FROM batter_pitcher_hist_v;

--try to get aggregates per handedness and stadium (for all pitchers)
CREATE OR REPLACE VIEW batter_hand_hometeam_v AS
SELECT batter, hometeam, throws,
  sum(num_hits) AS total_hits,
  CASE WHEN sum(num_pa) = 0 THEN null ELSE sum(num_hits)::float/sum(num_pa)::float END AS hpa,
  CASE WHEN sum(yr_wt::float*num_pa::float) = 0 THEN null ELSE sum(yr_wt::float*num_hits::float)/sum(yr_wt::float*num_pa::float) END AS hpa_yrwtd,
  CASE WHEN count(*) = 0 THEN null ELSE sum(hit_against_pitcher)::float/count(*)::float END AS aloh,
  CASE WHEN count(*) = 0 THEN null ELSE sum(yr_wt::float*hit_against_pitcher::float)/(sum(yr_wt::float)/**count(*)::float*/) END AS aloh_yrwtd,
  sum(num_pa) AS total_pa,
  max(yr) AS last_yr,
  count(distinct gamedate::varchar || gamenum::varchar) AS num_games
  --sum(yr_wt::float)/sum(num_pa::float) AS yr_wt
FROM batter_aloh_per_game_v
WHERE yr_wt > 0 --please don't count 0 or negatives
GROUP BY batter, hometeam, throws
;

CREATE OR REPLACE VIEW batter_hand_v AS
SELECT batter, throws,
  sum(num_hits) AS total_hits,
  CASE WHEN sum(num_pa) = 0 THEN null ELSE sum(num_hits)::float/sum(num_pa)::float END AS hpa,
  CASE WHEN sum(yr_wt::float*num_pa::float) = 0 THEN null ELSE sum(yr_wt::float*num_hits::float)/sum(yr_wt::float*num_pa::float) END AS hpa_yrwtd,
  CASE WHEN count(*) = 0 THEN null ELSE sum(hit_against_pitcher)::float/count(*)::float END AS aloh,
  CASE WHEN count(*) = 0 THEN null ELSE sum(yr_wt::float*hit_against_pitcher::float)/(sum(yr_wt::float)/**count(*)::float*/) END AS aloh_yrwtd,
  sum(num_pa) AS total_pa,
  max(yr) AS last_yr,
  --count(*) OVER (PARTITION BY gamedate, gamenum) AS num_games
  count(distinct gamedate::varchar || gamenum::varchar) AS num_games
  --sum(yr_wt::float)/sum(num_pa::float) AS yr_wt
FROM batter_aloh_per_game_v
WHERE yr_wt > 0 --please don't count 0 or negatives
GROUP BY batter, throws
;

CREATE OR REPLACE VIEW batter_hometeam_v AS
SELECT batter, hometeam,
  sum(num_hits) AS total_hits,
  CASE WHEN sum(num_pa) = 0 THEN null ELSE sum(num_hits)::float/sum(num_pa)::float END AS hpa,
  CASE WHEN sum(yr_wt::float*num_pa::float) = 0 THEN null ELSE sum(yr_wt::float*num_hits::float)/sum(yr_wt::float*num_pa::float) END AS hpa_yrwtd,
  CASE WHEN count(*) = 0 THEN null ELSE sum(hit_against_pitcher)::float/count(*)::float END AS aloh,
  CASE WHEN count(*) = 0 THEN null ELSE sum(yr_wt::float*hit_against_pitcher::float)/(sum(yr_wt::float)/**count(*)::float*/) END AS aloh_yrwtd,
  sum(num_pa) AS total_pa,
  max(yr) AS last_yr,
  --count(*) OVER (PARTITION BY gamedate, gamenum) AS num_games
  count(distinct gamedate::varchar || gamenum::varchar) AS num_games
  --sum(yr_wt::float)/sum(num_pa::float) AS yr_wt
FROM batter_aloh_per_game_v
WHERE yr_wt > 0 --please don't count 0 or negatives
GROUP BY batter, hometeam
;

CREATE OR REPLACE VIEW batter_pitcher_v AS
SELECT batter, pitcher,
  sum(num_hits) AS total_hits,
  CASE WHEN sum(num_pa) = 0 THEN null ELSE sum(num_hits)::float/sum(num_pa)::float END AS hpa,
  CASE WHEN sum(yr_wt::float*num_pa::float) = 0 THEN null ELSE sum(yr_wt::float*num_hits::float)/sum(yr_wt::float*num_pa::float) END AS hpa_yrwtd,
  CASE WHEN count(*) = 0 THEN null ELSE sum(hit_against_pitcher)::float/count(*)::float END AS aloh,
  CASE WHEN count(*) = 0 THEN null ELSE sum(yr_wt::float*hit_against_pitcher::float)/(sum(yr_wt::float)/**count(*)::float*/) END AS aloh_yrwtd,
  sum(num_pa) AS total_pa,
  max(yr) AS last_yr,
  count(distinct gamedate::varchar || gamenum::varchar) AS num_games
  --sum(yr_wt::float)/sum(num_pa::float) AS yr_wt
FROM batter_aloh_per_game_v
WHERE yr_wt > 0 --please don't count 0 or negatives
GROUP BY batter, pitcher
;

/*
TODO qry for success given hit streak #
first figure out how to get hit streak #
maybe figure out how to get streak chart, ex:
  4/1/15, 0
  4/2/15, 1
  4/3/15, 2
  4/4/15, 3
  4/5/15, 0
  ...
or it could potentially leave out the numbers in between, so:
  4/1/15, 0
  4/4/15, 3
  4/5/15, 0
  ...
*/

CREATE VIEW batter_game_streak_v AS
select yr, batter, gamedate, gamenum, hit_in_game, num_hits, num_pa, row_number() over (partition by batter, yr, grp order by gamedate, gamenum)-1 streak from
  (select *, max(seq) over (partition by batter, yr order by gamedate, gamenum rows between unbounded preceding and current row) grp from
    (select *, case when hit_in_game=1 then null else row_number() over (partition by batter, yr order by gamedate, gamenum) end as seq 
     from batter_game_mv) sub) sub2;

CREATE MATERIALIZED VIEW batter_game_streak_mv AS SELECT * FROM batter_game_streak_v;
