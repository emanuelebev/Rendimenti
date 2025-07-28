DECLARE

CURSOR filtro_saldi_gp_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY numero_deposito, numero_sottodeposito, codicetitolo_interno, importo_concordato, 
										data_saldo, quantita, ctv_carico, ctv_mercato, portafoglio_id
		ORDER BY numero_deposito, numero_sottodeposito, codicetitolo_interno, importo_concordato, 
				 data_saldo, quantita, ctv_carico, ctv_mercato, portafoglio_id ) AS pos
		FROM tmp_pfsaldi_gp
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_saldi_gp_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfsaldi_gp tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDI_GP - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDI_GP. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;