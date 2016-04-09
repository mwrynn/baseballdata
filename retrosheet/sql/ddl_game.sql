CREATE TABLE game (
       gamedate DATE,
       gamenum SMALLINT,
       hometeam VARCHAR(3),
       visteam VARCHAR(3),
       ballpark VARCHAR(5),
       PRIMARY KEY(gamedate,gamenum,hometeam,visteam)
);
