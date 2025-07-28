DECLARE
 
CURSOR cerca_quotazione IS 
	SELECT 	/*+ PARALLEL(8) */	  
		tbl.codicetitolo              													AS codicetitolo,
        'C'                              												AS tipo,
        'EUR'																			AS divisa,
        to_number(to_char(to_date(quot.data_riferimento, 'YYYY-mm-dd'), 'yyyymmdd'))	AS datalivello,
        quot.valore         					 										AS valore,
		sysdate									 										AS data_aggiornamento,
        quot.valore																		AS valore_lordo
    FROM TMP_QUOTAZIONE_R3 quot
    INNER JOIN TBL_BRIDGE tbl
    ON quot.codice_fondo = tbl.cod_universo;

I NUMBER(38,0):=0;


BEGIN

	FOR cur_item IN cerca_quotazione
    	LOOP
        I := I+1;

		MERGE INTO SERIE_STORICA ser
		  USING (SELECT cur_item.codicetitolo 					AS codicetitolo,
						cur_item.tipo							AS tipo,
						cur_item.divisa							AS divisa,
						cur_item.datalivello					AS datalivello,
						cur_item.valore							AS valore,
						cur_item.valore_lordo					AS valore_lordo,
						cur_item.data_aggiornamento				AS data_aggiornamento
			FROM dual
			) tomerge
		  ON (ser.codicetitolo = tomerge.codicetitolo
 			AND ser.tipo = tomerge.tipo
   			AND ser.datalivello = tomerge.datalivello)
		   
	WHEN MATCHED THEN UPDATE
		  SET
			ser.valore = tomerge.valore,
 		 	ser.divisa = tomerge.divisa,
   		 	ser.valore_lordo = tomerge.valore_lordo,
    		ser.data_aggiornamento = tomerge.data_aggiornamento
    		
  WHEN NOT MATCHED THEN
  INSERT
    (	codicetitolo, 
	    tipo, 
	    datalivello, 
	    valore, 
	    divisa, 
	    valore_lordo, 
	    data_aggiornamento
	 )
  VALUES (
	    tomerge.codicetitolo,
	    tomerge.tipo,
	    tomerge.datalivello,
	    tomerge.valore,
	    tomerge.divisa,
	    tomerge.valore_lordo,
	    tomerge.data_aggiornamento
	);
 
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SERIE_STORICA DA TMP_QUOTAZIONE_R3 - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SERIE_STORICA DA TMP_QUOTAZIONE_R3: ' || I || ' record.');
	COMMIT;
  
END;