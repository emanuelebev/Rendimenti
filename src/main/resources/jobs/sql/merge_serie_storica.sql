DECLARE
 
	rowcounts NUMBER;

	
BEGIN

MERGE    INTO
    SERIE_STORICA ser
  USING (
          SELECT
            tprez.CODICETITOLO              							AS CODICETITOLO,
            'C'                              							AS TIPO,
            to_number(to_char(TO_DATE(tprez.DATAPREZZO, 'YYYY-mm-dd'), 'yyyymmdd'))	AS DATALIVELLO,
            tprez.PREZZOCONTROVALORE         					 		AS VALORE,
            tprez.CODICEDIVISA              						  	AS DIVISA,
            TO_DATE(tprez.DATAAGGIORNAMENTO, 'yyyy-mm-dd hh24:mi:ss') 	AS DATA_AGGIORNAMENTO,
            tprez.PREZZOCONTROVALORELORDISTA							AS VALORE_LORDO
          FROM
            TMP_PFPREZZI tprez) tomerge
  ON
  (ser.CODICETITOLO = tomerge.CODICETITOLO
   AND ser.TIPO = tomerge.TIPO
   AND ser.DATALIVELLO = tomerge.DATALIVELLO
  )
  WHEN MATCHED THEN
  UPDATE
  SET
    ser.VALORE = tomerge.VALORE,
    ser.DIVISA = tomerge.DIVISA,
    ser.VALORE_LORDO = tomerge.VALORE_LORDO,
    ser.DATA_AGGIORNAMENTO = tomerge.DATA_AGGIORNAMENTO
  WHEN NOT MATCHED THEN
  INSERT
    (CODICETITOLO, TIPO, DATALIVELLO, VALORE, DIVISA, VALORE_LORDO, DATA_AGGIORNAMENTO)
  VALUES (
    tomerge.CODICETITOLO,
    tomerge.TIPO,
    tomerge.DATALIVELLO,
    tomerge.VALORE,
    tomerge.DIVISA,
    tomerge.VALORE_LORDO,
    tomerge.DATA_AGGIORNAMENTO
  );
COMMIT;

MERGE    INTO
    SERIE_STORICA ser
  USING (
          SELECT
            tprez.CODICETITOLO               AS CODICETITOLO,
            'C'                              AS TIPO,
            TO_NUMBER(
                TO_CHAR(
                    GREATEST(
                        COALESCE(
                            TO_DATE(tprez.DATAPREZZO, 'yyyy-mm-dd'), TO_DATE(1, 'j')),
                        COALESCE(
                            TO_DATE(tprez.DATARATEO, 'yyyy-mm-dd'), TO_DATE(1, 'j'))
                    ), 'yyyymmdd')
            )                                AS DATALIVELLO,
            tprez.PREZZOCONTROVALORE         AS VALORE,
            tprez.CODICEDIVISA               AS DIVISA,
            TO_DATE(tprez.DATAAGGIORNAMENTO,
                    'yyyy-mm-dd hh24:mi:ss') AS DATA_AGGIORNAMENTO,
            tprez.PREZZOCONTROVALORELORDISTA AS VALORE_LORDO
          FROM
            TMP_PFPREZZI tprez) tomerge
  ON
  (ser.CODICETITOLO = tomerge.CODICETITOLO
   AND ser.TIPO = tomerge.TIPO
   AND ser.DATALIVELLO = tomerge.DATALIVELLO
  )
  WHEN MATCHED THEN
  UPDATE
  SET
    ser.VALORE = tomerge.VALORE,
    ser.DIVISA = tomerge.DIVISA,
    ser.VALORE_LORDO = tomerge.VALORE_LORDO,
    ser.DATA_AGGIORNAMENTO = tomerge.DATA_AGGIORNAMENTO
  WHEN NOT MATCHED THEN
  INSERT
    (CODICETITOLO, TIPO, DATALIVELLO, VALORE, DIVISA, VALORE_LORDO, DATA_AGGIORNAMENTO)
  VALUES (
    tomerge.CODICETITOLO,
    tomerge.TIPO,
    tomerge.DATALIVELLO,
    tomerge.VALORE,
    tomerge.DIVISA,
    tomerge.VALORE_LORDO,
    tomerge.DATA_AGGIORNAMENTO
  );
  
  rowcounts := SQL%ROWCOUNT;
  
  COMMIT;
  
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SERIE_STORICA DA TMP_PFPREZZI: ' || rowcounts);
	COMMIT;
  
END;