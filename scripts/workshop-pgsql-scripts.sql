/* SQL Scripts for Aurora Global Database Workshop - PostgreSQL */

-- Primary Region; Create junk and random data

CREATE SCHEMA IF NOT EXISTS mylab AUTHORIZATION masteruser;

DROP TABLE IF EXISTS mylab.gdbtest1;

CREATE TABLE mylab.gdbtest1 (
  pk SERIAL,
  gen_number INT NOT NULL,
  PRIMARY KEY (pk)
  );

CREATE OR REPLACE FUNCTION InsertRand(NumRows integer, MinVal integer, MaxVal integer)
  RETURNS text AS
$func$
DECLARE i INT;
BEGIN
     i := 1;
     FOR i IN 1 .. NumRows LOOP
           INSERT INTO mylab.gdbtest1 (gen_number) 
               SELECT floor(random() * (MaxVal-MinVal+1) + MinVal)::int;
            
     END LOOP;
     RETURN 'Inserted ' || NumRows || ' random rows successfully.';
END;
$func$
LANGUAGE 'plpgsql';

-- (amount of rows; lowerbound; upperbound)
SELECT InsertRand(1000000, 1357, 9753);
COMMIT;



-- Return the top 100 rows
SELECT * FROM mylab.gdbtest1 limit 100;





-- To run in both Primary and Secondary Regions to validate data consistency

-- Run count of rows, sum of all randomized numbers, and a MD5 Checksum on the average
SELECT count(pk) AS item_count, sum(gen_number) AS item_summation, md5( CAST (avg(gen_number) AS varchar(32) ) ) AS avg_md5  
FROM mylab.gdbtest1;