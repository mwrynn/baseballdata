CREATE TABLE play (
       hometeam VARCHAR(3),
       visteam VARCHAR(3),
       gamedate DATE,
       gamenum SMALLINT,
       inning SMALLINT,
       batter VARCHAR(8),
       pitcher VARCHAR(8),
       result VARCHAR,
       badj VARCHAR(1)
);

CREATE INDEX play_trunc_year_idx ON play (extract(year from gamedate));
