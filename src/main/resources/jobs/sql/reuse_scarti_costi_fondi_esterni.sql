DECLARE

CURSOR del_cur IS
	SELECT /*+ parallel(8) */ scarto.ROWID AS scarto_rowid, 
			scarto.*, 
			tmp.ROWID AS tmp_rowid
	FROM TBL_SCARTI_TMP_PFCOSTI_AFB scarto
	LEFT JOIN TMP_PFCOSTI_AFB tmp
		ON( tmp.PERIOD_INITIAL_DATE = scarto.PERIOD_INITIAL_DATE
			AND tmp.PERIOD_FINAL_DATE = scarto.PERIOD_FINAL_DATE
			AND tmp.SOURCE_CONTRACT = scarto.SOURCE_CONTRACT
			AND tmp.ISIN = scarto.ISIN
			AND tmp.CONCEPT = scarto.CONCEPT)
	WHERE scarto.riproponibile = 'S';

I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN

	FOR cur_item IN del_cur 

		LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
		INSERT /*+ append nologging parallel(8) */
				INTO TMP_PFCOSTI_AFB (	DISTRIBUTOR_CODE,
										SUB_DIST_CODE,
										RECORD_TYPE,
										ACTION, 
										PERIOD_INITIAL_DATE, 
										PERIOD_FINAL_DATE,
										SOURCE_CONTRACT,
										ISIN,
										RESERVED1,
										RESERVED2,
										RESERVED3,
										CONCEPT,
										SIGN_AMT,
										AMOUNT,
										CURRENCY,
										PERCENTAGE,
										SIGN_AMT_CLI,
										AMOUNT_CURRENCY,
										CURRENCY_CLIENT,
										INFORMATION_FLAG
									)
								VALUES (cur_item.DISTRIBUTOR_CODE,
										cur_item.SUB_DIST_CODE,
										cur_item.RECORD_TYPE,
										cur_item.ACTION, 
										cur_item.PERIOD_INITIAL_DATE, 
										cur_item.PERIOD_FINAL_DATE,
										cur_item.SOURCE_CONTRACT,
										cur_item.ISIN,
										cur_item.RESERVED1,
										cur_item.RESERVED2,
										cur_item.RESERVED3,
										cur_item.CONCEPT,
										cur_item.SIGN_AMT,
										to_number(cur_item.AMOUNT, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.CURRENCY,
										cur_item.PERCENTAGE,
										cur_item.SIGN_AMT_CLI,
										cur_item.AMOUNT_CURRENCY,
										cur_item.CURRENCY_CLIENT,
										cur_item.INFORMATION_FLAG
								);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM TBL_SCARTI_TMP_PFCOSTI_AFB tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCOSTI_AFB. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCOSTI_AFB. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;