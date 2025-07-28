DECLARE

CURSOR scarti_quotazione IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_QUOTAZIONE_R3 tmp
	INNER JOIN (SELECT codice_prodotto, codice_fondo, data_riferimento
		    FROM TMP_QUOTAZIONE_R3 
		    GROUP BY codice_prodotto, codice_fondo, data_riferimento
		    HAVING COUNT(*) >1 ) A
	ON tmp.codice_prodotto = A.codice_prodotto
		AND tmp.codice_fondo = A.codice_fondo
		AND tmp.data_riferimento = A.data_riferimento;

TYPE scarti_quotazione_type IS TABLE OF scarti_quotazione%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_quotazione scarti_quotazione_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_quotazione;
	LOOP
			FETCH scarti_quotazione BULK COLLECT INTO res_scarti_quotazione LIMIT ROWS;
				EXIT WHEN res_scarti_quotazione.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_quotazione.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_quotazione.FIRST .. res_scarti_quotazione.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_QUOTAZIONE_R3 (	codice_prodotto,
															codice_fondo,
															descrizione_fondo,
															data_riferimento,
															valore,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile
														)
												VALUES (	res_scarti_quotazione(j).codice_prodotto,
															res_scarti_quotazione(j).codice_fondo,
															res_scarti_quotazione(j).descrizione_fondo,
															res_scarti_quotazione(j).data_riferimento,
															res_scarti_quotazione(j).valore,
															SYSDATE,
															'CHIAVE PRIMARIA "CODICE_PRODOTTO, CODICE_FONDO, DATA_RIFERIMENTO" DUPLICATA',
															'N'
														);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_quotazione.FIRST .. res_scarti_quotazione.LAST
			        	
			        DELETE FROM TMP_QUOTAZIONE_R3 tmp_del
					WHERE tmp_del.ROWID = res_scarti_quotazione(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_QUOTAZIONE_R3 PER CHIAVE (CODICE_PRODOTTO, CODICE_FONDO, DATA_RIFERIMENTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_quotazione;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_QUOTAZIONE_R3 PER CHIAVE (CODICE_PRODOTTO, CODICE_FONDO, DATA_RIFERIMENTO) DUPLICATA: ' || totale);
	COMMIT;
	
END;