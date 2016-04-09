CREATE OR REPLACE FUNCTION pvb_wt(ab IN INTEGER) RETURNS NUMERIC AS
$$
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
$$ 
LANGUAGE plpgsql;

