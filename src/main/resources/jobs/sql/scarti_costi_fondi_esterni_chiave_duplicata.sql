DECLARE

CURSOR scarti_costi_fondi_esterni IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_PFCOSTI_AFB tmp
	INNER JOIN (SELECT 	ACTION,
						PERIOD_INITIAL_DATE, 
						PERIOD_FINAL_DATE, 
						SOURCE_CONTRACT, 
						ISIN, 
						CONCEPT
		    FROM TMP_PFCOSTI_AFB 
		    GROUP BY ACTION,
		    			PERIOD_INITIAL_DATE, 
						PERIOD_FINAL_DATE, 
						SOURCE_CONTRACT, 
						ISIN, 
						CONCEPT
		    HAVING COUNT(*) >1 ) A
	ON tmp.ACTION = A.ACTION
		AND tmp.PERIOD_INITIAL_DATE = A.PERIOD_INITIAL_DATE
		AND tmp.PERIOD_FINAL_DATE = A.PERIOD_FINAL_DATE
		AND tmp.SOURCE_CONTRACT = A.SOURCE_CONTRACT
		AND tmp.ISIN = A.ISIN
		AND tmp.CONCEPT = A.CONCEPT;

TYPE scarti_costi_fondi_esterni_type IS TABLE OF scarti_costi_fondi_esterni%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_costi_fondi_esterni scarti_costi_fondi_esterni_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_costi_fondi_esterni;
	LOOP
			FETCH scarti_costi_fondi_esterni BULK COLLECT INTO res_scarti_costi_fondi_esterni LIMIT ROWS;
				EXIT WHEN res_scarti_costi_fondi_esterni.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_costi_fondi_esterni.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_costi_fondi_esterni.FIRST .. res_scarti_costi_fondi_esterni.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFCOSTI_AFB (DISTRIBUTOR_CODE,
														SUB_DIST_CODE,
														RECORD_TYPE,
														ACTION, 
														PERIOD_INITIAL_DATE, 
														PERIOD_FINAL_DATE,
														SOURCE_CONTRACT,
														ISIN,
														RESERVED1,
														RESERVED2,
														RESERVED3,
														CONCEPT,
														SIGN_AMT,
														AMOUNT,
														CURRENCY,
														PERCENTAGE,
														SIGN_AMT_CLI,
														AMOUNT_CURRENCY,
														CURRENCY_CLIENT,
														INFORMATION_FLAG,
														TMSTP, 							
														MOTIVO_SCARTO, 				 
														RIPROPONIBILE
													)
											VALUES (	res_scarti_costi_fondi_esterni(j).DISTRIBUTOR_CODE,
														res_scarti_costi_fondi_esterni(j).SUB_DIST_CODE,
														res_scarti_costi_fondi_esterni(j).RECORD_TYPE,
														res_scarti_costi_fondi_esterni(j).ACTION, 
														res_scarti_costi_fondi_esterni(j).PERIOD_INITIAL_DATE, 
														res_scarti_costi_fondi_esterni(j).PERIOD_FINAL_DATE,
														res_scarti_costi_fondi_esterni(j).SOURCE_CONTRACT,
														res_scarti_costi_fondi_esterni(j).ISIN,
														res_scarti_costi_fondi_esterni(j).RESERVED1,
														res_scarti_costi_fondi_esterni(j).RESERVED2,
														res_scarti_costi_fondi_esterni(j).RESERVED3,
														res_scarti_costi_fondi_esterni(j).CONCEPT,
														res_scarti_costi_fondi_esterni(j).SIGN_AMT,
														res_scarti_costi_fondi_esterni(j).AMOUNT,
														res_scarti_costi_fondi_esterni(j).CURRENCY,
														res_scarti_costi_fondi_esterni(j).PERCENTAGE,
														res_scarti_costi_fondi_esterni(j).SIGN_AMT_CLI,
														res_scarti_costi_fondi_esterni(j).AMOUNT_CURRENCY,
														res_scarti_costi_fondi_esterni(j).CURRENCY_CLIENT,
														res_scarti_costi_fondi_esterni(j).INFORMATION_FLAG,
														SYSDATE,
														'CHIAVE PRIMARIA "ACTION, PERIOD_INITIAL_DATE, PERIOD_FINAL_DATE, SOURCE_CONTRACT, ISIN, CONCEPT" DUPLICATA',
														'N'
													);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_costi_fondi_esterni.FIRST .. res_scarti_costi_fondi_esterni.LAST
			        	
			        DELETE FROM TMP_PFCOSTI_AFB tmp_del
					WHERE tmp_del.ROWID = res_scarti_costi_fondi_esterni(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB PER CHIAVE (PERIOD_INITIAL_DATE, PERIOD_FINAL_DATE, SOURCE_CONTRACT, ISIN, CONCEPT) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_costi_fondi_esterni;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB PER CHIAVE (PERIOD_INITIAL_DATE, PERIOD_FINAL_DATE, SOURCE_CONTRACT, ISIN, CONCEPT) DUPLICATA: ' || totale);
	COMMIT;
	
END;