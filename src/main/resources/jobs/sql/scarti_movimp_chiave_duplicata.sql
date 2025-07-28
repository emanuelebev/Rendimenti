DECLARE

CURSOR scarti_saldi_movimp IS
	SELECT /*+ parallel(8) */  tmp.ROWID, tmp.* 
	FROM tmp_pfsaldi_movimp tmp
	INNER JOIN rapporto R
		ON tmp.codicerapporto = R.codicerapporto
	INNER JOIN (
		SELECT R.ID AS idrapporto, 
			   tmp.codicerapporto AS codicerapporto,
			   tmp.codiceinterno AS codiceinterno	
			  FROM tmp_pfsaldi_movimp tmp
			  INNER JOIN rapporto R
				    ON tmp.codicerapporto = R.codicerapporto
			  GROUP BY R.ID, tmp.codicerapporto, tmp.codiceinterno
			  HAVING COUNT(*) >1) A
	ON R.ID = A.idrapporto
	AND tmp.codiceinterno = A.codiceinterno
	AND tmp.codicerapporto = A.codicerapporto;
	            
TYPE scarti_saldi_movimp_type IS TABLE OF scarti_saldi_movimp%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_saldi_movimp scarti_saldi_movimp_type;
	
ROWS      PLS_INTEGER := 10000;
	        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;
	

BEGIN
	
OPEN scarti_saldi_movimp;
	LOOP
			FETCH scarti_saldi_movimp BULK COLLECT INTO res_scarti_saldi_movimp LIMIT ROWS;
				EXIT WHEN res_scarti_saldi_movimp.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_saldi_movimp.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_saldi_movimp.FIRST .. res_scarti_saldi_movimp.LAST		
	
				INSERT INTO tbl_scarti_tmp_pfsaldi_movimp ( codicebanca,
															codiceagenzia,
															codicerapporto,
															codiceinterno,
															datasaldo,
															tiporapporto,
															datasottoscrizione,
															datascadenza,
															quantita,
															controvalore,
															codicerischio,
															prezzo_medio_carico,
															cambio_medio_carico,
															controvalore_vincolato,
															tmstp,             
															motivo_scarto,     
															riproponibile)
                                                            
												VALUES (res_scarti_saldi_movimp(j).codicebanca,
														res_scarti_saldi_movimp(j).codiceagenzia,
														res_scarti_saldi_movimp(j).codicerapporto,
														res_scarti_saldi_movimp(j).codiceinterno,
														res_scarti_saldi_movimp(j).datasaldo,
														res_scarti_saldi_movimp(j).tiporapporto,
														res_scarti_saldi_movimp(j).datasottoscrizione,
														res_scarti_saldi_movimp(j).datascadenza,
														res_scarti_saldi_movimp(j).quantita,
														res_scarti_saldi_movimp(j).controvalore,
														res_scarti_saldi_movimp(j).codicerischio,
														res_scarti_saldi_movimp(j).prezzo_medio_carico,
														res_scarti_saldi_movimp(j).cambio_medio_carico,
														res_scarti_saldi_movimp(j).controvalore_vincolato,
														sysdate,             
														'CHIAVE PRIMARIA "IDRAPPORTO, CODICERAPPORTO, CODICEINTERNO" DUPLICATA',     
														'N'
														);
														
			COMMIT;
			
			FORALL j IN res_scarti_saldi_movimp.FIRST .. res_scarti_saldi_movimp.LAST
			
			DELETE /*+ nologging */ FROM tmp_pfsaldi_movimp tmp_del
			WHERE tmp_del.ROWID = res_scarti_saldi_movimp(j).ROWID;
				
				        
			        COMMIT;		        
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_MOVIMP PER CHIAVE (IDRAPPORTO, CODICERAPPORTO, CODICEINTERNO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_saldi_movimp;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_MOVIMP PER CHIAVE (IDRAPPORTO, CODICERAPPORTO, CODICEINTERNO) DUPLICATA: ' || totale);
	COMMIT;
END;