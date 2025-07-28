DECLARE

CURSOR del_cur IS
	SELECT /*+ parallel(8) */ scarto.ROWID AS scarto_rowid, 
			scarto.*, 
			tmp.ROWID AS tmp_rowid
	FROM tbl_scarti_tmp_pfcosti_gp scarto
	LEFT JOIN tmp_pfcosti_gp tmp
		ON( tmp.identifier_value = scarto.identifier_value
			AND tmp.reason = scarto.reason
			AND tmp.period_start_date = scarto.period_start_date
			AND tmp.period_end_date = scarto.period_end_date
			AND tmp.codicetitolo_interno = scarto.codicetitolo_interno
			AND tmp.portfolio_id = scarto.portfolio_id)
	WHERE scarto.riproponibile = 'S';

I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN

	FOR cur_item IN del_cur 

		LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
		INSERT /*+ append nologging parallel(8) */
				INTO tmp_pfcosti_gp (	abi_code, 
										cab_code, 
										account_number, 
										identifier_value, 
										product_identifier, 
										portfolio_id, 
										reason, 
										period_start_date, 
										period_end_date, 
										amount, 
										internal_identifier, 
										date_time, 
										codicetitolo_interno
									)
								VALUES (cur_item.abi_code, 
										cur_item.cab_code, 
										cur_item.account_number, 
										cur_item.identifier_value, 
										cur_item.product_identifier, 
										cur_item.portfolio_id, 
										cur_item.reason, 
										cur_item.period_start_date, 
										cur_item.period_end_date, 
										to_number(cur_item.amount, '999999999999999999999999999.999999999999999999999999999'), 
										cur_item.internal_identifier, 
										cur_item.date_time, 
										cur_item.codicetitolo_interno
								);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM tbl_scarti_tmp_pfcosti_gp tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCOSTI_GP. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCOSTI_GP. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;