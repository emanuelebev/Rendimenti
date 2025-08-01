DECLARE
 
	rowcounts NUMBER;

BEGIN
   
MERGE   INTO
    PREZZI PREZ
  USING (
          SELECT
            TPREZ.CODICETITOLO														AS CODICETITOLO,
            TO_NUMBER(TO_CHAR(TO_DATE(TPREZ.DATAPREZZO, 'YYYY-MM-DD'), 'YYYYMMDD'))	AS "DATA",
            TPREZ.PREZZOMERCATO             	 									AS PREZZO,
            TPREZ.RATEOLORDO														AS RATEOLORDO,
            TPREZ.RATEONETTO														AS RATEONETTO,
            TPREZ.RITENUTADISAGGIO													AS RITENUTADISAGGIO,
            TPREZ.POOLFACTOR                 										AS PULLFACTOR,
            TPREZ.COEFFICIENTEINDICIZZAZIONE 										AS INDEXRATIO,
            TO_DATE(TPREZ.DATAAGGIORNAMENTO,'YYYY-MM-DD HH24:MI:SS') 				AS DATAAGGIORNAMENTO,
            TO_NUMBER(TO_CHAR(TO_DATE(TPREZ.DATAPREZZO, 'YYYY-MM-DD'), 'YYYYMMDD'))	AS D_DATA_PREZZO,  
            TO_NUMBER(TO_CHAR(TO_DATE(TPREZ.DATAPREZZO, 'YYYY-MM-DD'), 'YYYYMMDD'))	AS D_RATEO, --PRESA DATAPREZZO AL POSTO DI DATARATEO CHE DOVREBBE ESSERE SEMPRE NULLA
            TPREZ.RATEODISAGGIO             		 								AS RATEO_DISAGGIO,
            TPREZ.COEFFICIENTECORREZIONE     										AS I_COEFF_CORREZIONE,
            TPREZ.DESCRCOEFFINDICIZZAZIONE   										AS DESCR_COEFF_INDIC,
            TO_NUMBER(TPREZ.MOLTIPLICATORE,'999999999999999999999999999.999999999999999999999999999') AS MOLTIPLICATORE,
            NULL                             										AS C_FONTE,
            TPREZ.CODICEDIVISA              		 								AS C_DIVISA,
            TPREZ.PREZZOCONTROVALORE         										AS I_PREZZO_CONTROVALORE,
            NULL                             										AS LOTTO_QTA
          FROM
            TMP_PFPREZZI TPREZ) TOMERGE
  ON
  (PREZ.CODICETITOLO = TOMERGE.CODICETITOLO
   AND PREZ.DATA = TOMERGE.DATA
  )
  WHEN MATCHED THEN
  UPDATE
  SET
    PREZZO = TOMERGE.PREZZO,
    RATEOLORDO = TOMERGE.RATEOLORDO,
    RATEONETTO = TOMERGE.RATEONETTO,
    RITENUTADISAGGIO = TOMERGE.RITENUTADISAGGIO,
    PULLFACTOR = TOMERGE.PULLFACTOR,
    INDEXRATIO = TOMERGE.INDEXRATIO,
    DATAAGGIORNAMENTO = TOMERGE.DATAAGGIORNAMENTO,
    D_DATA_PREZZO = TOMERGE.D_DATA_PREZZO,
    D_RATEO = TOMERGE.D_RATEO,
    RATEO_DISAGGIO = TOMERGE.RATEO_DISAGGIO,
    I_COEFF_CORREZIONE = TOMERGE.I_COEFF_CORREZIONE,
    DESCR_COEFF_INDIC = TOMERGE.DESCR_COEFF_INDIC,
    MOLTIPLICATORE = TOMERGE.MOLTIPLICATORE,
    C_FONTE = TOMERGE.C_FONTE,
    C_DIVISA = TOMERGE.C_DIVISA,
    I_PREZZO_CONTROVALORE = TOMERGE.I_PREZZO_CONTROVALORE,
    LOTTO_QTA = TOMERGE.LOTTO_QTA
  WHEN NOT MATCHED THEN

  INSERT
    (CODICETITOLO,
     "DATA",
     PREZZO,
     RATEOLORDO,
     RATEONETTO,
     RITENUTADISAGGIO,
     PULLFACTOR,
     INDEXRATIO,
     DATAAGGIORNAMENTO,
     D_DATA_PREZZO,
     D_RATEO,
     RATEO_DISAGGIO,
     I_COEFF_CORREZIONE,
     DESCR_COEFF_INDIC,
     MOLTIPLICATORE,
     C_FONTE,
     C_DIVISA,
     I_PREZZO_CONTROVALORE,
     LOTTO_QTA)
  VALUES (
    TOMERGE.CODICETITOLO,
    TOMERGE."DATA",
    TOMERGE.PREZZO,
    TOMERGE.RATEOLORDO,
    TOMERGE.RATEONETTO,
    TOMERGE.RITENUTADISAGGIO,
    TOMERGE.PULLFACTOR,
    TOMERGE.INDEXRATIO,
    TOMERGE.DATAAGGIORNAMENTO,
    TOMERGE.D_DATA_PREZZO,
    TOMERGE.D_RATEO,
    TOMERGE.RATEO_DISAGGIO,
    TOMERGE.I_COEFF_CORREZIONE,
    TOMERGE.DESCR_COEFF_INDIC,
    TOMERGE.MOLTIPLICATORE,
    TOMERGE.C_FONTE,
    TOMERGE.C_DIVISA,
    TOMERGE.I_PREZZO_CONTROVALORE,
    TOMERGE.LOTTO_QTA);
    
    rowcounts := SQL%ROWCOUNT;

  COMMIT;
    
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFPREZZI: ' || rowcounts);
	COMMIT;
  
 END;