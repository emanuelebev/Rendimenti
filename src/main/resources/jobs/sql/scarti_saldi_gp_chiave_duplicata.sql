DECLARE

CURSOR scarti_saldi_gp IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_PFSALDI_GP tmp
	INNER JOIN (SELECT numero_deposito, numero_sottodeposito, codicetitolo_interno, data_saldo, portafoglio_id
		    FROM TMP_PFSALDI_GP 
		    GROUP BY numero_deposito, numero_sottodeposito, codicetitolo_interno, data_saldo, portafoglio_id
		    HAVING COUNT(*) >1 ) A
	ON tmp.numero_deposito = A.numero_deposito
		AND tmp.numero_sottodeposito = A.numero_sottodeposito
		AND tmp.codicetitolo_interno = A.codicetitolo_interno
		AND tmp.data_saldo = A.data_saldo
		AND tmp.portafoglio_id = A.portafoglio_id;

TYPE scarti_saldi_gp_type IS TABLE OF scarti_saldi_gp%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_saldi_gp scarti_saldi_gp_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_saldi_gp;
	LOOP
			FETCH scarti_saldi_gp BULK COLLECT INTO res_scarti_saldi_gp LIMIT ROWS;
				EXIT WHEN res_scarti_saldi_gp.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_saldi_gp.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_saldi_gp.FIRST .. res_scarti_saldi_gp.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFSALDI_GP (	numero_deposito,
														numero_sottodeposito,
														codicetitolo_interno,
														importo_concordato,
														data_saldo,
														quantita,
														ctv_carico,
														ctv_mercato,
														portafoglio_id,
														tmstp, 							
														motivo_scarto, 				 
														riproponibile
													)
											VALUES (	res_scarti_saldi_gp(j).numero_deposito,
														res_scarti_saldi_gp(j).numero_sottodeposito,
														res_scarti_saldi_gp(j).codicetitolo_interno,
														res_scarti_saldi_gp(j).importo_concordato,
														res_scarti_saldi_gp(j).data_saldo,
														res_scarti_saldi_gp(j).quantita,
														res_scarti_saldi_gp(j).ctv_carico,
														res_scarti_saldi_gp(j).ctv_mercato,
														res_scarti_saldi_gp(j).portafoglio_id,
														SYSDATE,
														'CHIAVE PRIMARIA "NUMERO_DEPOSITO, NUMERO_SOTTODEPOSITO, CODICETITOLO_INTERNO, DATA_SALDO, PORTAFOGLIO_ID" DUPLICATA',
														'N'
													);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_saldi_gp.FIRST .. res_scarti_saldi_gp.LAST
			        	
			        DELETE FROM TMP_PFSALDI_GP tmp_del
					WHERE tmp_del.ROWID = res_scarti_saldi_gp(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_GP PER CHIAVE (NUMERO_DEPOSITO, NUMERO_SOTTODEPOSITO, CODICETITOLO_INTERNO, DATA_SALDO, PORTAFOGLIO_ID) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_saldi_gp;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_GP PER CHIAVE (NUMERO_DEPOSITO, NUMERO_SOTTODEPOSITO, CODICETITOLO_INTERNO, DATA_SALDO, PORTAFOGLIO_ID) DUPLICATA: ' || totale);
	COMMIT;
	
END;