DECLARE

  CURSOR SCARTI_MOV_DATAVALUTA IS
  select /*+ parallel(8) */ tmp.rowid, tmp.*
  from TMP_PFMOVIMENTI TMP
  where tmp.DATAVALUTA is NULL and TIPORAPPORTO in ('14', '03');
  
  CURSOR SCARTI_MOV_DATACONTABILE IS
  select /*+ parallel(8) */ tmp.rowid, tmp.*
  from TMP_PFMOVIMENTI TMP
  where tmp.DATACONTABILE is NULL and TIPORAPPORTO in ('14', '97', '03');
 
  I                     NUMBER(38, 0) := 0;

BEGIN
	
  FOR CUR_ITEM IN SCARTI_MOV_DATAVALUTA

  LOOP

    I := I + 1;

      INSERT INTO TBL_SCARTI_TMP_PFMOVIMENTI (CODICEBANCA,
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
										        SYSDATE,
										        'Campo obbligatorio DATAVALUTA assente',
										        'N'
										      );


      DELETE /*+ nologging */ FROM TMP_PFMOVIMENTI DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOVIMENTI PER CAMPO OBBLIGATORIO (DATAVALUTA) NON VALORIZZATO - COMMIT ON ROW: '|| I);
      COMMIT;
    END IF;

  END LOOP;
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOVIMENTI PER CAMPO OBBLIGATORIO (DATAVALUTA) NON VALORIZZATO - COMMIT ON ROW: '|| I);
  COMMIT;
  
  I := 0;
  
  FOR CUR_ITEM IN SCARTI_MOV_DATACONTABILE

  LOOP

    I := I + 1;

      INSERT INTO TBL_SCARTI_TMP_PFMOVIMENTI (CODICEBANCA,
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
										        SYSDATE,
										        'Campo obbligatorio DATACONTABILE assente',
										        'N'
										      );


      DELETE /*+ nologging */ FROM TMP_PFMOVIMENTI DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOVIMENTI PER CAMPO OBBLIGATORIO (DATACONTABILE) NON VALORIZZATO - COMMIT ON ROW: '|| I);
      COMMIT;
    END IF;

  END LOOP;
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOVIMENTI PER CAMPO OBBLIGATORIO (DATACONTABILE) NON VALORIZZATO - COMMIT ON ROW: '|| I);
  COMMIT;
  
END;