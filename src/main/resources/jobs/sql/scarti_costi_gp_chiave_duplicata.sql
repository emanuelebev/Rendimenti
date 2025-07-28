DECLARE

CURSOR scarti_costi_gp IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_PFCOSTI_GP tmp
	INNER JOIN (SELECT 	identifier_value, 
						reason, 
						period_start_date, 
						period_end_date, 
						codicetitolo_interno,
						portfolio_id
		    FROM TMP_PFCOSTI_GP 
		    GROUP BY identifier_value, 
						reason, 
						period_start_date, 
						period_end_date, 
						codicetitolo_interno,
						portfolio_id
		    HAVING COUNT(*) >1 ) A
	ON tmp.identifier_value = A.identifier_value
		AND tmp.reason = A.reason
		AND tmp.period_start_date = A.period_start_date
		AND tmp.period_end_date = A.period_end_date
		AND tmp.codicetitolo_interno = A.codicetitolo_interno
		AND tmp.portfolio_id = A.portfolio_id;

TYPE scarti_costi_gp_type IS TABLE OF scarti_costi_gp%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_costi_gp scarti_costi_gp_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_costi_gp;
	LOOP
			FETCH scarti_costi_gp BULK COLLECT INTO res_scarti_costi_gp LIMIT ROWS;
				EXIT WHEN res_scarti_costi_gp.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_costi_gp.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_costi_gp.FIRST .. res_scarti_costi_gp.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFCOSTI_GP (	abi_code, 
														cab_code, 
														account_number, 
														identifier_value, 
														product_identifier, 
														portfolio_id, 
														reason, 
														period_start_date, 
														period_end_date, 
														amount, 
														internal_identifier, 
														date_time, 
														codicetitolo_interno,
														tmstp, 							
														motivo_scarto, 				 
														riproponibile
													)
											VALUES (	res_scarti_costi_gp(j).abi_code, 
														res_scarti_costi_gp(j).cab_code, 
														res_scarti_costi_gp(j).account_number, 
														res_scarti_costi_gp(j).identifier_value, 
														res_scarti_costi_gp(j).product_identifier, 
														res_scarti_costi_gp(j).portfolio_id, 
														res_scarti_costi_gp(j).reason, 
														res_scarti_costi_gp(j).period_start_date, 
														res_scarti_costi_gp(j).period_end_date, 
														res_scarti_costi_gp(j).amount, 
														res_scarti_costi_gp(j).internal_identifier, 
														res_scarti_costi_gp(j).date_time, 
														res_scarti_costi_gp(j).codicetitolo_interno,
														SYSDATE,
														'CHIAVE PRIMARIA "IDENTIFIER_VALUE, REASON, PERIOD_START_DATE, PERIOD_END_DATE, CODICETITOLO_INTERNO, PORTFOLIO_ID" DUPLICATA',
														'N'
													);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_costi_gp.FIRST .. res_scarti_costi_gp.LAST
			        	
			        DELETE FROM TMP_PFCOSTI_GP tmp_del
					WHERE tmp_del.ROWID = res_scarti_costi_gp(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_GP PER CHIAVE (IDENTIFIER_VALUE, REASON, PERIOD_START_DATE, PERIOD_END_DATE, CODICETITOLO_INTERNO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_costi_gp;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_GP PER CHIAVE (IDENTIFIER_VALUE, REASON, PERIOD_START_DATE, PERIOD_END_DATE, CODICETITOLO_INTERNO) DUPLICATA: ' || totale);
	COMMIT;
	
END;