DECLARE

--Saldi polizze monoramo
CURSOR scarti_saldi_polizze_mono IS
	SELECT /*+ parallel(8) */ sp.*, sp.ROWID
		FROM TMP_PFSALPOL_RECUP sp
		LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		INNER JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		INNER JOIN rapporto R
			ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
			AND R.tipo = '13'
		WHERE b.codicetitolo IS NULL
		AND sp.flagesclusione = '0'
		AND sf.livello_2 = 'POLIZZE RAMO I'
		AND to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')) > to_number(to_char(sysdate, 'YYYYMMDD'));

	
--Saldi polizze multiramo
CURSOR scarti_saldi_polizze_multi IS
	SELECT /*+ parallel(8) */ sp.*, sp.ROWID
	FROM TMP_PFSALPOL_RECUP sp
		LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		INNER JOIN rapporto R
			ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
				AND R.tipo = '13'
	WHERE  sp.flagesclusione = '0'
	AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
	AND to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')) > to_number(to_char(sysdate, 'YYYYMMDD'));

	
I 							NUMBER(38,0):=0;	
scarti_data			 		NUMBER:=0;



BEGIN
		
	FOR cur_item IN scarti_saldi_polizze_mono
		LOOP 
					
		I := I+1;
		
			INSERT INTO 
					TBL_SCARTI_TMP_PFSALPOL_RECUP (codicebanca,
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
											sysdate,             
											'MONORAMO - DATA FUTURA',     
											'S'
											);
										
					DELETE FROM TMP_PFSALPOL_RECUP tmp_del
					WHERE tmp_del.ROWID = cur_item.ROWID;
					
					scarti_data := scarti_data +1;
			
			IF MOD(I,10000) = 0 THEN
				INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MONO PER DATA FUTURA - COMMIT ON ROW: '|| I);
				COMMIT; 
			END IF;
					
		END LOOP;
			 INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MONO PER DATA FUTURA. RECORD ELABORATI: '|| I);
			 INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MONO PER DATA FUTURA. RECORD SCARTATI: '|| scarti_data);
		COMMIT;
		
		I := 0;
		scarti_data := 0;
		
	FOR cur_item IN scarti_saldi_polizze_multi
		LOOP 
				
		I := I+1;
		
			INSERT INTO 
					TBL_SCARTI_TMP_PFSALPOL_RECUP (codicebanca,
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
											sysdate,             
											'MULTIRAMO - DATA FUTURA',     
											'S'
											);
										
					DELETE FROM TMP_PFSALPOL_RECUP tmp_del
					WHERE tmp_del.ROWID = cur_item.ROWID;
					
					scarti_data := scarti_data +1;
							
			IF MOD(I,10000) = 0 THEN
				INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MULTI PER DATA FUTURA NON CENSITA - COMMIT ON ROW: '|| I);
				COMMIT; 
			END IF;
					
		END LOOP;
			 INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MULTI PER DATA FUTURA. RECORD ELABORATI: '|| I);
			 INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MULTI PER DATA FUTURA. RECORD SCARTATI: '|| scarti_data);
		COMMIT;
	END;