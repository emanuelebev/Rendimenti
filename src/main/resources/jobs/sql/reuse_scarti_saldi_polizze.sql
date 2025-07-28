DECLARE

CURSOR DEL_CUR IS
	SELECT /*+ parallel(8) */ SCARTO.ROWID AS SCARTO_ROWID, 
			SCARTO.*, 
			TMP.ROWID AS TMP_ROWID
	FROM TBL_SCARTI_TMP_PFSALDI_POLIZZE SCARTO
	LEFT JOIN TMP_PFSALDI_POLIZZE TMP
		ON( TMP.CODICEINTERNO = SCARTO.CODICEINTERNO
			AND TMP.CODICERAPPORTO = SCARTO.CODICERAPPORTO
			AND TMP.DATAAGGIORNAMENTO = SCARTO.DATAAGGIORNAMENTO)
	WHERE SCARTO.RIPROPONIBILE = 'S';

I 				NUMBER(38,0):=0;
REUSE_COUNT		NUMBER(38,0):=0;	


BEGIN

	FOR CUR_ITEM IN DEL_CUR 

		LOOP
			
		I := I+1;
		
		IF(CUR_ITEM.TMP_ROWID IS NULL) THEN
		
		INSERT /*+ append nologging parallel(8) */
				INTO TMP_PFSALDI_POLIZZE (	codicebanca,
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
						    				cod_tipo_attivita
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
						    			cur_item.cod_tipo_attivita
								);
										
				REUSE_COUNT := REUSE_COUNT + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM TBL_SCARTI_TMP_PFSALDI_POLIZZE TBL
			WHERE TBL.ROWID = CUR_ITEM.SCARTO_ROWID;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDI_POLIZZE. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDI_POLIZZE. RECORD RECUPERATI: ' || REUSE_COUNT);
		COMMIT;

END;