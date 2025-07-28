--Controllo sul cambio settimana e sul cambio mese 
--Prende la data massima delle polizze in essere e le salta al momento t1
--Calcola la settimana dell'anno prendendo la massima data aggiornamento della polizza in arriva nel flusso

BEGIN

	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 'maxyearweek' AS chiave,
	        MAX(CASE WHEN (TO_NUMBER(TO_CHAR(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW')) > 51 AND EXTRACT(MONTH FROM (TO_DATE(dataaggiornamento, 'YYYYMMDD'))) = 1) THEN 
  			 			 	(TO_NUMBER(CONCAT(EXTRACT(YEAR FROM (TO_DATE(dataaggiornamento, 'YYYYMMDD')))-1, TO_CHAR(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW'))))
					ELSE 
							(TO_NUMBER(CONCAT(EXTRACT(YEAR FROM (TO_DATE(dataaggiornamento, 'YYYYMMDD'))), TO_CHAR(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW')))) END) AS valore
	        FROM tmp_pfsaldi_polizze
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	
	
	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 'maxyearmonth' AS chiave,
	        MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0')))) AS valore
	        FROM tmp_pfsaldi_polizze
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	
	
	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 'maxyearweeksp' AS chiave,
	        MAX(CASE WHEN (TO_NUMBER(TO_CHAR(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW')) > 51 AND EXTRACT(MONTH FROM (TO_DATE(dataaggiornamento, 'YYYYMMDD'))) = 1) THEN 
  			 			 	(TO_NUMBER(CONCAT(EXTRACT(YEAR FROM (TO_DATE(dataaggiornamento, 'YYYYMMDD')))-1, TO_CHAR(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW'))))
					ELSE 
							(TO_NUMBER(CONCAT(EXTRACT(YEAR FROM (TO_DATE(dataaggiornamento, 'YYYYMMDD'))), TO_CHAR(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW')))) END)  AS valore
	        FROM tmp_pfsaldi_polizze_sp
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	
	
	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 'maxyearmonthsp' AS chiave,
	        MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0')))) AS valore
	        FROM tmp_pfsaldi_polizze_sp
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	
	
	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 't1pz' AS chiave,
	        nvl(MAX(yearweek), 0) AS valore
	        FROM saldo_rend_polizze
	        WHERE tipo_pol = 'PZ'
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	    
	
	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 't1mpz' AS chiave,
	        nvl(MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0')))),0) AS valore
	        FROM saldo_rend_polizze
	        WHERE tipo_pol = 'PZ'
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	
	
	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 't1sp' AS chiave,
	        nvl(MAX(yearweek), 0) AS valore
	        FROM saldo_rend_polizze
	        WHERE tipo_pol = 'SP'
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	    
	
	MERGE /*+ NOLOGGING PARALLEL(8) */ INTO maxdata_polizze mp
	USING ( SELECT 't1msp' AS chiave,
	        nvl(MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0')))),0) AS valore
	        FROM saldo_rend_polizze
	        WHERE tipo_pol = 'SP'
	) tomerge
	ON (mp.chiave = tomerge.chiave)
	WHEN MATCHED THEN UPDATE
		SET mp.valore = tomerge.valore
	
	WHEN NOT MATCHED 
	    THEN INSERT	(	chiave,
	                    valore)
	        VALUES(  tomerge.chiave,
	                 tomerge.valore);
	                 
	COMMIT;
	
END;