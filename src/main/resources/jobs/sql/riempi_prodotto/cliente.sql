DECLARE
BEGIN
  dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'CLIENTE', degree => 4,
                                estimate_percent=>1);
MERGE /*+APPEND NOLOGGING PARALLEL(8)*/ INTO CLIENTE C
USING (SELECT NDG, DATADINASCITA, DENOMINAZIONE, CODICETIPOLOGIASOGGETTO
       FROM TEMP_CLIENTE
       minus
       select CODICE, DATANASCITA, INTESTATARIO, TIPO
       from CLIENTE) T
ON (C.CODICE = T.NDG)
WHEN MATCHED THEN
  UPDATE
  SET C.DATANASCITA = T.DATADINASCITA,
      C.INTESTATARIO=T.DENOMINAZIONE,
      C.TIPO=T.CODICETIPOLOGIASOGGETTO
WHEN NOT MATCHED THEN
  INSERT (C.CODICE, C.DATANASCITA, C.INTESTATARIO, C.TIPO)
  VALUES (T.NDG, T.DATADINASCITA, T.DENOMINAZIONE, T.CODICETIPOLOGIASOGGETTO);

COMMIT;

END;
