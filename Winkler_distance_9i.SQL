 WITH
   strings AS
      (SELECT NULL          string1, NULL        string2 FROM DUAL UNION ALL
       SELECT 'test'       string1, NULL        string2 FROM DUAL UNION ALL
       SELECT NULL          string1, 'test'        string2 FROM DUAL UNION ALL
       SELECT 'CRATE'      string1, 'TRACE'        string2 FROM DUAL UNION ALL
       SELECT 'MARTHA'     string1, 'MARHTA'     string2 FROM DUAL UNION ALL
       SELECT 'DWAYNE'     string1, 'DUANE'        string2 FROM DUAL UNION ALL
       SELECT 'DIXON'      string1, 'DICKSONX'   string2 FROM DUAL UNION ALL
       SELECT 'Dunningham' string1, 'Cunningham' string2 FROM DUAL UNION ALL
       SELECT 'Abroms'     string1, 'Abrams'     string2 FROM DUAL UNION ALL
       SELECT 'Lampley'    string1, 'Campley'    string2 FROM DUAL UNION ALL
       SELECT 'Jonathon'   string1, 'Jonathan'   string2 FROM DUAL UNION ALL
       SELECT 'Jeraldine'  string1, 'Gerladine'  string2 FROM DUAL UNION ALL
       SELECT 'test'       string1, 'blank'        string2 FROM DUAL UNION ALL
       SELECT 'everybody'  string1, 'every'        string2 FROM DUAL UNION ALL
       SELECT 'a'          string1, 'aaa'        string2 FROM DUAL UNION ALL
       SELECT 'Géraldine'  string1, 'Gerladine'  string2 FROM DUAL UNION ALL
       SELECT 'Jérôme'     string1, 'Jerome'     string2 FROM DUAL UNION ALL
       SELECT 'ça'          string1, 'ca'        string2 FROM DUAL UNION ALL
       SELECT 'Üwe'          string1, 'Uwe'        string2 FROM DUAL)
 SELECT string1, string2,
         --UTL_MATCH.JARO_WINKLER_SIMILARITY (string1, string2) oracle_jws,
         jws (string1, string2) my_jws
 FROM   strings
 ORDER  BY my_jws DESC
 /