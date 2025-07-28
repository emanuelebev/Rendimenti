DECLARE

CURSOR scarti_movimenti_multi IS		
	SELECT /*+ parallel(8) */	R.id as idrapporto,
			p.codice_prodotto as codicetitolo,
			r.codicetitolo_multiramo as codicetitolo_multiramo,
			p.ROWID,
      		p.*	
	FROM TMP_PFMOV_PAG_FONDO P
		LEFT JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	WHERE EXISTS (	SELECT 1 
					FROM tbl_bridge b 
					WHERE b.cod_universo = P.codice_fondo);

	
	
--Movimenti polizze altro
CURSOR scarti_movimenti_altro IS
	SELECT /*+ parallel(8) */ DISTINCT R.id as idrapporto,
				SF.codicetitolo as codicetitolo,
				p.ROWID,
	      		p.*
	FROM TMP_PFMOV_PAG_FONDO P
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
	WHERE (b.codicetitolo IS NULL AND sf.codicetitolo IS NULL)
	OR r.id is null;
	
		
  I                     	NUMBER(38, 0) := 0;
  SCARTI_IDRAPPORTO		 	NUMBER := 0;
  SCARTI_CODICETITOLO	 	NUMBER := 0;
  SCARTI_CODICETITOLO_M	 	NUMBER := 0;
  
  
  
BEGIN
 
  FOR CUR_ITEM IN scarti_movimenti_multi

  LOOP

    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_FONDO (	ramo,
													codice_prodotto,
													numero_polizza,
													data_comunicazione_pagamento,
													cf_beneficiario,
													modalita_pagamento,
													codice_fondo,
													tipologia_liquidazione,
													isin,
													quote,
													nav,
													importo,
													data_nav,
													codice_attivita,
													provvigioni_intermediario,
													costo_etf,
													commissioni_di_gestione,
													numero_pratica,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	cur_item.ramo,
											cur_item.codice_prodotto,
											cur_item.numero_polizza,
											cur_item.data_comunicazione_pagamento,
											cur_item.cf_beneficiario,
											cur_item.modalita_pagamento,
											cur_item.codice_fondo,
											cur_item.tipologia_liquidazione,
											cur_item.isin,
											cur_item.quote,
											cur_item.nav,
											cur_item.importo,
											cur_item.data_nav,
											cur_item.codice_attivita,
											cur_item.provvigioni_intermediario,
											cur_item.costo_etf,
											cur_item.commissioni_di_gestione,
											cur_item.numero_pratica,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
										);
	
	SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.CODICETITOLO IS NULL) THEN
		INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_FONDO (	ramo,
														codice_prodotto,
														numero_polizza,
														data_comunicazione_pagamento,
														cf_beneficiario,
														modalita_pagamento,
														codice_fondo,
														tipologia_liquidazione,
														isin,
														quote,
														nav,
														importo,
														data_nav,
														codice_attivita,
														provvigioni_intermediario,
														costo_etf,
														commissioni_di_gestione,
														numero_pratica,
														tmstp,
														motivo_scarto,
														riproponibile) 
	                       			VALUES (	cur_item.ramo,
												cur_item.codice_prodotto,
												cur_item.numero_polizza,
												cur_item.data_comunicazione_pagamento,
												cur_item.cf_beneficiario,
												cur_item.modalita_pagamento,
												cur_item.codice_fondo,
												cur_item.tipologia_liquidazione,
												cur_item.isin,
												cur_item.quote,
												cur_item.nav,
												cur_item.importo,
												cur_item.data_nav,
												cur_item.codice_attivita,
												cur_item.provvigioni_intermediario,
												cur_item.costo_etf,
												cur_item.commissioni_di_gestione,
												cur_item.numero_pratica,
												SYSDATE,
												'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
												'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
  DELETE FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
  ELSIF (CUR_ITEM.IDRAPPORTO IS NOT NULL AND CUR_ITEM.CODICETITOLO_MULTIRAMO IS NULL) THEN
			INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_FONDO (	ramo,
														codice_prodotto,
														numero_polizza,
														data_comunicazione_pagamento,
														cf_beneficiario,
														modalita_pagamento,
														codice_fondo,
														tipologia_liquidazione,
														isin,
														quote,
														nav,
														importo,
														data_nav,
														codice_attivita,
														provvigioni_intermediario,
														costo_etf,
														commissioni_di_gestione,
														numero_pratica,
														tmstp,
														motivo_scarto,
														riproponibile) 
	                       			VALUES (	cur_item.ramo,
												cur_item.codice_prodotto,
												cur_item.numero_polizza,
												cur_item.data_comunicazione_pagamento,
												cur_item.cf_beneficiario,
												cur_item.modalita_pagamento,
												cur_item.codice_fondo,
												cur_item.tipologia_liquidazione,
												cur_item.isin,
												cur_item.quote,
												cur_item.nav,
												cur_item.importo,
												cur_item.data_nav,
												cur_item.codice_attivita,
												cur_item.provvigioni_intermediario,
												cur_item.costo_etf,
												cur_item.commissioni_di_gestione,
												cur_item.numero_pratica,
												SYSDATE,
												'CHIAVE ESTERNA "CODICETITOLO_MULTIRAMO" NON CENSITA',
												'S'
											);
								
	SCARTI_CODICETITOLO_M := SCARTI_CODICETITOLO_M + 1;
	
  DELETE FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;	
 
	END IF;
	
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO FK NON CENSITA (CODICETITOLO_MULTIRAMO): ' || SCARTI_CODICETITOLO_M);
  
	I:= 0;
  
  FOR CUR_ITEM IN scarti_movimenti_altro

  LOOP
    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_FONDO (	ramo,
													codice_prodotto,
													numero_polizza,
													data_comunicazione_pagamento,
													cf_beneficiario,
													modalita_pagamento,
													codice_fondo,
													tipologia_liquidazione,
													isin,
													quote,
													nav,
													importo,
													data_nav,
													codice_attivita,
													provvigioni_intermediario,
													costo_etf,
													commissioni_di_gestione,
													numero_pratica,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	cur_item.ramo,
											cur_item.codice_prodotto,
											cur_item.numero_polizza,
											cur_item.data_comunicazione_pagamento,
											cur_item.cf_beneficiario,
											cur_item.modalita_pagamento,
											cur_item.codice_fondo,
											cur_item.tipologia_liquidazione,
											cur_item.isin,
											cur_item.quote,
											cur_item.nav,
											cur_item.importo,
											cur_item.data_nav,
											cur_item.codice_attivita,
											cur_item.provvigioni_intermediario,
											cur_item.costo_etf,
											cur_item.commissioni_di_gestione,
											cur_item.numero_pratica,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
										);
	
	SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
		INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_FONDO (	ramo,
														codice_prodotto,
														numero_polizza,
														data_comunicazione_pagamento,
														cf_beneficiario,
														modalita_pagamento,
														codice_fondo,
														tipologia_liquidazione,
														isin,
														quote,
														nav,
														importo,
														data_nav,
														codice_attivita,
														provvigioni_intermediario,
														costo_etf,
														commissioni_di_gestione,
														numero_pratica,
														tmstp,
														motivo_scarto,
														riproponibile) 
	                       			VALUES (	cur_item.ramo,
												cur_item.codice_prodotto,
												cur_item.numero_polizza,
												cur_item.data_comunicazione_pagamento,
												cur_item.cf_beneficiario,
												cur_item.modalita_pagamento,
												cur_item.codice_fondo,
												cur_item.tipologia_liquidazione,
												cur_item.isin,
												cur_item.quote,
												cur_item.nav,
												cur_item.importo,
												cur_item.data_nav,
												cur_item.codice_attivita,
												cur_item.provvigioni_intermediario,
												cur_item.costo_etf,
												cur_item.commissioni_di_gestione,
												cur_item.numero_pratica,
												SYSDATE,
												'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
												'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
  DELETE FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	END IF;
	
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
 
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
             	CASE WHEN codice_attivita IN ('PM', 'MF') THEN '13_' || codice_attivita
					ELSE '13_' || tipologia_liquidazione END, --CODICECAUSALE
                 NULL,  --CAUCONTR
                 NULL, --DATAAGGIORNAMENTO
                 TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')), --DATAINSERIMENTO
                CASE WHEN codice_attivita IN ('PM', 'MF') THEN '13_' || codice_attivita
				 ELSE '13_' || tipologia_liquidazione END, --DESCRIZIONE
                 '1', --FLAGAGGSALDI
                 NULL, --SEGNO
                 '4', --TIPOCAUSALE
                 null, --SOTL
                 '07601', --CODICEBANCA
	         	 '13', --CANALE
           		 'PREL',
	             CASE WHEN codice_attivita IN ('PM', 'MF') THEN codice_attivita
				ELSE tipologia_liquidazione END--CODICECAUSALE_ORI
               FROM TMP_PFMOV_PAG_FONDO t
               	INNER JOIN TBL_BRIDGE CC
					ON t.codice_fondo = CC.cod_universo
				INNER JOIN RAPPORTO R
					ON 0 || numero_polizza = R.codicerapporto
					AND R.tipo = '13'
               WHERE NOT EXISTS
		               (SELECT 1
		                FROM CAUSALE c
		                WHERE c.CODICECAUSALE =  CASE WHEN codice_attivita IN ('PM', 'MF') THEN '13_' || codice_attivita
					ELSE '13_' || tipologia_liquidazione END);
  
  COMMIT;
END;