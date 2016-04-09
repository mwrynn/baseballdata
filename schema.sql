--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: baseball; Type: SCHEMA; Schema: -; Owner: mwrynn
--

CREATE SCHEMA baseball;


ALTER SCHEMA baseball OWNER TO mwrynn;

SET search_path = baseball, pg_catalog;

--
-- Name: pvb_wt(integer); Type: FUNCTION; Schema: baseball; Owner: mwrynn
--

CREATE FUNCTION pvb_wt(ab integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
  DECLARE
     mod_8 INTEGER;
     div_8 INTEGER;
     ret_wt NUMERIC:=0;-- := (1::NUMERIC/8::NUMERIC)::NUMERIC;
  BEGIN
    IF ab IS NULL THEN RETURN 0; END IF;

    SELECT mod(ab, 8) INTO mod_8;
    div_8=ab/8;

    FOR i IN 0 .. div_8-1 LOOP
      ret_wt := ret_wt + 8/(8 + pow(i,2));
    END LOOP; 

    ret_wt := ret_wt + mod_8 * 1/(8+pow(div_8,2));

    RETURN ret_wt;
  END;
$$;


ALTER FUNCTION baseball.pvb_wt(ab integer) OWNER TO mwrynn;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: batting_against; Type: TABLE; Schema: baseball; Owner: mwrynn; Tablespace: 
--

CREATE TABLE batting_against (
    rk smallint,
    pitcher character varying,
    age smallint,
    tm character varying(3),
    ip numeric,
    g smallint,
    pa smallint,
    ab smallint,
    r smallint,
    h smallint,
    "2b" smallint,
    "3b" smallint,
    hr smallint,
    sb smallint,
    cs smallint,
    bb smallint,
    so smallint,
    ba numeric,
    obp numeric,
    slg numeric,
    ops numeric,
    babip numeric,
    tb numeric,
    gdp numeric,
    hbp smallint,
    sh smallint,
    sf smallint,
    ibb smallint,
    roe smallint
);


ALTER TABLE baseball.batting_against OWNER TO mwrynn;

--
-- Name: bag_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW bag_v AS
 SELECT
        CASE
            WHEN ("position"((batting_against.pitcher_name)::bytea, '\xc2a0'::bytea) > 0) THEN (encode("overlay"((batting_against.pitcher_name)::bytea, '\x20'::bytea, "position"((batting_against.pitcher_name)::bytea, '\xc2a0'::bytea), 2), 'escape'::text))::character varying
            ELSE batting_against.pitcher_name
        END AS pitcher_name,
    batting_against.rk,
    batting_against.pitcher,
    batting_against.age,
    batting_against.tm,
    batting_against.ip,
    batting_against.g,
    batting_against.pa,
    batting_against.ab,
    batting_against.r,
    batting_against.h,
    batting_against."2b",
    batting_against."3b",
    batting_against.hr,
    batting_against.sb,
    batting_against.cs,
    batting_against.bb,
    batting_against.so,
    batting_against.ba,
    batting_against.obp,
    batting_against.slg,
    batting_against.ops,
    batting_against.babip,
    batting_against.tb,
    batting_against.gdp,
    batting_against.hbp,
    batting_against.sh,
    batting_against.sf,
    batting_against.ibb,
    batting_against.roe
   FROM ( SELECT (replace((batting_against_1.pitcher)::text, ('*'::character varying)::text, (''::character varying)::text))::character varying AS pitcher_name,
            batting_against_1.rk,
            batting_against_1.pitcher,
            batting_against_1.age,
            batting_against_1.tm,
            batting_against_1.ip,
            batting_against_1.g,
            batting_against_1.pa,
            batting_against_1.ab,
            batting_against_1.r,
            batting_against_1.h,
            batting_against_1."2b",
            batting_against_1."3b",
            batting_against_1.hr,
            batting_against_1.sb,
            batting_against_1.cs,
            batting_against_1.bb,
            batting_against_1.so,
            batting_against_1.ba,
            batting_against_1.obp,
            batting_against_1.slg,
            batting_against_1.ops,
            batting_against_1.babip,
            batting_against_1.tb,
            batting_against_1.gdp,
            batting_against_1.hbp,
            batting_against_1.sh,
            batting_against_1.sf,
            batting_against_1.ibb,
            batting_against_1.roe
           FROM batting_against batting_against_1) batting_against;


ALTER TABLE baseball.bag_v OWNER TO mwrynn;

--
-- Name: player_stats; Type: TABLE; Schema: baseball; Owner: mwrynn; Tablespace: 
--

CREATE TABLE player_stats (
    mlb_id integer NOT NULL,
    name character varying,
    team character varying(3),
    game character varying(5),
    game_num smallint,
    result character varying(8),
    h_or_p character varying(1),
    starter smallint,
    ab smallint,
    h smallint,
    "2b" smallint,
    "3b" smallint,
    hr smallint,
    r smallint,
    rbi smallint,
    bb smallint,
    ibb smallint,
    hbp smallint,
    so smallint,
    sb smallint,
    cs smallint,
    picked_off smallint,
    sac smallint,
    sf smallint,
    e smallint,
    pb smallint,
    lob smallint,
    gidp smallint,
    ip double precision,
    hits_allowed smallint,
    runs_allowed smallint,
    er smallint,
    walk smallint,
    intl_walk smallint,
    k smallint,
    hb smallint,
    pickoffs smallint,
    hr_allowed smallint,
    wp smallint,
    win smallint,
    loss smallint,
    save smallint,
    bs smallint,
    hold smallint,
    positions character varying,
    cg smallint,
    game_date date
);


ALTER TABLE baseball.player_stats OWNER TO mwrynn;

--
-- Name: batting_per_game_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW batting_per_game_v AS
 SELECT sub.game_date,
    sub.mlb_id,
    sub.name,
    sub.game,
    sub.team,
    sub.ab,
    sub.h,
    sub."2b",
    sub."3b",
    sub.hr,
    sub.r,
    sub.rbi,
    sub.bb,
    sub.hbp,
        CASE
            WHEN (sub.h >= 1) THEN 1
            ELSE 0
        END AS at_least_1_hit
   FROM ( SELECT player_stats.game_date,
            player_stats.mlb_id,
            player_stats.name,
            player_stats.game,
            player_stats.team,
            COALESCE((player_stats.ab)::integer, 0) AS ab,
            COALESCE((player_stats.h)::integer, 0) AS h,
            COALESCE((player_stats."2b")::integer, 0) AS "2b",
            COALESCE((player_stats."3b")::integer, 0) AS "3b",
            COALESCE((player_stats.hr)::integer, 0) AS hr,
            COALESCE((player_stats.r)::integer, 0) AS r,
            COALESCE((player_stats.rbi)::integer, 0) AS rbi,
            COALESCE((player_stats.bb)::integer, 0) AS bb,
            COALESCE((player_stats.hbp)::integer, 0) AS hbp
           FROM player_stats) sub;


ALTER TABLE baseball.batting_per_game_v OWNER TO mwrynn;

--
-- Name: batting_last_5_days_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW batting_last_5_days_v AS
 SELECT batting_per_game_v.mlb_id,
    batting_per_game_v.name,
    avg(((batting_per_game_v.h)::numeric / (batting_per_game_v.ab)::numeric)) AS avg_last_5,
    avg((batting_per_game_v.at_least_1_hit)::numeric) AS at_least_1_hit_last_5
   FROM batting_per_game_v
  WHERE ((batting_per_game_v.game_date >= (('now'::text)::date - '5 days'::interval)) AND (batting_per_game_v.ab > 0))
  GROUP BY batting_per_game_v.mlb_id, batting_per_game_v.name;


ALTER TABLE baseball.batting_last_5_days_v OWNER TO mwrynn;

--
-- Name: batting_agg_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW batting_agg_v AS
 SELECT bpg.mlb_id,
    bpg.name,
    bpg.team,
    sum(bpg.h) AS sum_h,
    avg(bpg.at_least_1_hit) AS avg_got_hit,
    sum(bpg.ab) AS sum_ab,
    ((sum(bpg.h))::double precision / (sum(bpg.ab))::double precision) AS avg,
    last5.avg_last_5,
    last5.at_least_1_hit_last_5
   FROM (batting_per_game_v bpg
   JOIN batting_last_5_days_v last5 ON ((bpg.mlb_id = last5.mlb_id)))
  GROUP BY bpg.mlb_id, bpg.name, bpg.team, last5.avg_last_5, last5.at_least_1_hit_last_5;


ALTER TABLE baseball.batting_agg_v OWNER TO mwrynn;

--
-- Name: batting_team_agg_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW batting_team_agg_v AS
 SELECT batting_per_game_v.name,
    "substring"((batting_per_game_v.game)::text, 3, 3) AS team,
    sum(batting_per_game_v.h) AS sum_h,
    avg(batting_per_game_v.at_least_1_hit) AS avg_got_hit,
    sum(batting_per_game_v.ab) AS sum_ab
   FROM batting_per_game_v
  GROUP BY batting_per_game_v.name, "substring"((batting_per_game_v.game)::text, 3, 3);


ALTER TABLE baseball.batting_team_agg_v OWNER TO mwrynn;

--
-- Name: delme_seq; Type: SEQUENCE; Schema: baseball; Owner: mwrynn
--

CREATE SEQUENCE delme_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE baseball.delme_seq OWNER TO mwrynn;

--
-- Name: player_stats_recur_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW player_stats_recur_v AS
 SELECT player_stats.mlb_id,
    player_stats.name,
    player_stats.team,
    player_stats.game,
    player_stats.game_num,
    player_stats.result,
    player_stats.h_or_p,
    player_stats.starter,
    player_stats.ab,
    player_stats.h,
    player_stats."2b",
    player_stats."3b",
    player_stats.hr,
    player_stats.r,
    player_stats.rbi,
    player_stats.bb,
    player_stats.ibb,
    player_stats.hbp,
    player_stats.so,
    player_stats.sb,
    player_stats.cs,
    player_stats.picked_off,
    player_stats.sac,
    player_stats.sf,
    player_stats.e,
    player_stats.pb,
    player_stats.lob,
    player_stats.gidp,
    player_stats.ip,
    player_stats.hits_allowed,
    player_stats.runs_allowed,
    player_stats.er,
    player_stats.walk,
    player_stats.intl_walk,
    player_stats.k,
    player_stats.hb,
    player_stats.pickoffs,
    player_stats.hr_allowed,
    player_stats.wp,
    player_stats.win,
    player_stats.loss,
    player_stats.save,
    player_stats.bs,
    player_stats.hold,
    player_stats.positions,
    player_stats.cg,
    player_stats.game_date,
        CASE
            WHEN (player_stats.h IS NOT NULL) THEN 1
            ELSE 0
        END AS got_hit,
    lag(player_stats.game_date) OVER (PARTITION BY player_stats.mlb_id ORDER BY player_stats.game_date) AS lag_game_date
   FROM player_stats
  WHERE (player_stats.mlb_id = 120074);


ALTER TABLE baseball.player_stats_recur_v OWNER TO mwrynn;

--
-- Name: pvb; Type: TABLE; Schema: baseball; Owner: mwrynn; Tablespace: 
--

CREATE TABLE pvb (
    mlb_id integer NOT NULL,
    espn_id integer,
    hitter_lastfirst character varying NOT NULL,
    hitter_firstlast character varying NOT NULL,
    team character varying(3) NOT NULL,
    h_a character varying(1) NOT NULL,
    bats character varying(1) NOT NULL,
    fdpos smallint,
    dspos smallint,
    djpos smallint,
    sspos smallint,
    ab smallint,
    h smallint,
    "2b" smallint,
    "3b" smallint,
    hr smallint,
    rbi smallint,
    bb smallint,
    so smallint,
    sb smallint,
    cs smallint,
    avg numeric,
    obp numeric,
    slg numeric,
    ops numeric,
    pitcher_mlb_id integer NOT NULL,
    pitcher_espn_id integer,
    pitcher_lastfirst character varying,
    pitcher_firstlast character varying,
    p_team character varying(3) NOT NULL,
    throws character varying(1) NOT NULL,
    game_time character varying
);


ALTER TABLE baseball.pvb OWNER TO mwrynn;

--
-- Name: pvb_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW pvb_v AS
 SELECT pvb.mlb_id,
    pvb.espn_id,
    pvb.hitter_lastfirst,
    pvb.team,
    pvb.h_a,
    pvb.bats,
    pvb.fdpos,
    pvb.dspos,
    pvb.djpos,
    pvb.sspos,
    pvb.ab,
    pvb.h,
    pvb."2b",
    pvb."3b",
    pvb.hr,
    pvb.rbi,
    pvb.bb,
    pvb.so,
    pvb.sb,
    pvb.cs,
    pvb.avg,
    pvb.obp,
    pvb.slg,
    pvb.ops,
    pvb.pitcher_mlb_id,
    pvb.pitcher_espn_id,
    pvb.pitcher_firstlast,
    pvb.pitcher_lastfirst,
    pvb.p_team,
    pvb.throws,
    pvb.game_time
   FROM pvb;


ALTER TABLE baseball.pvb_v OWNER TO mwrynn;

--
-- Name: weighted_hitter_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW weighted_hitter_v AS
 SELECT ba.name AS hitter_lastfirst,
    ba.avg_got_hit,
    ba.avg_last_5,
    ba.at_least_1_hit_last_5,
    pvb.avg AS pvb_avg,
    pvb_wt((pvb.ab)::integer) AS pvb_wt,
    COALESCE((pvb.ab)::integer, 0) AS pvb_ab,
    pvb.h AS pvb_h,
    bag.ba AS bag_ba,
    opposing_pitcher.pitcher_lastfirst,
    pvb.bats,
    opposing_pitcher.throws
   FROM (((batting_agg_v ba
   JOIN ( SELECT DISTINCT pvb_1.pitcher_firstlast,
            pvb_1.pitcher_lastfirst,
            pvb_1.throws,
            pvb_1.team
           FROM pvb pvb_1) opposing_pitcher ON ((lower((ba.team)::text) = lower((opposing_pitcher.team)::text))))
   LEFT JOIN pvb_v pvb ON ((ba.mlb_id = pvb.mlb_id)))
   LEFT JOIN bag_v bag ON (((opposing_pitcher.pitcher_firstlast)::text = (bag.pitcher_name)::text)))
  WHERE (ba.sum_ab > 100);


ALTER TABLE baseball.weighted_hitter_v OWNER TO mwrynn;

--
-- Name: rating_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW rating_v AS
 SELECT wh.hitter_lastfirst AS hitter,
    wh.avg_got_hit,
    wh.avg_last_5,
    wh.at_least_1_hit_last_5,
    wh.pitcher_lastfirst AS pvb_pitcher,
    wh.pvb_avg,
    wh.pvb_wt,
    wh.pvb_ab,
    wh.pvb_h,
    wh.bats,
    wh.throws,
    wh.bag_ba,
    ((((((2)::numeric * wh.avg_got_hit) + (
        CASE
            WHEN (wh.pvb_ab > 0) THEN ((1)::numeric / wh.pvb_wt)
            ELSE ((1)::numeric / (2)::numeric)
        END * COALESCE(wh.bag_ba, ( SELECT avg(bag_v.ba) AS avg
           FROM bag_v)))) + (wh.pvb_wt * COALESCE(wh.pvb_avg, ((-999))::numeric))) + ((
        CASE
            WHEN ((wh.bats)::text = (wh.throws)::text) THEN (0)::numeric
            ELSE 0.1
        END * (1)::numeric) / ((1 + wh.pvb_ab))::numeric)) / ((((1)::numeric +
        CASE
            WHEN (wh.pvb_ab > 0) THEN ((1)::numeric / wh.pvb_wt)
            ELSE ((1)::numeric / (2)::numeric)
        END) + wh.pvb_wt) + ((1 / (1 + wh.pvb_ab)))::numeric)) AS rating
   FROM weighted_hitter_v wh;


ALTER TABLE baseball.rating_v OWNER TO mwrynn;

--
-- Name: rating_rounded_v; Type: VIEW; Schema: baseball; Owner: mwrynn
--

CREATE VIEW rating_rounded_v AS
 SELECT rating_v.hitter,
    round(rating_v.avg_got_hit, 3) AS avg_got_hit,
    round(rating_v.avg_last_5, 3) AS avg_last_5,
    round(rating_v.at_least_1_hit_last_5, 3) AS at_least_1_hit_last_5,
    rating_v.pvb_pitcher,
    round(rating_v.pvb_avg, 3) AS pvg_avg,
    round(rating_v.pvb_wt, 3) AS pvb_wt,
    rating_v.pvb_ab,
    rating_v.pvb_h,
    rating_v.bats,
    rating_v.throws,
    round(rating_v.bag_ba, 3) AS bag_ba,
    round(rating_v.rating, 5) AS rating
   FROM rating_v;


ALTER TABLE baseball.rating_rounded_v OWNER TO mwrynn;

--
-- Name: pvb_pkey; Type: CONSTRAINT; Schema: baseball; Owner: mwrynn; Tablespace: 
--

ALTER TABLE ONLY pvb
    ADD CONSTRAINT pvb_pkey PRIMARY KEY (mlb_id, pitcher_mlb_id);


--
-- PostgreSQL database dump complete
--

