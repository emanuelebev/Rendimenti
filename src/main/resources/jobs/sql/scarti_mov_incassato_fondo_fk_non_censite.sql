DECLARE

CURSOR scarti_movimenti_multi IS 
	SELECT /*+ parallel(8) */	R.id AS idrapporto,
			p.codice_prodotto AS codicetitolo,
			r.codicetitolo_multiramo AS codicetitolo_multiramo,
			p.ROWID,
      		p.*
	FROM TMP_PFMOV_INC_FONDO p
		LEFT JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	WHERE EXISTS (	SELECT 1 
					FROM tbl_bridge b 
					WHERE b.cod_universo = P.codice_fondo);

	
CURSOR scarti_movimenti_altro IS
	SELECT /*+ parallel(8) */ DISTINCT R.id AS idrapporto,
			SF.codicetitolo AS codicetitolo,
			p.ROWID,
      		p.*
	FROM TMP_PFMOV_INC_FONDO P
		LEFT JOIN ( SELECT X.* 
					FROM tbl_bridge X 
					INNER JOIN strumentofinanziario y 
						ON X.codicetitolo = y.codicetitolo) b
			ON b.cod_universo = P.codice_fondo
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = P.codice_fondo
		LEFT JOIN rapporto R
			ON R.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND R.tipo = '13'
	WHERE (b.codicetitolo IS NULL and sf.codicetitolo IS NULL)
	OR r.id IS NULL;	

I                     	NUMBER(38, 0) := 0;
SCARTI_IDRAPPORTO		NUMBER := 0;
SCARTI_CODICETITOLO	 	NUMBER := 0;
SCARTI_CODICETITOLO_M 	NUMBER := 0;

  
BEGIN
    
 	FOR CUR_ITEM IN scarti_movimenti_multi

  LOOP
  
	I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_FONDO (	id_titolo,
													ramo,
													codice_prodotto,
													numero_polizza,
													tipo_titolo,
													data_effetto_titolo,
													codice_motivo_storno,
													data_carico,
													codice_fondo,
													isin,
													quote,
													nav,
													importo,
													data_nav,
													costo_etf,
													tmstp, 							
													motivo_scarto, 				 
													riproponibile
												)
										VALUES (	cur_item.id_titolo,
													cur_item.ramo,
													cur_item.codice_prodotto,
													cur_item.numero_polizza,
													cur_item.tipo_titolo,
													cur_item.data_effetto_titolo,
													cur_item.codice_motivo_storno,
													cur_item.data_carico,
													cur_item.codice_fondo,
													cur_item.isin,
													cur_item.quote,
													cur_item.nav,
													cur_item.importo,
													cur_item.data_nav,
													cur_item.costo_etf,
													SYSDATE,
													'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
													'S'
												);
	
		SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_INC_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.CODICETITOLO IS NULL) THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_FONDO (	id_titolo,
													ramo,
													codice_prodotto,
													numero_polizza,
													tipo_titolo,
													data_effetto_titolo,
													codice_motivo_storno,
													data_carico,
													codice_fondo,
													isin,
													quote,
													nav,
													importo,
													data_nav,
													costo_etf,
													tmstp, 							
													motivo_scarto, 				 
													riproponibile
												)
										VALUES (	cur_item.id_titolo,
													cur_item.ramo,
													cur_item.codice_prodotto,
													cur_item.numero_polizza,
													cur_item.tipo_titolo,
													cur_item.data_effetto_titolo,
													cur_item.codice_motivo_storno,
													cur_item.data_carico,
													cur_item.codice_fondo,
													cur_item.isin,
													cur_item.quote,
													cur_item.nav,
													cur_item.importo,
													cur_item.data_nav,
													cur_item.costo_etf,
													SYSDATE,
													'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
													'S'
												);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
      DELETE FROM TMP_PFMOV_INC_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
    ELSIF (CUR_ITEM.IDRAPPORTO IS NOT NULL AND CUR_ITEM.CODICETITOLO_MULTIRAMO IS NULL) THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_FONDO (	id_titolo,
													ramo,
													codice_prodotto,
													numero_polizza,
													tipo_titolo,
													data_effetto_titolo,
													codice_motivo_storno,
													data_carico,
													codice_fondo,
													isin,
													quote,
													nav,
													importo,
													data_nav,
													costo_etf,
													tmstp, 							
													motivo_scarto, 				 
													riproponibile
												)
										VALUES (	cur_item.id_titolo,
													cur_item.ramo,
													cur_item.codice_prodotto,
													cur_item.numero_polizza,
													cur_item.tipo_titolo,
													cur_item.data_effetto_titolo,
													cur_item.codice_motivo_storno,
													cur_item.data_carico,
													cur_item.codice_fondo,
													cur_item.isin,
													cur_item.quote,
													cur_item.nav,
													cur_item.importo,
													cur_item.data_nav,
													cur_item.costo_etf,
													SYSDATE,
													'CHIAVE ESTERNA "CODICETITOLO_MULTIRAMO" NON CENSITA',
													'S'
												);
								
	SCARTI_CODICETITOLO_M := SCARTI_CODICETITOLO_M + 1;
	
      DELETE FROM TMP_PFMOV_INC_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	  
      
      
	END IF;

		
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO MULTI PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO FK NON CENSITA (CODICETITOLO_MULTIRAMO): ' || SCARTI_CODICETITOLO_M);
  
  
  I := 0;
  
  FOR CUR_ITEM IN scarti_movimenti_altro

  LOOP

    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_FONDO (	id_titolo,
													ramo,
													codice_prodotto,
													numero_polizza,
													tipo_titolo,
													data_effetto_titolo,
													codice_motivo_storno,
													data_carico,
													codice_fondo,
													isin,
													quote,
													nav,
													importo,
													data_nav,
													costo_etf,
													tmstp, 							
													motivo_scarto, 				 
													riproponibile
												)
										VALUES (	cur_item.id_titolo,
													cur_item.ramo,
													cur_item.codice_prodotto,
													cur_item.numero_polizza,
													cur_item.tipo_titolo,
													cur_item.data_effetto_titolo,
													cur_item.codice_motivo_storno,
													cur_item.data_carico,
													cur_item.codice_fondo,
													cur_item.isin,
													cur_item.quote,
													cur_item.nav,
													cur_item.importo,
													cur_item.data_nav,
													cur_item.costo_etf,
													SYSDATE,
													'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
													'S'
												);
	
		SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_INC_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_FONDO (	id_titolo,
													ramo,
													codice_prodotto,
													numero_polizza,
													tipo_titolo,
													data_effetto_titolo,
													codice_motivo_storno,
													data_carico,
													codice_fondo,
													isin,
													quote,
													nav,
													importo,
													data_nav,
													costo_etf,
													tmstp, 							
													motivo_scarto, 				 
													riproponibile
												)
										VALUES (	cur_item.id_titolo,
													cur_item.ramo,
													cur_item.codice_prodotto,
													cur_item.numero_polizza,
													cur_item.tipo_titolo,
													cur_item.data_effetto_titolo,
													cur_item.codice_motivo_storno,
													cur_item.data_carico,
													cur_item.codice_fondo,
													cur_item.isin,
													cur_item.quote,
													cur_item.nav,
													cur_item.importo,
													cur_item.data_nav,
													cur_item.costo_etf,
													SYSDATE,
													'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
													'S'
												);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
      DELETE FROM TMP_PFMOV_INC_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_FONDO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  
  COMMIT;
  
  
  INSERT INTO CAUSALE (	  CODICECAUSALE,
                          CAUCONTR,
                          DATAAGGIORNAMENTO,
                          DATAINSERIMENTO,
                          DESCRIZIONE,
                          FLAGAGGSALDI,
                          SEGNO,
                          TIPOCAUSALE,
                          SOTL,
                          CODICEBANCA,
                          CANALE,
                          TIPOLOGIA_CAUSALE,
                          CODICECAUSALE_ORI)
               SELECT DISTINCT
               	 '13_' || t.tipo_titolo, --CODICECAUSALE
                 NULL,  --CAUCONTR
                 NULL, --DATAAGGIORNAMENTO
                 TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')), --DATAINSERIMENTO
                 t.tipo_titolo, --DESCRIZIONE
                 '1', --FLAGAGGSALDI
                 NULL, --SEGNO
                 '4', --TIPOCAUSALE
                 null, --SOTL
                 '07601', --CODICEBANCA
	         	 '13', --CANALE
                 'VER',
                 t.tipo_titolo --CODICECAUSALE_ORI
               FROM TMP_PFMOV_INC_FONDO t
               	INNER JOIN TBL_BRIDGE CC
					ON t.codice_fondo = CC.cod_universo
				INNER JOIN RAPPORTO R
					ON 0 || numero_polizza = R.codicerapporto
					AND R.tipo = '13'
               WHERE NOT EXISTS
		               (SELECT 1
		                FROM CAUSALE c
		                WHERE c.CODICECAUSALE = r.tipo || '_' || t.tipo_titolo);
  
  COMMIT;
END;