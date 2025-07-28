BEGIN
   
	
	
END;

DECLARE

  CURSOR SCARTI_MOV IS
    SELECT   
      SF.CODICETITOLO  AS SF_CODICETITOLO,
      R.CODICERAPPORTO AS R_CODICERAPPORTO,
      C.CODICECAUSALE  AS C_CODICECAUSALE,
      TMP.ROWID,
      TMP.*
    FROM TMP_PFMOVIMENTI TMP
      LEFT JOIN STRUMENTOFINANZIARIO SF
        ON SF.CODICETITOLO = TMP.CODICEINTERNO
      LEFT JOIN RAPPORTO R
        ON SUBSTR(TMP.CODICERAPPORTO, INSTR(TMP.CODICERAPPORTO, '-')+1)= R.CODICERAPPORTO
        AND TMP.TIPORAPPORTO = R.TIPO
        AND TMP.CODICEBANCA = R.CODICEBANCA
      LEFT JOIN CAUSALE C
        ON C.CODICECAUSALE = TMP.CAUSALE;


  I                     NUMBER(38, 0) := 0;
  SCARTI_CODICETITOLO   NUMBER := 0;
  SCARTI_CODICERAPPORTO NUMBER := 0;
  SCARTI_CAUSALE		NUMBER := 0;
  INSERT_NUOVA_CAUSALE  NUMBER := 0;
  CHECK_CAUSALE         NUMBER := 0;
  INSERTED_ROWS         NUMBER := 0;

BEGIN

  FOR CUR_ITEM IN SCARTI_MOV

  LOOP

    I := I + 1;


    IF (CUR_ITEM.SF_CODICETITOLO IS NULL)
    THEN
      INSERT   
      INTO 
        TBL_SCARTI_TMP_PFMOVIMENTI (CODICEBANCA,
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
                                    SYSDATE,
                                    'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
                                    'S'
                                  );


      DELETE    FROM TMP_PFMOVIMENTI DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;

      SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;

    ELSIF (CUR_ITEM.R_CODICERAPPORTO IS NULL)
      THEN
        INSERT
        INTO   
          TBL_SCARTI_TMP_PFMOVIMENTI (CODICEBANCA,
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
                                      SYSDATE,
                                      'CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA',
                                      'S'
                                    );

        DELETE     FROM TMP_PFMOVIMENTI DEL_TMP_MOV
        WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;

        SCARTI_CODICERAPPORTO := SCARTI_CODICERAPPORTO + 1;
        
         
   ELSIF (CUR_ITEM.C_CODICECAUSALE IS NULL)
      THEN

        INSERT   INTO CAUSALE (CODICECAUSALE,
                             CAUCONTR,
                             DATAAGGIORNAMENTO,
                             DATAINSERIMENTO,
                             DESCRIZIONE,
                             FLAGAGGSALDI,
                             --PROCEDURA,
                             SEGNO,
                             TIPOCAUSALE,
                             SOTL,
                             CODICEBANCA,
                             CANALE,
                             TIPOLOGIA_CAUSALE)
          SELECT
            CUR_ITEM.CAUSALE,
            NULL,
            NULL,
            TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')),
            CUR_ITEM.CAUSALE,
            '1',
            NULL,
            NULL,
            '4',
            NULL,
            '07601',
           -- CUR_ITEM.C_PROCEDURA,
            CASE
            WHEN (CUR_ITEM.QUANTITA IS NOT NULL AND CUR_ITEM.QUANTITA > 0)
              THEN 'VER'
            WHEN (CUR_ITEM.QUANTITA IS NOT NULL AND CUR_ITEM.QUANTITA < 0)
              THEN 'PREL'
            WHEN (CUR_ITEM.QUANTITA IS NULL AND CUR_ITEM.CTVREGOLATO < 0)
              THEN 'PREL'
            WHEN (CUR_ITEM.QUANTITA IS NULL AND CUR_ITEM.CTVREGOLATO > 0)
              THEN 'VER'
            END
          FROM DUAL
          WHERE NOT EXISTS
          (SELECT 1
           FROM CAUSALE
           WHERE CODICECAUSALE = CUR_ITEM.CAUSALE);
        INSERTED_ROWS := SQL%ROWCOUNT;

        INSERT_NUOVA_CAUSALE := INSERT_NUOVA_CAUSALE + INSERTED_ROWS;

        /*
        MERGE INTO REPORT_SCARTI RS
        USING (SELECT
                 'MOVIMENTO'                                        AS NOME_FLUSSO,
                 '${ABI}'                                           AS BANCA,
                 TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD'))            AS DATA_SCARTO,
                 CUR_ITEM.C_PROCEDURA                               AS PARTITARIO,
                 'NUOVA CAUSALE INSERITA: ' || CUR_ITEM.CAUSALE_MOD AS MOTIVO_SCARTO,
                 NULL                                               AS RECORD_SCARTATI,
                 SYSDATE                                            AS TMSTP
               FROM DUAL) A
        ON (RS.NOME_FLUSSO = A.NOME_FLUSSO
            AND RS.BANCA = A.BANCA
            AND RS.DATA_SCARTO = A.DATA_SCARTO
            AND RS.PARTITARIO = A.PARTITARIO
            AND RS.MOTIVO_SCARTO = A.MOTIVO_SCARTO)
        WHEN MATCHED THEN
        UPDATE SET
          RS.TOTALE_SCARTI = A.RECORD_SCARTATI,
          RS.TMSTP = A.TMSTP
        WHEN NOT MATCHED THEN
        INSERT (NOME_FLUSSO,
                BANCA,
                TOTALE_SCARTI,
                DATA_SCARTO,
                PARTITARIO,
                MOTIVO_SCARTO,
                TMSTP)
        VALUES (A.NOME_FLUSSO,
          A.BANCA,
          A.RECORD_SCARTATI,
          A.DATA_SCARTO,
          A.PARTITARIO,
          A.MOTIVO_SCARTO,
          A.TMSTP);*/

    END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) ||
                                             ' SCARTI TMP_PFMOVIMENTI PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: '
                                             || I);
      COMMIT;
    END IF;

  END LOOP;
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) ||
                                         ' SCARTI TMP_PFMOVIMENTI PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '
                                         || I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (
    TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOVIMENTI FK NON CENSITA (CODICETITOLO): ' ||
    SCARTI_CODICETITOLO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (
    TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOVIMENTI FK NON CENSITA (CODICERAPPORTO): ' ||
    SCARTI_CODICERAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (
    TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOVIMENTI NUOVE CAUSALI INSERITE: ' ||
    INSERT_NUOVA_CAUSALE);

  COMMIT;
END;