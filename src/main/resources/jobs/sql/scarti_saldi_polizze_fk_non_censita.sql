DECLARE

--Saldi polizze monoramo
CURSOR SCARTI_SALDI_POLIZZE_MONO IS
	SELECT /*+ parallel(8) */ R.codicerapporto AS r_codicerapporto, sf.codicetitolo AS sf_codicetitolo, sp.ROWID, sp.* 
	FROM tmp_pfsaldi_polizze sp
		LEFT JOIN ( SELECT X.* 
					FROM tbl_bridge X 
					INNER JOIN strumentofinanziario y 
						ON X.codicetitolo = y.codicetitolo) b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		LEFT JOIN rapporto R
			ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
			AND R.tipo = '13'
		WHERE b.codicetitolo IS NULL
		AND sf.livello_2 = 'POLIZZE RAMO I' 
		AND sp.flagesclusione = '0'
		AND R.ID IS NULL;

	
--Saldi polizze multiramo
CURSOR SCARTI_SALDI_POLIZZE_MULTI IS
	SELECT /*+ parallel(8) */ R.codicerapporto AS r_codicerapporto, sf.codicetitolo AS sf_codicetitolo, sp.ROWID, sp.* 
	FROM tmp_pfsaldi_polizze sp
		LEFT JOIN ( SELECT X.* 
					FROM tbl_bridge X 
					INNER JOIN strumentofinanziario y 
						ON X.codicetitolo = y.codicetitolo) b
			ON b.cod_universo = sp.codiceinterno
			AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
				(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		LEFT JOIN rapporto R
			ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
				AND R.tipo = '13'
	WHERE sp.flagesclusione = '0'
	AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
	AND R.ID IS NULL;

	
--Saldi polizze tuttoilresto
CURSOR SCARTI_SALDI_POLIZZE_ALTRO IS
	SELECT  /*+ parallel(8) */ R.codicerapporto AS r_codicerapporto, CASE WHEN b.codicetitolo IS NOT NULL THEN b.codicetitolo
		ELSE sf.codicetitolo END AS sf_codicetitolo, sp.ROWID, sp.* 
	FROM tmp_pfsaldi_polizze sp
		LEFT JOIN ( SELECT X.* 
					FROM tbl_bridge X 
					INNER JOIN strumentofinanziario y 
						ON X.codicetitolo = y.codicetitolo) b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		LEFT JOIN rapporto R
			ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
			AND R.tipo = '13'
		WHERE ((b.codicetitolo IS NULL AND (sf.codicetitolo IS NULL OR (sf.livello_2 NOT IN  ('POLIZZE RAMO I', 'POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))))
			OR  R.ID IS NULL)
		AND sp.flagesclusione = '0';
	
I 							NUMBER(38,0):=0;	
SCARTI_CODICETITOLO 		NUMBER:=0;
SCARTI_CODICERAPPORTO 		NUMBER:=0;


BEGIN
		
	FOR CUR_ITEM IN SCARTI_SALDI_POLIZZE_MONO
		LOOP 
					
		I := I+1;
		
			IF (CUR_ITEM.SF_CODICETITOLO IS NULL) THEN			
				INSERT INTO 
					TBL_SCARTI_TMP_PFSALDI_POLIZZE (codicebanca,
													codiceagenzia,
													codicerapporto,
													codiceinterno,
													ramo,
													fondo,
													datasaldo,
													tiporapporto,
													controvalore,
													divisa,
													flagconsolidato,
													ctvversato,
													ctvprelevato,
													ctvversatonetto,
													dataaggiornamento,
													codiceinternomacroprodotto,
													descrizionemacroprodotto,
													valorenominale,
													datacompleannopolizza,
													idtitolo,
													flagesclusione,
													numero_quote,
											   		nav,
											    	cod_tipo_attivita,
													tmstp,
													motivo_scarto,
													riproponibile   
													)
									VALUES (cur_item.codicebanca,       
											cur_item.codiceagenzia,     
											cur_item.codicerapporto,    
											cur_item.codiceinterno,
											cur_item.ramo,
											cur_item.fondo,
											cur_item.datasaldo,
											cur_item.tiporapporto,
											cur_item.controvalore,
											cur_item.divisa,
											cur_item.flagconsolidato,
											cur_item.ctvversato,
											cur_item.ctvprelevato,
											cur_item.ctvversatonetto,
											cur_item.dataaggiornamento,
											cur_item.codiceinternomacroprodotto,
											cur_item.descrizionemacroprodotto,
											cur_item.valorenominale,
											cur_item.datacompleannopolizza,
											cur_item.idtitolo,
											cur_item.flagesclusione,
											cur_item.numero_quote,
											cur_item.nav,
											cur_item.cod_tipo_attivita,
											sysdate,             
											'MONORAMO - CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',     
											'S'
											);
										
					DELETE /*+ nologging */ FROM TMP_PFSALDI_POLIZZE TMP_DEL
					WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
					
					SCARTI_CODICETITOLO := SCARTI_CODICETITOLO +1;
				
				ELSIF (CUR_ITEM.R_CODICERAPPORTO IS NULL) THEN
					INSERT INTO 
						TBL_SCARTI_TMP_PFSALDI_POLIZZE (codicebanca,
														codiceagenzia,
														codicerapporto,
														codiceinterno,
														ramo,
														fondo,
														datasaldo,
														tiporapporto,
														controvalore,
														divisa,
														flagconsolidato,
														ctvversato,
														ctvprelevato,
														ctvversatonetto,
														dataaggiornamento,
														codiceinternomacroprodotto,
														descrizionemacroprodotto,
														valorenominale,
														datacompleannopolizza,
														idtitolo,
														flagesclusione,
														numero_quote,
											   			nav,
											    		cod_tipo_attivita,
														tmstp,
														motivo_scarto,
														riproponibile   
														)
										VALUES (cur_item.codicebanca,       
												cur_item.codiceagenzia,     
												cur_item.codicerapporto,    
												cur_item.codiceinterno,
												cur_item.ramo,
												cur_item.fondo,
												cur_item.datasaldo,
												cur_item.tiporapporto,
												cur_item.controvalore,
												cur_item.divisa,
												cur_item.flagconsolidato,
												cur_item.ctvversato,
												cur_item.ctvprelevato,
												cur_item.ctvversatonetto,
												cur_item.dataaggiornamento,
												cur_item.codiceinternomacroprodotto,
												cur_item.descrizionemacroprodotto,
												cur_item.valorenominale,
												cur_item.datacompleannopolizza,
												cur_item.idtitolo,
												cur_item.flagesclusione,
												cur_item.numero_quote,
											   	cur_item.nav,
											    cur_item.cod_tipo_attivita,
												sysdate, 
												'MONORAMO - CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA',     
												'S'
												);
													
							DELETE /*+ nologging */ FROM TMP_PFSALDI_POLIZZE TMP_DEL
							WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
							
							SCARTI_CODICERAPPORTO := SCARTI_CODICERAPPORTO +1;			
					END IF;
			
			IF MOD(I,10000) = 0 THEN
				INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MONO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: '|| I);
				COMMIT; 
			END IF;
					
		END LOOP;
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MONO PER CHIAVE ESTERNA NON CENSITA. RECORD ELABORATI: '|| I);
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MONO PER CODICETITOLO NON CENSITO. RECORD SCARTATI: '|| SCARTI_CODICETITOLO);
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MONO PER CODICERAPPORTO NON CENSITO. RECORD SCARTATI: '|| SCARTI_CODICERAPPORTO);
		COMMIT;
		
		I := 0;	
		
	FOR CUR_ITEM IN SCARTI_SALDI_POLIZZE_MULTI
		LOOP 
				
		I := I+1;
		
			IF (CUR_ITEM.SF_CODICETITOLO IS NULL) THEN			
				INSERT INTO 
					TBL_SCARTI_TMP_PFSALDI_POLIZZE (codicebanca,
													codiceagenzia,
													codicerapporto,
													codiceinterno,
													ramo,
													fondo,
													datasaldo,
													tiporapporto,
													controvalore,
													divisa,
													flagconsolidato,
													ctvversato,
													ctvprelevato,
													ctvversatonetto,
													dataaggiornamento,
													codiceinternomacroprodotto,
													descrizionemacroprodotto,
													valorenominale,
													datacompleannopolizza,
													idtitolo,
													flagesclusione,
													numero_quote,
										   			nav,
										    		cod_tipo_attivita,
													tmstp,
													motivo_scarto,
													riproponibile   
													)
									VALUES (cur_item.codicebanca,       
											cur_item.codiceagenzia,     
											cur_item.codicerapporto,    
											cur_item.codiceinterno,
											cur_item.ramo,
											cur_item.fondo,
											cur_item.datasaldo,
											cur_item.tiporapporto,
											cur_item.controvalore,
											cur_item.divisa,
											cur_item.flagconsolidato,
											cur_item.ctvversato,
											cur_item.ctvprelevato,
											cur_item.ctvversatonetto,
											cur_item.dataaggiornamento,
											cur_item.codiceinternomacroprodotto,
											cur_item.descrizionemacroprodotto,
											cur_item.valorenominale,
											cur_item.datacompleannopolizza,
											cur_item.idtitolo,
											cur_item.flagesclusione,
											cur_item.numero_quote,
											cur_item.nav,
											cur_item.cod_tipo_attivita,
											SYSDATE,             
											'MULTIRAMO - CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',     
											'S'
											);
										
					DELETE FROM TMP_PFSALDI_POLIZZE TMP_DEL
					WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
					
					SCARTI_CODICETITOLO := SCARTI_CODICETITOLO +1;
				
				ELSIF (CUR_ITEM.R_CODICERAPPORTO IS NULL) THEN
					INSERT INTO 
						TBL_SCARTI_TMP_PFSALDI_POLIZZE (codicebanca,
														codiceagenzia,
														codicerapporto,
														codiceinterno,
														ramo,
														fondo,
														datasaldo,
														tiporapporto,
														controvalore,
														divisa,
														flagconsolidato,
														ctvversato,
														ctvprelevato,
														ctvversatonetto,
														dataaggiornamento,
														codiceinternomacroprodotto,
														descrizionemacroprodotto,
														valorenominale,
														datacompleannopolizza,
														idtitolo,
														flagesclusione,
														numero_quote,
										   				nav,
										    			cod_tipo_attivita,
														tmstp,
														motivo_scarto,
														riproponibile   
														)
										VALUES (cur_item.codicebanca,       
												cur_item.codiceagenzia,     
												cur_item.codicerapporto,    
												cur_item.codiceinterno,
												cur_item.ramo,
												cur_item.fondo,
												cur_item.datasaldo,
												cur_item.tiporapporto,
												cur_item.controvalore,
												cur_item.divisa,
												cur_item.flagconsolidato,
												cur_item.ctvversato,
												cur_item.ctvprelevato,
												cur_item.ctvversatonetto,
												cur_item.dataaggiornamento,
												cur_item.codiceinternomacroprodotto,
												cur_item.descrizionemacroprodotto,
												cur_item.valorenominale,
												cur_item.datacompleannopolizza,
												cur_item.idtitolo,
												cur_item.flagesclusione,
												cur_item.numero_quote,
										   		cur_item.nav,
										    	cur_item.cod_tipo_attivita,
												sysdate, 
												'MULTIRAMO - CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA',     
												'S'
												);
													
							DELETE FROM TMP_PFSALDI_POLIZZE TMP_DEL
							WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
							
							SCARTI_CODICERAPPORTO := SCARTI_CODICERAPPORTO +1;			
					END IF;
			
			IF MOD(I,10000) = 0 THEN
				INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MULTI PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: '|| I);
				COMMIT; 
			END IF;
					
		END LOOP;
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MULTI PER CHIAVE ESTERNA NON CENSITA. RECORD ELABORATI: '|| I);
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MULTI PER CODICETITOLO NON CENSITO. RECORD SCARTATI: '|| SCARTI_CODICETITOLO);
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE MULTI PER CODICERAPPORTO NON CENSITO. RECORD SCARTATI: '|| SCARTI_CODICERAPPORTO);
		COMMIT;
		
		I :=0;
		
		FOR CUR_ITEM IN SCARTI_SALDI_POLIZZE_ALTRO
		LOOP 
					
		I := I+1;
		
			IF (CUR_ITEM.R_CODICERAPPORTO IS NULL) THEN				
				INSERT INTO 
					TBL_SCARTI_TMP_PFSALDI_POLIZZE (codicebanca,
													codiceagenzia,
													codicerapporto,
													codiceinterno,
													ramo,
													fondo,
													datasaldo,
													tiporapporto,
													controvalore,
													divisa,
													flagconsolidato,
													ctvversato,
													ctvprelevato,
													ctvversatonetto,
													dataaggiornamento,
													codiceinternomacroprodotto,
													descrizionemacroprodotto,
													valorenominale,
													datacompleannopolizza,
													idtitolo,
													flagesclusione,
													numero_quote,
										   			nav,
										    		cod_tipo_attivita,
													tmstp,
													motivo_scarto,
													riproponibile   
													)
									VALUES (cur_item.codicebanca,       
											cur_item.codiceagenzia,     
											cur_item.codicerapporto,    
											cur_item.codiceinterno,
											cur_item.ramo,
											cur_item.fondo,
											cur_item.datasaldo,
											cur_item.tiporapporto,
											cur_item.controvalore,
											cur_item.divisa,
											cur_item.flagconsolidato,
											cur_item.ctvversato,
											cur_item.ctvprelevato,
											cur_item.ctvversatonetto,
											cur_item.dataaggiornamento,
											cur_item.codiceinternomacroprodotto,
											cur_item.descrizionemacroprodotto,
											cur_item.valorenominale,
											cur_item.datacompleannopolizza,
											cur_item.idtitolo,
											cur_item.flagesclusione,
											cur_item.numero_quote,
										   	cur_item.nav,
										    cur_item.cod_tipo_attivita,
											sysdate,             
											'POLIZZE - CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA',     
											'S'
											);
										
					DELETE FROM TMP_PFSALDI_POLIZZE TMP_DEL
					WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
					
					SCARTI_CODICERAPPORTO := SCARTI_CODICERAPPORTO +1;
				
				ELSE
					INSERT INTO 
						TBL_SCARTI_TMP_PFSALDI_POLIZZE (codicebanca,
														codiceagenzia,
														codicerapporto,
														codiceinterno,
														ramo,
														fondo,
														datasaldo,
														tiporapporto,
														controvalore,
														divisa,
														flagconsolidato,
														ctvversato,
														ctvprelevato,
														ctvversatonetto,
														dataaggiornamento,
														codiceinternomacroprodotto,
														descrizionemacroprodotto,
														valorenominale,
														datacompleannopolizza,
														idtitolo,
														flagesclusione,
														numero_quote,
										   				nav,
										    			cod_tipo_attivita,
														tmstp,
														motivo_scarto,
														riproponibile   
														)
										VALUES (cur_item.codicebanca,       
												cur_item.codiceagenzia,     
												cur_item.codicerapporto,    
												cur_item.codiceinterno,
												cur_item.ramo,
												cur_item.fondo,
												cur_item.datasaldo,
												cur_item.tiporapporto,
												cur_item.controvalore,
												cur_item.divisa,
												cur_item.flagconsolidato,
												cur_item.ctvversato,
												cur_item.ctvprelevato,
												cur_item.ctvversatonetto,
												cur_item.dataaggiornamento,
												cur_item.codiceinternomacroprodotto,
												cur_item.descrizionemacroprodotto,
												cur_item.valorenominale,
												cur_item.datacompleannopolizza,
												cur_item.idtitolo,
												cur_item.flagesclusione,
												cur_item.numero_quote,
										   		cur_item.nav,
										    	cur_item.cod_tipo_attivita,
												sysdate, 
												'POLIZZE - IMPOSSIBILE RICONOSCERE LO STRUMENTO',     
												'S'
												);
													
							DELETE FROM TMP_PFSALDI_POLIZZE TMP_DEL
							WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
							
							SCARTI_CODICETITOLO := SCARTI_CODICETITOLO +1;			
					END IF;
			
			IF MOD(I,10000) = 0 THEN
				INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE ALTRO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: '|| I);
				COMMIT; 
			END IF;
					
		END LOOP;
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE ALTRO PER CHIAVE ESTERNA NON CENSITA. RECORD ELABORATI: '|| I);
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE ALTRO IMPOSSIBILE RICONOSCERE LO STRUMENTO. RECORD SCARTATI: '|| SCARTI_CODICETITOLO);
			 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE ALTRO PER CODICERAPPORTO NON CENSITO. RECORD SCARTATI: '|| SCARTI_CODICERAPPORTO);
		COMMIT;
	END;