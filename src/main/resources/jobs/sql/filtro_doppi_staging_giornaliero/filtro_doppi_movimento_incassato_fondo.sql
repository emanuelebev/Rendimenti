DECLARE

CURSOR filtro_mov_inc_fondo IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
			row_number() OVER (PARTITION BY id_titolo, ramo, codice_prodotto, numero_polizza, 
			tipo_titolo, data_effetto_titolo, codice_motivo_storno, data_carico, codice_fondo, 
			isin, quote, nav, importo, data_nav, costo_etf 
		ORDER BY id_titolo, ramo, codice_prodotto, numero_polizza, 
			tipo_titolo, data_effetto_titolo, codice_motivo_storno, data_carico, codice_fondo, 
			isin, quote, nav, importo, data_nav, costo_etf) AS pos
		FROM tmp_pfmov_inc_fondo
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_mov_inc_fondo

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfmov_inc_fondo tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_INC_FONDO - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_INC_FONDO. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;