DECLARE

CURSOR scarti_costi_prod IS
	SELECT /*+ parallel(8) */ tmp.ROWID, tmp.* 
	FROM TMP_COSTI_PRODOTTO tmp
	INNER JOIN (SELECT codicebanca, codicerapporto, tiporapporto, codiceinterno, codicecosto, dataa, datada, flag_storno 
		    FROM TMP_COSTI_PRODOTTO tcost
		    GROUP BY codicebanca, codicerapporto, tiporapporto, codiceinterno, codicecosto, dataa, datada, flag_storno 
		    HAVING COUNT(*) >1) A
	ON tmp.codicebanca = A.codicebanca
		AND tmp.codicerapporto = A.codicerapporto
		AND tmp.tiporapporto = A.tiporapporto
		AND tmp.codiceinterno = A.codiceinterno
		AND tmp.codicecosto = A.codicecosto
		AND tmp.dataa = A.dataa
		AND tmp.datada = A.datada
		AND tmp.flag_storno = A.flag_storno;


TYPE scarti_costi_prod_type IS TABLE OF scarti_costi_prod%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_costi_prod scarti_costi_prod_type;
	
ROWS    PLS_INTEGER := 10000;
	        
I 		NUMBER(38,0);
totale	NUMBER(38,0):=0;
	

BEGIN
	
OPEN scarti_costi_prod;
	LOOP
			FETCH scarti_costi_prod BULK COLLECT INTO res_scarti_costi_prod LIMIT ROWS;
				EXIT WHEN res_scarti_costi_prod.COUNT = 0;  
				
	I:=0;
	I:= res_scarti_costi_prod.COUNT;
	totale := totale + I;
				
		FORALL j IN res_scarti_costi_prod.FIRST .. res_scarti_costi_prod.LAST		
	
			INSERT INTO TBL_SCARTI_TMP_COSTI_PRODOTTO(	codicebanca,
														codiceagenzia,
														codicerapporto,
														tiporapporto,
														codiceinterno,
														codicecosto,
														datada,
														dataa,
														importo,
														fonte,
														dataaggiornamento,
														tmstp,
														motivo_scarto,
														riproponibile
							)
			VALUES (res_scarti_costi_prod(j).CODICEBANCA,
					res_scarti_costi_prod(j).codiceagenzia,
					res_scarti_costi_prod(j).codicerapporto,
					res_scarti_costi_prod(j).tiporapporto,
					res_scarti_costi_prod(j).codiceinterno,
					res_scarti_costi_prod(j).codicecosto,
					res_scarti_costi_prod(j).datada,
					res_scarti_costi_prod(j).dataa,
					res_scarti_costi_prod(j).importo,
					res_scarti_costi_prod(j).fonte,
					res_scarti_costi_prod(j).dataaggiornamento,
					sysdate,
					'CHIAVE PRIMARIA "CODICEBANCA, CODICEAGENZIA, CODICERAPPORTO, TIPORAPPORTO, CODICEINTERNO, CODICECOSTO, DATAA, DATADA" DUPLICATA',
					'N'
					);
				
			        COMMIT;		
			        
			FORALL j IN res_scarti_costi_prod.FIRST .. res_scarti_costi_prod.LAST
			        	
		        DELETE   FROM TMP_COSTI_PRODOTTO tmp_del
				WHERE tmp_del.ROWID = res_scarti_costi_prod(j).ROWID;
					
				COMMIT;       	
	            
     INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_COSTI_PRODOTTO 
				PER CHIAVE (CODICEBANCA, CODICEAGENZIA, CODICERAPPORTO, TIPORAPPORTO, CODICEINTERNO, CODICECOSTO, DATAA, DATADA) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;

CLOSE scarti_costi_prod;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || 
	' SCARTI TMP_COSTI_PRODOTTO PER CHIAVE (CODICEBANCA, CODICEAGENZIA, CODICERAPPORTO, TIPORAPPORTO, CODICEINTERNO, CODICECOSTO, DATAA, DATADA) DUPLICATA: ' || totale);
	COMMIT;
END;