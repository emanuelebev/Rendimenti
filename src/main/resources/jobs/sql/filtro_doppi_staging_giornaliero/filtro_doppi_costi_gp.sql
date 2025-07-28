DECLARE

CURSOR filtro_costi_gp_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY abi_code, cab_code, account_number, identifier_value, product_identifier, 
							portfolio_id, reason, period_start_date, period_end_date, amount, internal_identifier, date_time, codicetitolo_interno 
		ORDER BY abi_code, cab_code, account_number, identifier_value, product_identifier, portfolio_id, reason, period_start_date, 
					period_end_date, amount, internal_identifier, date_time, codicetitolo_interno) AS pos
		FROM tmp_pfcosti_gp
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_costi_gp_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfcosti_gp tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFCOSTI_GP - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFCOSTI_GP. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;