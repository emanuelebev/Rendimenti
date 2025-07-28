DECLARE
  i INTEGER;
BEGIN

  dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'NDG', degree => 4,  estimate_percent=>10);
  dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'TEMP_CLIENTE', degree => 4,  estimate_percent=>10);

  MERGE /*+APPEND NOLOGGING PARALLEL(8)*/ INTO NDG C
  USING (SELECT NDG,
                CODICEBANCA,
                AGENZIAANAGRAFICA,
                CODICETIPOLOGIASOGGETTO,
                CODICE_GESTORE,
                DATADINASCITA,
                to_CHAR(ETA) ETA,
                CODICEFISCALE
         FROM TEMP_CLIENTE
         minus
         SELECT CODICE,
                CODICEBANCA,
                FILIALE,
                TIPO,
                EMAIL3,
                DATANASCITA,
                EMAIL2,
                CODICEFISCALE
         from NDG
  ) T
  ON (C.CODICE = T.NDG)
  WHEN MATCHED THEN
    UPDATE
    SET C.STATO='A',
        C.FILIALE=T.AGENZIAANAGRAFICA,
        C.TIPO=T.CODICETIPOLOGIASOGGETTO,
        C.EMAIL3=T.CODICE_GESTORE,
        C.EMAIL2=T.ETA,
        C.CODICEFISCALE=T.CODICEFISCALE
  WHEN NOT MATCHED THEN
    INSERT (C.NDG, C.STATO, C.FILIALE, C.CODICEBANCA, C.CODICE, C.TIPO,  C.EMAIL3, C.EMAIL2, C.DATANASCITA, C.CODICEFISCALE)
    VALUES (T.NDG, 'A', T.AGENZIAANAGRAFICA, T.CODICEBANCA, T.NDG, T.CODICETIPOLOGIASOGGETTO, T.CODICE_GESTORE, T.ETA, T.DATADINASCITA, T.CODICEFISCALE);
  COMMIT;


END;