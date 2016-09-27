-http://www.orafaq.com/forum/t/164224/
CREATE OR REPLACE FUNCTION GKN_COMMON.jws -- Jaro-Winkler similarity
  (p_string1     IN VARCHAR2,
   p_string2     IN VARCHAR2)
  RETURN            NUMBER
  DETERMINISTIC
AS
  v_string1         VARCHAR2 (32767);
  v_string2         VARCHAR2 (32767);
  v_closeness       NUMBER := 0;
  v_temp            VARCHAR2 (32767);
  v_comp1           VARCHAR2 (32767);
  v_comp2           VARCHAR2 (32767);
  v_matches         NUMBER := 0; 
  v_char            VARCHAR2 (1);
  v_transpositions  NUMBER := 0;
  v_d_jaro          NUMBER := 0;
  v_leading         NUMBER := 0;
  v_d_winkler       NUMBER := 0;
  v_jws             NUMBER := 0;
BEGIN
  -- check for null strings:
  IF p_string1 IS NULL OR p_string2 IS NULL THEN 
    RETURN 0;
  END IF;
  -- remove accents:
  v_string1 := translate (p_string1,
            '?S?Zs?z?AAA?A??CEEEEIIII??OOO?O?UUUUY?aaa?a??ceeeeiiii???ooo?ouuuuyy??',
            'fSEZsezYAAAAAAECEEEEIIIIDNOOOOOOUUUUYBaaaaaaeceeeeiiiioonooooouuuuyy');
  v_string2 := translate (p_string2,
            '?S?Zs?z?AAA?A??CEEEEIIII??OOO?O?UUUUY?aaa?a??ceeeeiiii???ooo?ouuuuyy??',
            'fSEZsezYAAAAAAECEEEEIIIIDNOOOOOOUUUUYBaaaaaaeceeeeiiiioonooooouuuuyy');
  -- closeness:
  v_closeness := (GREATEST (LENGTH (v_string1), LENGTH (v_string2)) / 2) - 1;
  -- find matching characters and transpositions within closeness:
  v_temp := v_string2;
  FOR i IN 1 .. LENGTH (v_string1) LOOP
    IF INSTR (v_temp, SUBSTR (v_string1, i, 1)) > 0 THEN
      v_char := SUBSTR (v_string1, i, 1);
      IF ABS (INSTR (v_string1, v_char) - INSTR (v_string2, v_char)) <= v_closeness THEN
        v_comp1 := v_comp1 || SUBSTR (v_string1, i, 1);
        v_temp := SUBSTR (v_temp, 1, INSTR (v_temp, SUBSTR (v_string1, i, 1)) - 1)
               || SUBSTR (v_temp, INSTR (v_temp, SUBSTR (v_string1, i, 1)) + 1);
      END IF;
    END IF;    
  END LOOP;
  v_temp := v_string1;
  FOR i IN 1 .. LENGTH (v_string2) LOOP
    IF INSTR (v_temp, SUBSTR (v_string2, i, 1)) > 0 THEN
      v_char := SUBSTR (v_string2, i, 1);
      IF ABS (INSTR (v_string2, v_char) - INSTR (v_string1, v_char)) <= v_closeness THEN
        v_comp2 := v_comp2 || SUBSTR (v_string2, i, 1);
        v_temp := SUBSTR (v_temp, 1, INSTR (v_temp, SUBSTR (v_string2, i, 1)) - 1)
               || SUBSTR (v_temp, INSTR (v_temp, SUBSTR (v_string2, i, 1)) + 1);
      END IF;
    END IF;    
  END LOOP;
  -- check for null strings:
  IF v_comp1 IS NULL OR v_comp2 IS NULL THEN 
    RETURN 0;
  END IF;
  -- count matches and transpositions within closeness:
  FOR i IN 1 .. LEAST (LENGTH (v_comp1), LENGTH (v_comp2)) LOOP
    IF SUBSTR (v_comp1, i, 1) = SUBSTR (v_comp2, i, 1) THEN
      v_matches := v_matches + 1;
    ELSE
      v_char := SUBSTR (v_comp1, i, 1);
      IF ABS (INSTR (v_string1, v_char) - INSTR (v_string2, v_char)) <= v_closeness THEN
        v_transpositions := v_transpositions + 1;
        v_matches := v_matches + 1;
      END IF; 
    END IF;
  END LOOP;
  v_transpositions := v_transpositions / 2;
  -- check for no matches:
  IF v_matches = 0
    THEN RETURN 0;
  END IF;
  -- Jaro:
  v_d_jaro := ((v_matches / LENGTH (v_string1)) + 
               (v_matches / LENGTH (v_string2)) +
               ((v_matches - v_transpositions) / v_matches)) 
               / 3;
  -- count matching leading characters (up to 4):
  FOR i IN 1 .. LEAST (LENGTH (v_string1), LENGTH (v_string2), 4) LOOP
    IF SUBSTR (v_string1, i, 1) = SUBSTR (v_string2, i, 1) THEN
      v_leading := v_leading + 1;
    ELSE
      EXIT;
    END IF;
  END LOOP;
  -- Winkler:
  v_d_winkler := v_d_jaro + ((v_leading * .1) * (1 - v_d_jaro));
  -- Jaro-Winkler similarity rounded:
  v_jws := ROUND (v_d_winkler * 100);
  RETURN v_jws;
END jws;
/
