DECLARE

CURSOR filtro_cambi_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codicedivisacerto, codicedivisaincerto,  datacambio, cambio, dataaggiornamento 
		ORDER BY codicebanca, codicedivisacerto, codicedivisaincerto,  datacambio, cambio, dataaggiornamento) AS pos
		FROM tmp_pfcambi
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_cambi_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfcambi tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFCAMBI - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFCAMBI. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;