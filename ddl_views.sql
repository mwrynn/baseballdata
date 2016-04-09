DROP VIEW IF EXISTS pvb_v CASCADE;
CREATE OR REPLACE VIEW pvb_v AS
 SELECT pvb.mlb_id, pvb.espn_id, pvb.hitter_lastfirst, pvb.team, pvb.h_a, pvb.bats, pvb.fdpos,
    pvb.dspos, pvb.djpos, pvb.sspos, pvb.ab, pvb.h, pvb."2b", pvb."3b", pvb.hr,
    pvb.rbi, pvb.bb, pvb.so, pvb.sb, pvb.cs, pvb.avg, pvb.obp, pvb.slg, pvb.ops,
    pvb.pitcher_mlb_id, pvb.pitcher_espn_id, pvb.pitcher_firstlast, pvb.pitcher_lastfirst, pvb.p_team, pvb.throws, pvb.game_time
   FROM pvb;

DROP VIEW IF EXISTS batting_per_game_v CASCADE;
CREATE OR REPLACE VIEW batting_per_game_v AS
 SELECT sub.game_date, sub.mlb_id, sub.name, sub.game, sub.team, sub.ab, sub.h, sub."2b", sub."3b",
    sub.hr, sub.r, sub.rbi, sub.bb, sub.hbp,
        CASE
            WHEN sub.h >= 1 THEN 1
            ELSE 0
        END AS at_least_1_hit
   FROM ( SELECT player_stats.game_date, player_stats.mlb_id, player_stats.name, player_stats.game, player_stats.team,
            COALESCE(player_stats.ab::integer, 0) AS ab,
            COALESCE(player_stats.h::integer, 0) AS h,
            COALESCE(player_stats."2b"::integer, 0) AS "2b",
            COALESCE(player_stats."3b"::integer, 0) AS "3b",
            COALESCE(player_stats.hr::integer, 0) AS hr,
            COALESCE(player_stats.r::integer, 0) AS r,
            COALESCE(player_stats.rbi::integer, 0) AS rbi,
            COALESCE(player_stats.bb::integer, 0) AS bb,
            COALESCE(player_stats.hbp::integer, 0) AS hbp
           FROM player_stats) sub;

DROP VIEW IF EXISTS bag_v CASCADE;
CREATE OR REPLACE VIEW bag_v AS 
 SELECT CASE WHEN "position"(batting_against.pitcher_name::bytea, '\302\240'::bytea)>0 THEN encode("overlay"(batting_against.pitcher_name::bytea, ' '::bytea, "position"(batting_against.pitcher_name::bytea, '\302\240'::bytea), 2), 'escape'::text) ELSE pitcher_name END::character varying AS pitcher_name, 
    batting_against.rk, batting_against.pitcher, batting_against.age, 
    batting_against.tm, batting_against.ip, batting_against.g, 
    batting_against.pa, batting_against.ab, batting_against.r, 
    batting_against.h, batting_against."2b", batting_against."3b", 
    batting_against.hr, batting_against.sb, batting_against.cs, 
    batting_against.bb, batting_against.so, batting_against.ba, 
    batting_against.obp, batting_against.slg, batting_against.ops, 
    batting_against.babip, batting_against.tb, batting_against.gdp, 
    batting_against.hbp, batting_against.sh, batting_against.sf, 
    batting_against.ibb, batting_against.roe
   FROM ( SELECT replace(batting_against.pitcher::text, '*'::character varying::text, ''::character varying::text)::character varying AS pitcher_name, 
            batting_against.rk, batting_against.pitcher, batting_against.age, 
            batting_against.tm, batting_against.ip, batting_against.g, 
            batting_against.pa, batting_against.ab, batting_against.r, 
            batting_against.h, batting_against."2b", batting_against."3b", 
            batting_against.hr, batting_against.sb, batting_against.cs, 
            batting_against.bb, batting_against.so, batting_against.ba, 
            batting_against.obp, batting_against.slg, batting_against.ops, 
            batting_against.babip, batting_against.tb, batting_against.gdp, 
            batting_against.hbp, batting_against.sh, batting_against.sf, 
            batting_against.ibb, batting_against.roe
           FROM batting_against) batting_against;

DROP VIEW IF EXISTS batting_last_5_days_v CASCADE;
CREATE OR REPLACE VIEW batting_last_5_days_v AS
SELECT mlb_id, name, avg(h::numeric/ab::numeric) avg_last_5, avg(at_least_1_hit::numeric) AS at_least_1_hit_last_5 FROM batting_per_game_v WHERE game_date >= current_date - interval '5 days' AND ab>0 
GROUP BY mlb_id, name;

DROP VIEW IF EXISTS batting_agg_v CASCADE;
CREATE OR REPLACE VIEW batting_agg_v AS 
 SELECT bpg.mlb_id, bpg.name, bpg.team, sum(bpg.h) AS sum_h, 
    avg(bpg.at_least_1_hit) AS avg_got_hit, 
    sum(bpg.ab) AS sum_ab, 
    sum(bpg.h)::double precision / sum(bpg.ab)::double precision AS avg,
    avg_last_5,
    at_least_1_hit_last_5
   FROM batting_per_game_v bpg
   JOIN batting_last_5_days_v last5 ON bpg.mlb_id=last5.mlb_id
  GROUP BY bpg.mlb_id, bpg.name, bpg.team, avg_last_5, at_least_1_hit_last_5;

DROP VIEW IF EXISTS weighted_hitter_v CASCADE;
CREATE OR REPLACE VIEW weighted_hitter_v AS
 SELECT ba.name AS hitter_lastfirst, ba.avg_got_hit, ba.avg_last_5, ba.at_least_1_hit_last_5, pvb.avg AS pvb_avg,
    pvb_wt(pvb.ab)::numeric AS pvb_wt, COALESCE(pvb.ab,0) AS pvb_ab,
    pvb.h AS pvb_h, bag.ba AS bag_ba, opposing_pitcher.pitcher_lastfirst, pvb.bats, opposing_pitcher.throws
   FROM batting_agg_v ba 
   JOIN (SELECT DISTINCT pitcher_firstlast, pitcher_lastfirst, throws, team from pvb) opposing_pitcher ON lower(ba.team)=lower(opposing_pitcher.team)
   LEFT JOIN pvb_v pvb ON ba.mlb_id = pvb.mlb_id
   LEFT JOIN bag_v bag ON opposing_pitcher.pitcher_firstlast::text = bag.pitcher_name::text
  WHERE ba.sum_ab > 100;

DROP VIEW IF EXISTS batting_team_agg_v CASCADE;
CREATE OR REPLACE VIEW batting_team_agg_v AS 
 SELECT batting_per_game_v.name, 
    "substring"(batting_per_game_v.game::text, 3, 3) AS team, 
    sum(batting_per_game_v.h) AS sum_h, 
    avg(batting_per_game_v.at_least_1_hit) AS avg_got_hit, 
    sum(batting_per_game_v.ab) AS sum_ab
   FROM batting_per_game_v
  GROUP BY batting_per_game_v.name, "substring"(batting_per_game_v.game::text, 3, 3);

DROP VIEW IF EXISTS rating_nobag_v CASCADE;
/*
CREATE OR REPLACE VIEW rating_nobag_v AS 
 SELECT weighted_hitter_v.hitter_lastfirst as hitter, weighted_hitter_v.avg_got_hit, weighted_hitter_v.pitcher_lastfirst as pvb_pitcher,
    weighted_hitter_v.pvb_avg, weighted_hitter_v.pvb_wt, 
    weighted_hitter_v.pvb_ab, weighted_hitter_v.pvb_h, weighted_hitter_v.bag_ba, 
    (weighted_hitter_v.avg_got_hit + weighted_hitter_v.pvb_wt * weighted_hitter_v.pvb_avg) / (1::numeric + weighted_hitter_v.pvb_wt) AS rating
   FROM weighted_hitter_v;
*/

DROP VIEW IF EXISTS rating_v CASCADE;
CREATE OR REPLACE VIEW rating_v AS 
 SELECT wh.hitter_lastfirst as hitter, wh.avg_got_hit, wh.avg_last_5, wh.at_least_1_hit_last_5, wh.pitcher_lastfirst as pvb_pitcher,
    wh.pvb_avg, wh.pvb_wt, 
    wh.pvb_ab, wh.pvb_h, bats, throws, wh.bag_ba, 
    (2*avg_got_hit + 
     CASE WHEN pvb_ab > 0 THEN (1::NUMERIC/pvb_wt::NUMERIC) ELSE (1::NUMERIC/2::NUMERIC)::NUMERIC END*COALESCE(bag_ba, (select avg(ba) from bag_v)::NUMERIC) + /* league average */
     pvb_wt * COALESCE(pvb_avg,-999) + /*weight * avg, but in case when no history of pvb, pvb_wt will be 0, so multiply by any non-null */
     CASE WHEN bats=throws THEN 0 ELSE .1 END * 1/(1+pvb_ab) 
    ) / (1+
         CASE WHEN pvb_ab > 0 THEN (1::NUMERIC/pvb_wt::NUMERIC) ELSE (1::NUMERIC/2::NUMERIC)::NUMERIC END + 
         wh.pvb_wt +
         1/(1+pvb_ab)
    ) AS rating
   FROM weighted_hitter_v wh;

DROP VIEW IF EXISTS rating_rounded_v CASCADE;
CREATE OR REPLACE VIEW rating_rounded_v AS 
SELECT hitter, round(avg_got_hit, 3) avg_got_hit, round(avg_last_5, 3) avg_last_5, round(at_least_1_hit_last_5, 3) at_least_1_hit_last_5,
  pvb_pitcher, round(pvb_avg, 3) pvg_avg, round(pvb_wt, 3) pvb_wt, pvb_ab, pvb_h, bats, throws, 
  round(bag_ba, 3) bag_ba, round(rating, 5) rating
FROM rating_v;

