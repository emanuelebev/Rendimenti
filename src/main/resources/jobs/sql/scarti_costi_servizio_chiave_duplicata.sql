DECLARE

CURSOR scarti_costi_serv IS
	SELECT /*+ parallel(8) */ tmp.ROWID, tmp.* 
	FROM tmp_pfcosti_serv tmp
	INNER JOIN (SELECT codicebanca, codicerapporto, tiporapporto, codicecosto, codicemovimento, datavaluta
			    FROM tmp_pfcosti_serv tcost
			    GROUP BY codicebanca, codicerapporto, tiporapporto, codicecosto, codicemovimento, datavaluta
			    HAVING COUNT(*) >1) A
	ON tmp.codicebanca = A.codicebanca
		AND tmp.codicerapporto = A.codicerapporto
		AND tmp.codicecosto = A.codicecosto
		AND tmp.codicemovimento = A.codicemovimento
		AND tmp.tiporapporto = A.tiporapporto
		AND tmp.datavaluta = A.datavaluta;


TYPE scarti_costi_serv_type IS TABLE OF scarti_costi_serv%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_costi_serv scarti_costi_serv_type;
	
ROWS    PLS_INTEGER := 10000;
	        
I 		NUMBER(38,0);
totale	NUMBER(38,0):=0;
	

BEGIN
	
OPEN scarti_costi_serv;
	LOOP
			FETCH scarti_costi_serv BULK COLLECT INTO res_scarti_costi_serv LIMIT ROWS;
				EXIT WHEN res_scarti_costi_serv.COUNT = 0;  
				
	I:=0;
	I:= res_scarti_costi_serv.COUNT;
	totale := totale + I;
				
		FORALL j IN res_scarti_costi_serv.FIRST .. res_scarti_costi_serv.LAST		
	
			INSERT INTO tbl_scarti_tmp_pfcosti_serv(	codicebanca,
														codicecliente,
														codicemovimento,
														codicecosto,
														codiceagenzia,
														codicerapporto,
														tiporapporto,
														datacontabile,
														datavaluta,
														datada,
														dataa,
														importo,
														dataaggiornamento,
														tmstp,
														motivo_scarto,
														riproponibile
													)
											VALUES (res_scarti_costi_serv(j).codicebanca,
													res_scarti_costi_serv(j).codicecliente,
													res_scarti_costi_serv(j).codicemovimento,
													res_scarti_costi_serv(j).codicecosto,
													res_scarti_costi_serv(j).codiceagenzia,
													res_scarti_costi_serv(j).codicerapporto,
													res_scarti_costi_serv(j).tiporapporto,
													res_scarti_costi_serv(j).datacontabile,
													res_scarti_costi_serv(j).datavaluta,
													res_scarti_costi_serv(j).datada,
													res_scarti_costi_serv(j).dataa,
													res_scarti_costi_serv(j).importo,
													res_scarti_costi_serv(j).dataaggiornamento,
													sysdate,
													'CHIAVE PRIMARIA "CODICEBANCA, CODICERAPPORTO, TIPORAPPORTO, CODICECOSTO, CODICEMOVIMENTO, DATAVALUTA" DUPLICATA',
													'N'
													);
				
			        COMMIT;		
			        
			FORALL j IN res_scarti_costi_serv.FIRST .. res_scarti_costi_serv.LAST
			        	
		        DELETE   FROM tmp_pfcosti_serv tmp_del
				WHERE tmp_del.ROWID = res_scarti_costi_serv(j).ROWID;
					
				COMMIT;       	
	            
     INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || 
     		' SCARTI TMP_PFCOSTI_SERV PER CHIAVE (CODICEBANCA, CODICERAPPORTO, TIPORAPPORTO, CODICECOSTO, CODICEMOVIMENTO, DATAVALUTA) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;

CLOSE scarti_costi_serv;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || 
			' SCARTI TMP_PFCOSTI_SERV PER CHIAVE (CODICEBANCA, CODICERAPPORTO, TIPORAPPORTO, CODICECOSTO, CODICEMOVIMENTO, DATAVALUTA) DUPLICATA: ' || totale);
	COMMIT;
END;