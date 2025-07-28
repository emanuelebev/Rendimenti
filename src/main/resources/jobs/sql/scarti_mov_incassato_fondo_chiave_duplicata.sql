DECLARE

CURSOR scarti_movimenti_multi IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_PFMOV_INC_FONDO tmp
	INNER JOIN (SELECT id_titolo, ramo, codice_prodotto, numero_polizza, tipo_titolo, data_effetto_titolo, codice_motivo_storno, data_carico, codice_fondo
		    FROM TMP_PFMOV_INC_FONDO 
		    GROUP BY id_titolo, ramo, codice_prodotto, numero_polizza, tipo_titolo, data_effetto_titolo, codice_motivo_storno, data_carico, codice_fondo
		    HAVING COUNT(*) >1 ) A
	ON tmp.id_titolo = A.id_titolo
		AND tmp.ramo = A.ramo
		AND tmp.codice_prodotto = A.codice_prodotto
		AND tmp.numero_polizza = A.numero_polizza
		AND tmp.tipo_titolo = A.tipo_titolo
		AND tmp.data_effetto_titolo = A.data_effetto_titolo
		AND tmp.codice_motivo_storno = A.codice_motivo_storno
		AND tmp.data_carico = A.data_carico
		AND tmp.codice_fondo = A.codice_fondo;

TYPE scarti_movimenti_multi_type IS TABLE OF scarti_movimenti_multi%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_movimenti_multi scarti_movimenti_multi_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_movimenti_multi;
	LOOP
			FETCH scarti_movimenti_multi BULK COLLECT INTO res_scarti_movimenti_multi LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_multi.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_multi.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_FONDO (id_titolo,
															ramo,
															codice_prodotto,
															numero_polizza,
															tipo_titolo,
															data_effetto_titolo,
															codice_motivo_storno,
															data_carico,
															codice_fondo,
															isin,
															quote,
															nav,
															importo,
															data_nav,
															costo_etf,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile
														)
												VALUES (	res_scarti_movimenti_multi(j).id_titolo,
															res_scarti_movimenti_multi(j).ramo,
															res_scarti_movimenti_multi(j).codice_prodotto,
															res_scarti_movimenti_multi(j).numero_polizza,
															res_scarti_movimenti_multi(j).tipo_titolo,
															res_scarti_movimenti_multi(j).data_effetto_titolo,
															res_scarti_movimenti_multi(j).codice_motivo_storno,
															res_scarti_movimenti_multi(j).data_carico,
															res_scarti_movimenti_multi(j).codice_fondo,
															res_scarti_movimenti_multi(j).isin,
															res_scarti_movimenti_multi(j).quote,
															res_scarti_movimenti_multi(j).nav,
															res_scarti_movimenti_multi(j).importo,
															res_scarti_movimenti_multi(j).data_nav,
															res_scarti_movimenti_multi(j).costo_etf,
															SYSDATE,
															'CHIAVE PRIMARIA "ID_TITOLO, RAMO, CODICE_PRODOTTO, NUMERO_POLIZZA, TIPO_TITOLO, DATA_EFFETTO_TITOLO, CODICE_MOTIVO_STORNO, DATA_CARICO, CODICE_FONDO" DUPLICATA',
															'N'
														);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST
			        	
			        DELETE FROM TMP_PFMOV_INC_FONDO tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_multi(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO PER CHIAVE (ID_TITOLO, RAMO, CODICE_PRODOTTO, NUMERO_POLIZZA, TIPO_TITOLO, DATA_EFFETTO_TITOLO, CODICE_MOTIVO_STORNO, DATA_CARICO, CODICE_FONDO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_multi;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO PER CHIAVE (ID_TITOLO, RAMO, CODICE_PRODOTTO, NUMERO_POLIZZA, TIPO_TITOLO, DATA_EFFETTO_TITOLO, CODICE_MOTIVO_STORNO, DATA_CARICO, CODICE_FONDO) DUPLICATA: ' || totale);
	COMMIT;
	
END;