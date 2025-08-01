DECLARE

CURSOR DEL_CUR IS
	SELECT /*+ parallel(8) */ SCARTO.ROWID AS SCARTO_ROWID, 
			SCARTO.*, 
			TMP.ROWID AS TMP_ROWID
	FROM TBL_SCARTI_TMP_PFSALDI_POLI_SP SCARTO
	LEFT JOIN TMP_PFSALDI_POLIZZE_SP TMP
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
				INTO TMP_PFSALDI_POLIZZE_SP (CODICEBANCA,
											CODICEAGENZIA,
											CODICERAPPORTO,
											CODICEINTERNO,
											RAMO,
											FONDO,
											DATASALDO,
											TIPORAPPORTO,
											CONTROVALORE,
											DIVISA,
											FLAGCONSOLIDATO,
											CTVVERSATO,
											CTVPRELEVATO,
											CTVVERSATONETTO,
											DATAAGGIORNAMENTO,
											CODICEINTERNOMACROPRODOTTO,
											DESCRIZIONEMACROPRODOTTO,
											VALORENOMINALE,
											DATACOMPLEANNOPOLIZZA,
											IDTITOLO,
											FLAGESCLUSIONE
										)
								VALUES (CUR_ITEM.CODICEBANCA,
										CUR_ITEM.CODICEAGENZIA,
										CUR_ITEM.CODICERAPPORTO,
										CUR_ITEM.CODICEINTERNO,
										CUR_ITEM.RAMO,
										CUR_ITEM.FONDO,
										CUR_ITEM.DATASALDO,
										CUR_ITEM.TIPORAPPORTO,
										CUR_ITEM.CONTROVALORE,
										CUR_ITEM.DIVISA,
										CUR_ITEM.FLAGCONSOLIDATO,
										CUR_ITEM.CTVVERSATO,
										CUR_ITEM.CTVPRELEVATO,
										CUR_ITEM.CTVVERSATONETTO,
										CUR_ITEM.DATAAGGIORNAMENTO,
										CUR_ITEM.CODICEINTERNOMACROPRODOTTO,
										CUR_ITEM.DESCRIZIONEMACROPRODOTTO,
										CUR_ITEM.VALORENOMINALE,
										CUR_ITEM.DATACOMPLEANNOPOLIZZA,
										CUR_ITEM.IDTITOLO,
										CUR_ITEM.FLAGESCLUSIONE
								);
										
				REUSE_COUNT := REUSE_COUNT + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM TBL_SCARTI_TMP_PFSALDI_POLI_SP TBL
			WHERE TBL.ROWID = CUR_ITEM.SCARTO_ROWID;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDI_POLIZZE_SP. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDI_POLIZZE_SP. RECORD RECUPERATI: ' || REUSE_COUNT);
		COMMIT;

END;