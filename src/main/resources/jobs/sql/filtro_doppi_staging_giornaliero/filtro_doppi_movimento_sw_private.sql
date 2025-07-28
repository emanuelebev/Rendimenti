DECLARE

CURSOR filtro_mov_swprivate IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
			row_number() OVER (PARTITION BY numero_polizza, fondo, data_nav, 
					isin, tipo_movimento, nav, quote, importo, cod_linea, data_mov,
					cod_universo, costo_etf
		ORDER BY numero_polizza, fondo, data_nav, 
					isin, tipo_movimento, nav, quote, importo, cod_linea, data_mov,
					cod_universo, costo_etf) AS pos
		FROM tmp_pfmov_swprivate
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_mov_swprivate

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfmov_swprivate tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_SWPRIVATE - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_SWPRIVATE. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;