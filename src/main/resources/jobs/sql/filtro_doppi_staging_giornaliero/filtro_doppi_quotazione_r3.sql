DECLARE

CURSOR filtro_quotazione_r3 IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
			row_number() OVER (PARTITION BY codice_prodotto, codice_fondo, 
				descrizione_fondo, data_riferimento, valore
		ORDER BY codice_prodotto, codice_fondo, 
				descrizione_fondo, data_riferimento, valore) AS pos
		FROM tmp_quotazione_r3
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_quotazione_r3

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_quotazione_r3 tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_QUOTAZIONE_R3 - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_QUOTAZIONE_R3. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;