DECLARE

  CURSOR SCARTI_MOV IS
  select /*+ parallel(8) */ tmp.rowid, tmp.*
  from TMP_PFMOV_TITOLI TMP
  where tmp.codiceinterno is null
  and tmp.tiporapporto != '02';
 
  I                     NUMBER(38, 0) := 0;

BEGIN
	

  FOR CUR_ITEM IN SCARTI_MOV

  LOOP

    I := I + 1;

      INSERT INTO TBL_SCARTI_TMP_PFMOV_TITOLI (CODICEBANCA,
		                                       CODICE,
		                                       CODICEAGENZIA,
		                                       CODICERAPPORTO,
		                                       TIPORAPPORTO,
		                                       CODICEINTERNO,
		                                       CAUSALE,
		                                       CTVREGOLATO,
		                                       CTVMERCATO,
		                                       CTVREGOLATODIVISA,
		                                       CTVMERCATODIVISA,
		                                       DIVISA,
		                                       QUANTITA,
		                                       PREZZOMERCATO,
		                                       PREZZO,
		                                       RATEOLORDO,
		                                       RATEONETTO,
		                                       CAMBIO,
		                                       DATAORDINE,
		                                       DATACONTABILE,
		                                       DATAVALUTA,
		                                       FLAGSTORNO,
		                                       CODICESTORNO,
		                                       FLAGCANCELLATO,
		                                       IMPOSTE,
		                                       COMMISSIONI,
		                                       DATAAGGIORNAMENTO,
		                                       IMPOSTA_REST,
		                                       QUANTITA_DA_SISTEMARE,
		                                       TMSTP,
		                                       MOTIVO_SCARTO,
		                                       RIPROPONIBILE) 
		                               VALUES (
										        CUR_ITEM.CODICEBANCA,
										        CUR_ITEM.CODICE,
										        CUR_ITEM.CODICEAGENZIA,
										        CUR_ITEM.CODICERAPPORTO,
										        CUR_ITEM.TIPORAPPORTO,
										        CUR_ITEM.CODICEINTERNO,
										        CUR_ITEM.CAUSALE,
										        CUR_ITEM.CTVREGOLATO,
										        CUR_ITEM.CTVMERCATO,
										        CUR_ITEM.CTVREGOLATODIVISA,
										        CUR_ITEM.CTVMERCATODIVISA,
										        CUR_ITEM.DIVISA,
										        CUR_ITEM.QUANTITA,
										        CUR_ITEM.PREZZOMERCATO,
										        CUR_ITEM.PREZZO,
										        CUR_ITEM.RATEOLORDO,
										        CUR_ITEM.RATEONETTO,
										        CUR_ITEM.CAMBIO,
										        CUR_ITEM.DATAORDINE,
										        CUR_ITEM.DATACONTABILE,
										        CUR_ITEM.DATAVALUTA,
										        CUR_ITEM.FLAGSTORNO,
										        CUR_ITEM.CODICESTORNO,
										        CUR_ITEM.FLAGCANCELLATO,
										        CUR_ITEM.IMPOSTE,
										        CUR_ITEM.COMMISSIONI,
										        CUR_ITEM.DATAAGGIORNAMENTO,
										        CUR_ITEM.IMPOSTA_REST,
										        CUR_ITEM.QUANTITA_DA_SISTEMARE,
										        SYSDATE,
										        'CAMPO OBBLIGATORIO (CODICEINTERNO) NON VALORIZZATO',
										        'N'
										      );


      DELETE /*+ nologging */ FROM TMP_PFMOV_TITOLI DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_TITOLI PER CAMPO OBBLIGATORIO (CODICEINTERNO) NON VALORIZZATO - COMMIT ON ROW: '|| I);
      COMMIT;
    END IF;

  END LOOP;
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_TITOLI PER CAMPO OBBLIGATORIO (CODICEINTERNO) NON VALORIZZATO - COMMIT ON ROW: '|| I);
  COMMIT;
END;