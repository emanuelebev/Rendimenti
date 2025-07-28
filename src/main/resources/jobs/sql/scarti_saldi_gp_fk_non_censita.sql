DECLARE

-- SCARTI MOVIMENTI CON CODICETITOLO O ID RAPPORTO NULL
CURSOR scarti_saldi_gp IS
    SELECT /*+ parallel(8) */ 
    	sf.codicetitolo AS sf_codicetitolo,
    	R.ID 			AS r_id,
        tmp.ROWID,
        tmp.*
    FROM tmp_pfsaldi_gp tmp
    	LEFT JOIN strumentofinanziario sf
    		ON sf.codicetitolo = tmp.codicetitolo_interno
    	LEFT JOIN rapporto R
    		ON R.codicerapporto = tmp.numero_deposito || tmp.numero_sottodeposito
	WHERE (sf.codicetitolo IS NULL OR R.ID IS NULL);

-- SCARTI SALDI NON PRESENTI IN TBL_BRIDGE_GP
CURSOR scarti_saldi_gp_bridge IS
	SELECT /*+ parallel(8) */ 
        sf.codicetitolo AS sf_codicetitolo,
        R.ID            AS r_id,
        tmp.ROWID,
        tmp.*
    FROM tmp_pfsaldi_gp tmp
        LEFT JOIN strumentofinanziario sf
            ON sf.codicetitolo = tmp.codicetitolo_interno
        LEFT JOIN rapporto R
            ON R.codicerapporto = tmp.numero_deposito || tmp.numero_sottodeposito   
    WHERE sf.codicetitolo not in (select codice_linea from tbl_bridge_gp);
    
I 						NUMBER(38,0) :=0;
scarti_codicetitolo 	NUMBER :=0;
scarti_codicerapporto 	NUMBER :=0;
scarti_bridge_gp		NUMBER :=0;


BEGIN

FOR cur_item IN scarti_saldi_gp
    LOOP
        I := I+1;

	IF (cur_item.sf_codicetitolo IS NULL) THEN
	
	INSERT INTO tbl_scarti_tmp_pfsaldi_gp (	numero_deposito,
											numero_sottodeposito,
											codicetitolo_interno,
											importo_concordato,
											data_saldo,
											quantita,
											ctv_carico,
											ctv_mercato,
											portafoglio_id,
											tmstp,
											riproponibile,
											motivo_scarto             											             
										)
									VALUES (cur_item.numero_deposito,
											cur_item.numero_sottodeposito,
											cur_item.codicetitolo_interno,
											cur_item.importo_concordato,
											cur_item.data_saldo,
											cur_item.quantita,
											cur_item.ctv_carico,
											cur_item.ctv_mercato,
											cur_item.portafoglio_id,
								            sysdate,
								            'S',
								            'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA'
								       	 	);

	DELETE  /*+ nologging */ FROM tmp_pfsaldi_gp tmp_del 
	WHERE tmp_del.ROWID = cur_item.ROWID;
	
	scarti_codicetitolo := scarti_codicetitolo +1;
	
	IF MOD(I,10000) = 0 THEN
	    INSERT INTO output_print_table VALUES( to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||' SCARTI TMP_PFSALDI_GP PER CHIAVE ESTERNA (CODICETITOLO) NON CENSITA - COMMIT ON ROW: ' || scarti_codicetitolo);
		COMMIT;
	END IF;
	
	
	ELSE
	
	INSERT INTO tbl_scarti_tmp_pfsaldi_gp (	numero_deposito,
											numero_sottodeposito,
											codicetitolo_interno,
											importo_concordato,
											data_saldo,
											quantita,
											ctv_carico,
											ctv_mercato,
											portafoglio_id,
											tmstp,
											riproponibile,
											motivo_scarto             											             
										)
									VALUES (cur_item.numero_deposito,
											cur_item.numero_sottodeposito,
											cur_item.codicetitolo_interno,
											cur_item.importo_concordato,
											cur_item.data_saldo,
											cur_item.quantita,
											cur_item.ctv_carico,
											cur_item.ctv_mercato,
											cur_item.portafoglio_id,
								            sysdate,
								            'S',
								            'CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA'
								       	 	);

	DELETE  /*+ nologging */ FROM tmp_pfsaldi_gp tmp_del 
	WHERE tmp_del.ROWID = cur_item.ROWID;
	
	scarti_codicerapporto := scarti_codicerapporto +1;

	IF MOD(I,10000) = 0 THEN
	    INSERT INTO output_print_table VALUES( to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||' SCARTI TMP_PFSALDI_GP PER CHIAVE ESTERNA (CODICERAPPORTO) NON CENSITA - COMMIT ON ROW: ' || scarti_codicerapporto);
		COMMIT;
	END IF;
	
	END IF;
	
	END LOOP;
	
FOR cur_item IN scarti_saldi_gp_bridge
    LOOP
        I := I+1;
	
	INSERT INTO tbl_scarti_tmp_pfsaldi_gp (	numero_deposito,
											numero_sottodeposito,
											codicetitolo_interno,
											importo_concordato,
											data_saldo,
											quantita,
											ctv_carico,
											ctv_mercato,
											portafoglio_id,
											tmstp,
											riproponibile,
											motivo_scarto             											             
										)
									VALUES (cur_item.numero_deposito,
											cur_item.numero_sottodeposito,
											cur_item.codicetitolo_interno,
											cur_item.importo_concordato,
											cur_item.data_saldo,
											cur_item.quantita,
											cur_item.ctv_carico,
											cur_item.ctv_mercato,
											cur_item.portafoglio_id,
								            sysdate,
								            'S',
								            'CHIAVE ESTERNA "CODICELINEA" NON PRESENTE NELLA TBL_BRIDGE'
								       	 	);

	DELETE  /*+ nologging */ FROM tmp_pfsaldi_gp tmp_del 
	WHERE tmp_del.ROWID = cur_item.ROWID;
	
	scarti_bridge_gp := scarti_bridge_gp +1;
	
	IF MOD(I,10000) = 0 THEN
	    INSERT INTO output_print_table VALUES( to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||' SCARTI TMP_PFSALDI_GP PER CHIAVE ESTERNA (CODICETITOLO) NON CENSITA - COMMIT ON ROW: ' || scarti_bridge_gp);
		COMMIT;
	END IF;
	
	END LOOP;
	

	INSERT INTO output_print_table VALUES(to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_GP PER CHIAVE ESTERNA (CODICETITOLO) NON CENSITA. RECORD SCARTATI: ' || scarti_codicetitolo);
	INSERT INTO output_print_table VALUES(to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_GP PER CHIAVE ESTERNA (CODICERAPPORTO) NON CENSITA. RECORD SCARTATI: ' || scarti_codicerapporto);
	INSERT INTO output_print_table VALUES(to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||	' SCARTI TMP_PFSALDI_GP PER CHIAVE ESTERNA (CODICELINEA) NON PRESENTE NELLA TBL_BRIDGE. RECORD SCARTATI: '|| scarti_bridge_gp);
	INSERT INTO output_print_table VALUES(to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) ||	' SCARTI TMP_PFSALDI_GP PER CHIAVE ESTERNA (CODICETITOLO) NON CENSITA. RECORD ELABORATI: '|| I);

	COMMIT;

END;