DECLARE

CURSOR scarti_costi_prod IS
	SELECT /*+ parallel(8) */
			rapp.id 			AS idrapporto,
			tc.codice 			AS codice,
			sf.codicetitolo 	AS codicetitolo,
			tmp.ROWID,
	      	tmp.*
	FROM tmp_costi_prodotto tmp
	LEFT JOIN rapporto rapp 
        ON rapp.codicebanca = tmp.codicebanca 
            --AND rapp.codiceagenzia = tmp.codiceagenzia
            AND rapp.codicerapporto = tmp.codicerapporto
            AND rapp.tipo = tmp.tiporapporto
	LEFT JOIN tipo_costo tc
		ON tmp.codicebanca = tc.codice_banca
			AND tmp.codicecosto = tc.codice
	LEFT JOIN strumentofinanziario sf
		ON substr(tmp.codiceinterno,2) = sf.codicetitolo
	WHERE (rapp.id IS NULL OR tc.codice IS NULL OR sf.codicetitolo IS NULL);

I                     	NUMBER(38, 0) := 0;
scarti_idrapporto		NUMBER		  := 0;
scarti_tipo_costo		NUMBER 		  := 0;
scarti_codicetitolo		NUMBER 		  := 0;


BEGIN

	FOR cur_item IN scarti_costi_prod

  		LOOP

    I := I + 1;

    IF (cur_item.idrapporto IS NULL) THEN
      INSERT INTO TBL_SCARTI_TMP_COSTI_PRODOTTO(CODICEBANCA,
												CODICEAGENZIA,
												CODICERAPPORTO,
												TIPORAPPORTO,
												CODICEINTERNO,
												CODICECOSTO,
												DATADA,
												DATAA,
												IMPORTO,
												FONTE,
												DATAAGGIORNAMENTO,
												TMSTP,
												MOTIVO_SCARTO,
												RIPROPONIBILE) 
                       VALUES (	cur_item.CODICEBANCA,
								cur_item.CODICEAGENZIA,
								cur_item.CODICERAPPORTO,
								cur_item.TIPORAPPORTO,
								cur_item.CODICEINTERNO,
								cur_item.CODICECOSTO,
								cur_item.DATADA,
								cur_item.DATAA,
								cur_item.IMPORTO,
								cur_item.FONTE,
								cur_item.DATAAGGIORNAMENTO,
								sysdate,
								'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
								'S'
								);
	
	scarti_idrapporto := scarti_idrapporto + 1;	
	
      DELETE FROM TMP_COSTI_PRODOTTO del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
								
	ELSIF (cur_item.codice IS NULL)	THEN
	 INSERT INTO TBL_SCARTI_TMP_COSTI_PRODOTTO(CODICEBANCA,
												CODICEAGENZIA,
												CODICERAPPORTO,
												TIPORAPPORTO,
												CODICEINTERNO,
												CODICECOSTO,
												DATADA,
												DATAA,
												IMPORTO,
												FONTE,
												DATAAGGIORNAMENTO,
												TMSTP,
												MOTIVO_SCARTO,
												RIPROPONIBILE) 
                       VALUES (	cur_item.CODICEBANCA,
								cur_item.CODICEAGENZIA,
								cur_item.CODICERAPPORTO,
								cur_item.TIPORAPPORTO,
								cur_item.CODICEINTERNO,
								cur_item.CODICECOSTO,
								cur_item.DATADA,
								cur_item.DATAA,
								cur_item.IMPORTO,
								cur_item.FONTE,
								cur_item.DATAAGGIORNAMENTO,
								sysdate,
								'CHIAVE ESTERNA "CODICE_COSTO" NON CENSITA',
								'S'
								);
								
	scarti_tipo_costo := scarti_tipo_costo + 1;	
	
      DELETE FROM TMP_COSTI_PRODOTTO del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
	
   ELSIF (cur_item.codicetitolo IS NULL) THEN
	 INSERT INTO TBL_SCARTI_TMP_COSTI_PRODOTTO(CODICEBANCA,
												CODICEAGENZIA,
												CODICERAPPORTO,
												TIPORAPPORTO,
												CODICEINTERNO,
												CODICECOSTO,
												DATADA,
												DATAA,
												IMPORTO,
												FONTE,
												DATAAGGIORNAMENTO,
												TMSTP,
												MOTIVO_SCARTO,
												RIPROPONIBILE) 
                       VALUES (	cur_item.CODICEBANCA,
								cur_item.CODICEAGENZIA,
								cur_item.CODICERAPPORTO,
								cur_item.TIPORAPPORTO,
								cur_item.CODICEINTERNO,
								cur_item.CODICECOSTO,
								cur_item.DATADA,
								cur_item.DATAA,
								cur_item.IMPORTO,
								cur_item.FONTE,
								cur_item.DATAAGGIORNAMENTO,
								sysdate,
								'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
								'S'
								);
								
	scarti_codicetitolo := scarti_codicetitolo + 1;	
	
      DELETE FROM TMP_COSTI_PRODOTTO del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;      
      
	END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_COSTI_PRODOTTO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_COSTI_PRODOTTO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_COSTI_PRODOTTO FK NON CENSITA (IDRAPPORTO): ' || scarti_idrapporto);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_COSTI_PRODOTTO FK NON CENSITA (TIPO_COSTO): ' || scarti_tipo_costo);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_COSTI_PRODOTTO FK NON CENSITA (CODICETITOLO): ' || scarti_codicetitolo);
  
  COMMIT;
END;