DECLARE

-- SCARTI MOVIMENTI CODICE TITOLO NULL O RAPPORTO NULL
CURSOR scarti_movimenti_gp IS
    SELECT /*+ parallel(8) */ 
    	sf.codicetitolo AS sf_codicetitolo,
    	R.ID 			AS r_id,
        tmp.ROWID,
        tmp.*
    FROM tmp_pfmov_gp tmp
    	LEFT JOIN strumentofinanziario sf
    		ON sf.codicetitolo = tmp.codicetitolo_interno
    	LEFT JOIN rapporto R
    		ON R.codicerapporto = tmp.numero_deposito || tmp.numero_sottodeposito
	WHERE (sf.codicetitolo IS NULL OR R.ID IS NULL);
	
-- SCARTI MOVIMENTI CODICETITOLO NON PRESENTE IN TBL_BRIDGE_GP
CURSOR scarti_movimenti_gp_bridge IS
	SELECT /*+ parallel(8) */ 
        sf.codicetitolo AS sf_codicetitolo,
        R.ID            AS r_id,
        tmp.ROWID,
        tmp.*
    FROM tmp_pfmov_gp tmp
        LEFT JOIN strumentofinanziario sf
            ON sf.codicetitolo = tmp.codicetitolo_interno
        LEFT JOIN rapporto R
            ON R.codicerapporto = tmp.numero_deposito || tmp.numero_sottodeposito       
    WHERE sf.codicetitolo not in (select codice_linea from tbl_bridge_gp);

I                     	NUMBER(38, 0) := 0;
scarti_idrapporto		NUMBER := 0;
scarti_codicetitolo	 	NUMBER := 0;
scarti_bridge			NUMBER := 0;
  
BEGIN

  FOR cur_item IN scarti_movimenti_gp

  LOOP

    I := I + 1;

    IF (cur_item.r_id IS NULL)
    THEN
      INSERT INTO tbl_scarti_tmp_pfmov_gp (	codice_transazione,
											data_settlement,
											data_transazione,
											numero_deposito,
											numero_sottodeposito,
											codicetitolo_interno,
											importo_transato,
											causale_movimento,
											quantita_ordinata,
											quantita_effettiva,
											segno,
											commissioni,
											divisa_trattazione,
											cambio,
											canale_ordine,
											ndg,
											codicefiscale,
											tmstp,
											motivo_scarto,
											riproponibile,
											id_prodotto,
											upfront_fee_lorda, 
											upfront_fee_netta, 	
											upfront_fee_retrocessioni
										) 
                       			VALUES (	cur_item.codice_transazione,
											cur_item.data_settlement,
											cur_item.data_transazione,
											cur_item.numero_deposito,
											cur_item.numero_sottodeposito,
											cur_item.codicetitolo_interno,
											cur_item.importo_transato,
											cur_item.causale_movimento,
											cur_item.quantita_ordinata,
											cur_item.quantita_effettiva,
											cur_item.segno,
											cur_item.commissioni,
											cur_item.divisa_trattazione,
											cur_item.cambio,
											cur_item.canale_ordine,
											cur_item.ndg,
											cur_item.codicefiscale,
											sysdate,
											'CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA',
											'S',
											cur_item.id_prodotto,
											cur_item.upfront_fee_lorda, 
											cur_item.upfront_fee_netta, 	
											cur_item.upfront_fee_retrocessioni
											);
	
		scarti_idrapporto := scarti_idrapporto + 1;	
	
      DELETE FROM tmp_pfmov_gp del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
								
	ELSIF (cur_item.sf_codicetitolo IS NULL) THEN
	
      INSERT INTO tbl_scarti_tmp_pfmov_gp (	codice_transazione,
											data_settlement,
											data_transazione,
											numero_deposito,
											numero_sottodeposito,
											codicetitolo_interno,
											importo_transato,
											causale_movimento,
											quantita_ordinata,
											quantita_effettiva,
											segno,
											commissioni,
											divisa_trattazione,
											cambio,
											canale_ordine,
											ndg,
											codicefiscale,
											tmstp,
											motivo_scarto,
											riproponibile,
											id_prodotto,
											upfront_fee_lorda, 
											upfront_fee_netta, 	
											upfront_fee_retrocessioni
										) 
                       			VALUES (	cur_item.codice_transazione,
											cur_item.data_settlement,
											cur_item.data_transazione,
											cur_item.numero_deposito,
											cur_item.numero_sottodeposito,
											cur_item.codicetitolo_interno,
											cur_item.importo_transato,
											cur_item.causale_movimento,
											cur_item.quantita_ordinata,
											cur_item.quantita_effettiva,
											cur_item.segno,
											cur_item.commissioni,
											cur_item.divisa_trattazione,
											cur_item.cambio,
											cur_item.canale_ordine,
											cur_item.ndg,
											cur_item.codicefiscale,
											sysdate,
											'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
											'S',
											cur_item.id_prodotto,
											cur_item.upfront_fee_lorda, 
											cur_item.upfront_fee_netta, 	
											cur_item.upfront_fee_retrocessioni
											);
								
	scarti_codicetitolo := scarti_codicetitolo + 1;
	
      DELETE FROM tmp_pfmov_gp del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
	
	END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  FOR cur_item IN scarti_movimenti_gp_bridge

  LOOP

    I := I + 1;

      INSERT INTO tbl_scarti_tmp_pfmov_gp (	codice_transazione,
											data_settlement,
											data_transazione,
											numero_deposito,
											numero_sottodeposito,
											codicetitolo_interno,
											importo_transato,
											causale_movimento,
											quantita_ordinata,
											quantita_effettiva,
											segno,
											commissioni,
											divisa_trattazione,
											cambio,
											canale_ordine,
											ndg,
											codicefiscale,
											tmstp,
											motivo_scarto,
											riproponibile,
											id_prodotto,
											upfront_fee_lorda, 
											upfront_fee_netta, 	
											upfront_fee_retrocessioni
										) 
                       			VALUES (	cur_item.codice_transazione,
											cur_item.data_settlement,
											cur_item.data_transazione,
											cur_item.numero_deposito,
											cur_item.numero_sottodeposito,
											cur_item.codicetitolo_interno,
											cur_item.importo_transato,
											cur_item.causale_movimento,
											cur_item.quantita_ordinata,
											cur_item.quantita_effettiva,
											cur_item.segno,
											cur_item.commissioni,
											cur_item.divisa_trattazione,
											cur_item.cambio,
											cur_item.canale_ordine,
											cur_item.ndg,
											cur_item.codicefiscale,
											sysdate,
											'CHIAVE ESTERNA "CODICELINEA" NON PRESENTE NELLA TBL_BRIDGE',
											'S',
											cur_item.id_prodotto,
											cur_item.upfront_fee_lorda, 
											cur_item.upfront_fee_netta, 	
											cur_item.upfront_fee_retrocessioni
											);
	
		scarti_bridge := scarti_bridge + 1;	
	
      DELETE FROM tmp_pfmov_gp del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;

	IF MOD(I, 10000) = 0
    	THEN
     		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP PER CHIAVE ESTERNA CODICELINEA NON PRESENTE NELLA TBL_BRIDGE - COMMIT ON ROW: ' || I);
      	COMMIT;
   	END IF;
   	
  END LOOP;
  
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP FK NON CENSITA (CODICERAPPORTO): ' || scarti_idrapporto);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP FK NON CENSITA (CODICETITOLO): ' || scarti_codicetitolo);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_GP FK NON CENSITA (CODICELINEA): ' || scarti_bridge);

  
  COMMIT;
  
  INSERT INTO causale (	  codicecausale,
                          caucontr,
                          dataaggiornamento,
                          datainserimento,
                          descrizione,
                          flagaggsaldi,
                          segno,
                          tipocausale,
                          sotl,
                          codicebanca,
                          canale,
                          tipologia_causale,
                          codicecausale_ori,
                          procedura)
               SELECT DISTINCT
	               	'GP_' || T.causale_movimento, --CODICECAUSALE
	                 NULL,  --CAUCONTR
	                 NULL, --DATAAGGIORNAMENTO
	                 to_number(to_char(sysdate, 'YYYYMMDD')), --DATAINSERIMENTO
	                 CASE WHEN T.causale_movimento = 'SOTT' then 'Sottoscrizione'
	                      WHEN T.causale_movimento = 'RIMB' then 'Rimborso'
	                  END, --DESCRIZIONE
	                 '1', --FLAGAGGSALDI
	                 NULL, --SEGNO
	                 '4', --TIPOCAUSALE
	                 NULL, --SOTL
	                 '07601', --CODICEBANCA
		         	 '15', --CANALE
	                 CASE WHEN T.causale_movimento = 'SOTT' then 'VER'
	                      WHEN T.causale_movimento = 'RIMB' then 'PREL'
	                  END, --TIPOLOGIA_CAUSALE
	                 T.causale_movimento, --CODICECAUSALE_ORI
	                 'GP' --PROCEDURA
	               FROM tmp_pfmov_gp T
	               WHERE NOT EXISTS
			               (SELECT 1
			                FROM causale C
			                WHERE C.codicecausale = 'GP_' || T.causale_movimento);
  
  COMMIT;
END;