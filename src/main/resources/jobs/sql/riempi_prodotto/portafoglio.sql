DECLARE
    BEGIN
	    dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'PORTAFOGLIO', degree => 4, estimate_percent=>1); 

	    dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'TEMP_DELTARAPPORTO', degree => 4, estimate_percent=>1); 
	     
     	INSERT /*+APPEND NOLOGGING PARALLEL(8)*/ INTO PORTAFOGLIO (ID,CODICE,FILEPATH,ISBENCHMARK,ISSHARED,TIPO,TIPO_BENCHMARK,FILENAME,INTESTAZIONE,IDBANCA)
        SELECT IDPTF,ID,' ','N','N','php', 'IDX',' ',' ',CODICEBANCA
        FROM TEMP_DELTARAPPORTO;

     	COMMIT;
END;
