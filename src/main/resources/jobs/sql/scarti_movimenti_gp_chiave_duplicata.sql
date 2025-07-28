DECLARE

CURSOR scarti_movimenti_gp IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_PFMOV_GP tmp
	INNER JOIN (SELECT codice_transazione
		    FROM TMP_PFMOV_GP 
		    GROUP BY codice_transazione
		    HAVING COUNT(*) >1 ) A
	ON tmp.codice_transazione = A.codice_transazione;

TYPE scarti_movimenti_gp_type IS TABLE OF scarti_movimenti_gp%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_movimenti_gp scarti_movimenti_gp_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_movimenti_gp;
	LOOP
			FETCH scarti_movimenti_gp BULK COLLECT INTO res_scarti_movimenti_gp LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_gp.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_gp.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_gp.FIRST .. res_scarti_movimenti_gp.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_GP (	codice_transazione,
														data_settlement,
														data_transazione,
														numero_deposito,
														numero_sottodeposito,
														codicetitolo_interno,
														importo_transato,
														causale_movimento,
														quantita_ordinata,
														quantita_effettiva,
														segno,
														commissioni,
														divisa_trattazione,
														cambio,
														canale_ordine,
														ndg,
														codicefiscale,
														tmstp, 							
														motivo_scarto, 				 
														riproponibile,
														id_prodotto,
														upfront_fee_lorda, 
														upfront_fee_netta, 	
														upfront_fee_retrocessioni
													)
											VALUES (	res_scarti_movimenti_gp(j).codice_transazione,
														res_scarti_movimenti_gp(j).data_settlement,
														res_scarti_movimenti_gp(j).data_transazione,
														res_scarti_movimenti_gp(j).numero_deposito,
														res_scarti_movimenti_gp(j).numero_sottodeposito,
														res_scarti_movimenti_gp(j).codicetitolo_interno,
														res_scarti_movimenti_gp(j).importo_transato,
														res_scarti_movimenti_gp(j).causale_movimento,
														res_scarti_movimenti_gp(j).quantita_ordinata,
														res_scarti_movimenti_gp(j).quantita_effettiva,
														res_scarti_movimenti_gp(j).segno,
														res_scarti_movimenti_gp(j).commissioni,
														res_scarti_movimenti_gp(j).divisa_trattazione,
														res_scarti_movimenti_gp(j).cambio,
														res_scarti_movimenti_gp(j).canale_ordine,
														res_scarti_movimenti_gp(j).ndg,
														res_scarti_movimenti_gp(j).codicefiscale,
														SYSDATE,
														'CHIAVE PRIMARIA "CODICE_TRANSAZIONE" DUPLICATA',
														'N',
														res_scarti_movimenti_gp(j).id_prodotto,
														res_scarti_movimenti_gp(j).upfront_fee_lorda, 
														res_scarti_movimenti_gp(j).upfront_fee_netta, 	
														res_scarti_movimenti_gp(j).upfront_fee_retrocessioni
													);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_gp.FIRST .. res_scarti_movimenti_gp.LAST
			        	
			        DELETE FROM TMP_PFMOV_GP tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_gp(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP PER CHIAVE (CODICE_TRANSAZIONE) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_gp;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP PER CHIAVE (CODICE_TRANSAZIONE) DUPLICATA: ' || totale);
	COMMIT;
	
END;