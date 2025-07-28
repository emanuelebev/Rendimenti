DECLARE

CURSOR filtro_costi_prodotto_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codiceagenzia, codicerapporto, tiporapporto, codiceinterno, 
             codicecosto, datada, dataa, importo, fonte, dataaggiornamento, flag_storno   
		ORDER BY codicebanca, codiceagenzia, codicerapporto, tiporapporto, codiceinterno, codicecosto,  
             datada, dataa, importo, fonte, dataaggiornamento, flag_storno) AS pos
		FROM tmp_costi_prodotto
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_costi_prodotto_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_costi_prodotto tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_COSTI_PRODOTTO - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_COSTI_PRODOTTO. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;