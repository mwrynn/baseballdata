CREATE TABLE player (id SERIAL PRIMARY KEY, name VARCHAR, num SMALLINT, team VARCHAR(3));
CREATE TABLE pa (pa_id SERIAL PRIMARY KEY, player_id INT REFERENCES player(id), gamedate DATE, inning SMALLINT, result VARCHAR(1));
CREATE OR REPLACE VIEW team_avg_v AS SELECT team, SUM(CASE WHEN result='H' THEN 1 ELSE 0 END)::float/COUNT(*)::float AS avg FROM pa JOIN player p ON pa.player_id=p.id GROUP BY team
CREATE MATERIALIZED VIEW team_avg_mv AS SELECT * FROM team_avg_v;
