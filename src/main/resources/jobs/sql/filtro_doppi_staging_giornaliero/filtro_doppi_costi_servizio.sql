DECLARE

CURSOR filtro_costi_servizio_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codicecliente, codicemovimento, codicecosto, codiceagenzia, codicerapporto, 
                tiporapporto, datacontabile, datavaluta, datada, dataa, importo, dataaggiornamento  
		ORDER BY codicebanca, codicecliente, codicemovimento, codicecosto, codiceagenzia, codicerapporto, 
                tiporapporto, datacontabile, datavaluta, datada, dataa, importo, dataaggiornamento) AS pos
		FROM tmp_pfcosti_serv
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_costi_servizio_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfcosti_serv tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFCOSTI_SERV - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFCOSTI_SERV. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;