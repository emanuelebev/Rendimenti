DECLARE

CURSOR scarti_costi_fondi_esterni IS
	SELECT /*+ parallel(8) */
			rapp.id 			AS idrapporto,
			tc.codice 			AS codice,
			sf.codicetitolo 	AS codicetitolo,
			tmp.ROWID,
	      	tmp.*
	FROM tmp_pfcosti_afb tmp
	LEFT JOIN rapporto rapp 
        ON rapp.codicebanca = '07601'
            AND rapp.codicerapporto = tmp.source_contract
            AND rapp.tipo = '97'
	LEFT JOIN tipo_costo tc
		ON tc.codice_banca = '07601'
			AND tmp.concept = tc.codice
	LEFT JOIN strumentofinanziario sf
		ON tmp.isin = sf.isin
	WHERE (rapp.id IS NULL OR tc.codice IS NULL OR sf.codicetitolo IS NULL);
	
CURSOR scarti_costi_fondi_esterni_action IS
	SELECT /*+ parallel(8) */
			tmp.ROWID,
	      	tmp.*
	FROM tmp_pfcosti_afb tmp
	WHERE (tmp.action = 'D');

I                     	NUMBER(38, 0) := 0;
scarti_idrapporto		NUMBER		  := 0;
scarti_tipo_costo		NUMBER 		  := 0;
scarti_codicetitolo		NUMBER 		  := 0;
scarti_action			NUMBER		  := 0;


BEGIN

	FOR cur_item IN scarti_costi_fondi_esterni

  		LOOP

    I := I + 1;

    IF (cur_item.idrapporto IS NULL) THEN
      INSERT INTO TBL_SCARTI_TMP_PFCOSTI_AFB (DISTRIBUTOR_CODE,
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
														INFORMATION_FLAG,
														TMSTP, 							
														MOTIVO_SCARTO, 				 
														RIPROPONIBILE
													)
											VALUES (	cur_item.DISTRIBUTOR_CODE,
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
														cur_item.AMOUNT,
														cur_item.CURRENCY,
														cur_item.PERCENTAGE,
														cur_item.SIGN_AMT_CLI,
														cur_item.AMOUNT_CURRENCY,
														cur_item.CURRENCY_CLIENT,
														cur_item.INFORMATION_FLAG,
														SYSDATE,
														'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
														'S'
													);
	
	scarti_idrapporto := scarti_idrapporto + 1;	
	
      DELETE FROM TMP_PFCOSTI_AFB del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
								
	ELSIF (cur_item.codice IS NULL)	THEN
	 INSERT INTO TBL_SCARTI_TMP_PFCOSTI_AFB (DISTRIBUTOR_CODE,
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
														INFORMATION_FLAG,
														TMSTP, 							
														MOTIVO_SCARTO, 				 
														RIPROPONIBILE
													)
											VALUES (	cur_item.DISTRIBUTOR_CODE,
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
														cur_item.AMOUNT,
														cur_item.CURRENCY,
														cur_item.PERCENTAGE,
														cur_item.SIGN_AMT_CLI,
														cur_item.AMOUNT_CURRENCY,
														cur_item.CURRENCY_CLIENT,
														cur_item.INFORMATION_FLAG,
														SYSDATE,
														'CHIAVE ESTERNA "CODICE_COSTO" NON CENSITA',
														'S'
													);
								
	scarti_tipo_costo := scarti_tipo_costo + 1;	
	
      DELETE FROM TMP_PFCOSTI_AFB del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
	
   ELSIF (cur_item.codicetitolo IS NULL) THEN
	 INSERT INTO TBL_SCARTI_TMP_PFCOSTI_AFB (DISTRIBUTOR_CODE,
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
														INFORMATION_FLAG,
														TMSTP, 							
														MOTIVO_SCARTO, 				 
														RIPROPONIBILE
													)
											VALUES (	cur_item.DISTRIBUTOR_CODE,
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
														cur_item.AMOUNT,
														cur_item.CURRENCY,
														cur_item.PERCENTAGE,
														cur_item.SIGN_AMT_CLI,
														cur_item.AMOUNT_CURRENCY,
														cur_item.CURRENCY_CLIENT,
														cur_item.INFORMATION_FLAG,
														SYSDATE,
														'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
														'S'
													);
								
	scarti_codicetitolo := scarti_codicetitolo + 1;	
	
      DELETE FROM TMP_PFCOSTI_AFB del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;      
      
	END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB FK NON CENSITA (IDRAPPORTO): ' || scarti_idrapporto);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB FK NON CENSITA (TIPO_COSTO): ' || scarti_tipo_costo);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB FK NON CENSITA (CODICETITOLO): ' || scarti_codicetitolo);
  
  I := 0;
  
  FOR cur_item IN scarti_costi_fondi_esterni_action

  		LOOP

    I := I + 1;

      INSERT INTO TBL_SCARTI_TMP_PFCOSTI_AFB (DISTRIBUTOR_CODE,
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
														INFORMATION_FLAG,
														TMSTP, 							
														MOTIVO_SCARTO, 				 
														RIPROPONIBILE
													)
											VALUES (	cur_item.DISTRIBUTOR_CODE,
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
														cur_item.AMOUNT,
														cur_item.CURRENCY,
														cur_item.PERCENTAGE,
														cur_item.SIGN_AMT_CLI,
														cur_item.AMOUNT_CURRENCY,
														cur_item.CURRENCY_CLIENT,
														cur_item.INFORMATION_FLAG,
														SYSDATE,
														'CAMPO "ACTION=D" NON GESTITO',
														'N'
													);
	
	DELETE /*+ nologging */ FROM TMP_PFCOSTI_AFB DEL_TMP_COS
      WHERE DEL_TMP_COS.ROWID = CUR_ITEM.ROWID;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB PER CAMPO "ACTION=D" NON GESTITO - COMMIT ON ROW: '|| I);
      COMMIT;
    END IF;

  END LOOP;
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_AFB PER CAMPO "ACTION=D" NON GESTITO - COMMIT ON ROW: '|| I);
  COMMIT;
END;