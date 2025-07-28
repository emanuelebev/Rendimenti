DECLARE

CURSOR cerca_quotazione IS 
	SELECT 	/*+ PARALLEL(8) */	  
			codice_prodotto 	AS codice_prodotto,
			codice_fondo		AS codice_fondo,
			tbl.codicetitolo	AS codicetitolo,
			descrizione_fondo	AS descrizione_fondo,
			data_riferimento	AS data_riferimento,
			valore				AS valore																						
	FROM TMP_QUOTAZIONE_R3 tmp
	INNER JOIN TBL_BRIDGE tbl
    ON tmp.codice_fondo = tbl.cod_universo;


I NUMBER(38,0):=0;


BEGIN
	
	FOR cur_item IN cerca_quotazione
    	LOOP
        I := I+1;

		MERGE INTO QUOTAZIONE_R3 quot
		  USING (SELECT cur_item.codice_prodotto 	AS codice_prodotto,
						cur_item.codice_fondo		AS codice_fondo,
						cur_item.codicetitolo		AS codicetitolo,
						cur_item.descrizione_fondo	AS descrizione_fondo,
						cur_item.data_riferimento	AS data_riferimento,
						cur_item.valore				AS valore
			FROM dual
			) tomerge
		  ON (quot.codice_prodotto = tomerge.codice_prodotto
		  	 AND quot.codice_fondo = tomerge.codice_fondo
		  	 AND quot.data_riferimento = tomerge.data_riferimento)
		   
	WHEN MATCHED THEN UPDATE
		  SET
		    quot.descrizione_fondo = tomerge.descrizione_fondo,
		    quot.valore = tomerge.valore,
            quot.codicetitolo = tomerge.codicetitolo
  	
	WHEN NOT MATCHED THEN 
			INSERT (codice_prodotto,
					codice_fondo,
					codicetitolo,
					descrizione_fondo,
					data_riferimento,
					valore						
					)
  			VALUES (tomerge.codice_prodotto,
					tomerge.codice_fondo,
					tomerge.codicetitolo,
					tomerge.descrizione_fondo,
					tomerge.data_riferimento,
					tomerge.valore			
				);
 
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_QUOTAZIONE_R3 - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_QUOTAZIONE_R3 - COMMIT ON ROW: ' || I);
	COMMIT;
	
END;