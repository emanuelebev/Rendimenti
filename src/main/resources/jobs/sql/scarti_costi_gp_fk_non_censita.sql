DECLARE

CURSOR scarti_costi_gp IS
    SELECT /*+ parallel(8) */ 
    	tp.codice            AS tp_codice,
    	ndg.codicefiscale 	 AS ndg_codicefiscale,
        tmp.ROWID,
        tmp.*
    FROM TMP_PFCOSTI_GP tmp
    	LEFT JOIN tipo_costo tp
    		ON tp.codice = tmp.reason
    	LEFT JOIN ndg ndg
    		ON ndg.codicefiscale = tmp.identifier_value	
	WHERE (tp.codice IS NULL OR ndg.codicefiscale IS NULL);
	
CURSOR scarti_costi_gp_porfolio_id IS
	SELECT /*+ parallel(8) */ 
        tmp.portfolio_id         AS tmp_portfolio_id,
        tmp.ROWID,
        tmp.*
    FROM TMP_PFCOSTI_GP tmp
        LEFT JOIN saldo_rend_sott_gp sgp
             ON tmp.portfolio_id = sgp.portafoglio_id    
        WHERE (sgp.portafoglio_id IS NULL);

I 						NUMBER(38,0) :=0;
scarti_codicecosto	 	NUMBER :=0;
scarti_codicefiscale 	NUMBER :=0;
scarti_portfolio_id		NUMBER :=0;

BEGIN

FOR cur_item IN scarti_costi_gp
    LOOP
        I := I+1;

	IF (cur_item.tp_codice IS NULL) THEN
	
	INSERT INTO tbl_scarti_tmp_pfcosti_gp (	abi_code, 
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
											codicetitolo_interno,
											tmstp,
											riproponibile,
											motivo_scarto             											             
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
											cur_item.amount, 
											cur_item.internal_identifier, 
											cur_item.date_time, 
											cur_item.codicetitolo_interno,
								            sysdate,
								            'S',
								            'CHIAVE ESTERNA "CODICECOSTO" NON CENSITA'
								       	 	);

	DELETE  /*+ nologging */ FROM TMP_PFCOSTI_GP tmp_del 
	WHERE tmp_del.ROWID = cur_item.ROWID;
	
	scarti_codicecosto := scarti_codicecosto +1;
	
	IF MOD(I,10000) = 0 THEN
	    INSERT INTO output_print_table VALUES( to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||' SCARTI TMP_PFCOSTI_GP PER CHIAVE ESTERNA (CODICECOSTO) NON CENSITA - COMMIT ON ROW: ' || scarti_codicecosto);
		COMMIT;
	END IF;
	
	ELSE
	
	INSERT INTO tbl_scarti_tmp_pfcosti_gp (	abi_code, 
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
											codicetitolo_interno,
											tmstp,
											riproponibile,
											motivo_scarto             											             
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
											cur_item.amount, 
											cur_item.internal_identifier, 
											cur_item.date_time, 
											cur_item.codicetitolo_interno,
								            sysdate,
								            'S',
								            'CHIAVE ESTERNA "CODICEFISCALE" NON CENSITA'
								       	 	);

	DELETE  /*+ nologging */ FROM TMP_PFCOSTI_GP tmp_del 
	WHERE tmp_del.ROWID = cur_item.ROWID;
	
	scarti_codicefiscale := scarti_codicefiscale +1;
	
	IF MOD(I,10000) = 0 THEN
	    INSERT INTO output_print_table VALUES( to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||' SCARTI TMP_PFCOSTI_GP PER CHIAVE ESTERNA (CODICEFISCALE) NON CENSITA - COMMIT ON ROW: ' || scarti_codicefiscale);
		COMMIT;
	END IF;
	
	END IF;

END LOOP;

FOR cur_item IN scarti_costi_gp_porfolio_id
    LOOP
        I := I+1;
	
	INSERT INTO tbl_scarti_tmp_pfcosti_gp (	abi_code, 
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
											codicetitolo_interno,
											tmstp,
											riproponibile,
											motivo_scarto             											             
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
											cur_item.amount, 
											cur_item.internal_identifier, 
											cur_item.date_time, 
											cur_item.codicetitolo_interno,
								            sysdate,
								            'S',
								            'CHIAVE ESTERNA "PORTAFOGLIO_ID" NON CENSITA'
								       	 	);

	DELETE  /*+ nologging */ FROM TMP_PFCOSTI_GP tmp_del 
	WHERE tmp_del.ROWID = cur_item.ROWID;
	
	scarti_portfolio_id := scarti_portfolio_id +1;
	
	IF MOD(I,10000) = 0 THEN
	    INSERT INTO output_print_table VALUES( to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||' SCARTI TMP_PFCOSTI_GP PER CHIAVE ESTERNA (PORTAFOGLIO_ID) NON CENSITA - COMMIT ON ROW: ' || scarti_portfolio_id);
		COMMIT;
	END IF;
	
END LOOP;

INSERT INTO output_print_table VALUES( to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||' SCARTI TMP_PFCOSTI_GP PER CHIAVE ESTERNA NON CENSITA. RECORD ELABORATI: '|| I);
INSERT INTO output_print_table VALUES(to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_GP PER CHIAVE ESTERNA (CODICECOSTO) NON CENSITA. RECORD SCARTATI: ' || scarti_codicecosto);
INSERT INTO output_print_table VALUES(to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_GP PER CHIAVE ESTERNA (CODICEFISCALE) NON CENSITA. RECORD SCARTATI: ' || scarti_codicefiscale);
INSERT INTO output_print_table VALUES(to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_GP PER CHIAVE ESTERNA (PORTAFOGLIO_ID) NON CENSITA. RECORD SCARTATI: ' || scarti_portfolio_id);

COMMIT;
END;