DECLARE

CURSOR scarti_fondo_nuovo IS 	
    SELECT /*+ parallel(8) */  tmp.ROWID,
			tmp.*
	FROM TMP_PFMOV_SWPRIVATE TMP
	LEFT JOIN TMP_PFMOV_SWPRIVATE TMP2
    ON tmp.numero_polizza = TMP2.numero_polizza
        AND TMP2.tipo_movimento = 'Fondo Nuovo'
	 WHERE TMP.tipo_movimento = 'Fondo Precedente'
     and TMP2.numero_polizza is null;
     

CURSOR scarti_fondo_precedente IS 	
    SELECT /*+ parallel(8) */  tmp.ROWID,
			tmp.*
	FROM TMP_PFMOV_SWPRIVATE TMP
	LEFT JOIN TMP_PFMOV_SWPRIVATE TMP2
    ON tmp.numero_polizza = TMP2.numero_polizza
        AND TMP2.tipo_movimento = 'Fondo Precedente'
	 WHERE TMP.tipo_movimento = 'Fondo Nuovo'
     and TMP2.numero_polizza is null;
     

TYPE scarti_fondo_nuovo_type IS TABLE OF scarti_fondo_nuovo%rowtype INDEX BY PLS_INTEGER;
TYPE scarti_fondo_precedente_type IS TABLE OF scarti_fondo_precedente%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_fondo_nuovo scarti_fondo_nuovo_type;
res_scarti_fondo_precedente scarti_fondo_precedente_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 						NUMBER(38,0);
count_nuovo				NUMBER(38,0):=0;
count_precedente		NUMBER(38,0):=0;



BEGIN
	
	OPEN scarti_fondo_nuovo;
	LOOP
			FETCH scarti_fondo_nuovo BULK COLLECT INTO res_scarti_fondo_nuovo LIMIT ROWS;
				EXIT WHEN res_scarti_fondo_nuovo.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_fondo_nuovo.COUNT;
	      count_nuovo := count_nuovo + I;
				
				FORALL j IN res_scarti_fondo_nuovo.FIRST .. res_scarti_fondo_nuovo.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_SWPRIVATE (numero_polizza,
															fondo,
															data_nav,
															isin,
															tipo_movimento,
															nav,
															quote,
															importo,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile,
															cod_linea,
															data_mov,
															cod_universo,
															costo_etf
														)
												VALUES (	res_scarti_fondo_nuovo(j).numero_polizza,
															res_scarti_fondo_nuovo(j).fondo,
															res_scarti_fondo_nuovo(j).data_nav,
															res_scarti_fondo_nuovo(j).isin,
															res_scarti_fondo_nuovo(j).tipo_movimento,
															res_scarti_fondo_nuovo(j).nav,
															res_scarti_fondo_nuovo(j).quote,
															res_scarti_fondo_nuovo(j).importo,
															SYSDATE,
															'FONDO NUOVO MANCANTE',
															'N',
															res_scarti_fondo_nuovo(j).cod_linea,
															res_scarti_fondo_nuovo(j).data_mov,
															res_scarti_fondo_nuovo(j).cod_universo,
															res_scarti_fondo_nuovo(j).costo_etf
														);
			        COMMIT;		
			        
			        FORALL j IN res_scarti_fondo_nuovo.FIRST .. res_scarti_fondo_nuovo.LAST
			        	
			        DELETE FROM TMP_PFMOV_SWPRIVATE tmp_del
					WHERE tmp_del.ROWID = res_scarti_fondo_nuovo(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER FONDO NUOVO MANCANTE: ' || count_nuovo || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_fondo_nuovo;
	
    
	
	OPEN scarti_fondo_precedente;
	LOOP
			FETCH scarti_fondo_precedente BULK COLLECT INTO res_scarti_fondo_precedente LIMIT ROWS;
				EXIT WHEN res_scarti_fondo_precedente.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_fondo_precedente.COUNT;
	      count_precedente := count_precedente + I;
				
				FORALL j IN res_scarti_fondo_precedente.FIRST .. res_scarti_fondo_precedente.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_SWPRIVATE (numero_polizza,
															fondo,
															data_nav,
															isin,
															tipo_movimento,
															nav,
															quote,
															importo,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile,
															cod_linea,
															data_mov,
															cod_universo,
															costo_etf
														)
												VALUES (	res_scarti_fondo_precedente(j).numero_polizza,
															res_scarti_fondo_precedente(j).fondo,
															res_scarti_fondo_precedente(j).data_nav,
															res_scarti_fondo_precedente(j).isin,
															res_scarti_fondo_precedente(j).tipo_movimento,
															res_scarti_fondo_precedente(j).nav,
															res_scarti_fondo_precedente(j).quote,
															res_scarti_fondo_precedente(j).importo,
															SYSDATE,
															'FONDO PRECEDENTE MANCANTE',
															'N',
															res_scarti_fondo_precedente(j).cod_linea,
															res_scarti_fondo_precedente(j).data_mov,
															res_scarti_fondo_precedente(j).cod_universo,
															res_scarti_fondo_precedente(j).costo_etf
														);
			        COMMIT;		
			        
			        FORALL j IN res_scarti_fondo_precedente.FIRST .. res_scarti_fondo_precedente.LAST
			        	
			        DELETE FROM TMP_PFMOV_SWPRIVATE tmp_del
					WHERE tmp_del.ROWID = res_scarti_fondo_precedente(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER FONDO PRECEDENTE MANCANTE: ' || count_precedente || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_fondo_precedente;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER FONDO NUOVO NON TROVATO: ' || count_nuovo);
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER FONDO PRECEDENTE NON TROVATO: ' || count_precedente);
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER FONDO NON TROVATO: ' || I || ' totale');
	COMMIT;
	
END;