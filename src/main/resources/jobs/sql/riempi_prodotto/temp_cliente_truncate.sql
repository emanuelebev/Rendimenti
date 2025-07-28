BEGIN
  dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'TMP_PFANANDG', degree => 4, estimate_percent=>1);
  EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_CLIENTE DROP STORAGE';
END;
