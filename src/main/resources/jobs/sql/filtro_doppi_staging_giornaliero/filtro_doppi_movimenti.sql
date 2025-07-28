DECLARE

CURSOR filtro_movimenti_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codice, codiceagenzia, codicerapporto, tiporapporto, codiceinterno, causale, 
            ctvregolato, ctvmercato, ctvregolatodivisa, ctvmercatodivisa, divisa, quantita, prezzomercato, prezzo, rateolordo, 
            rateonetto, cambio, dataordine, datacontabile, datavaluta, flagstorno, codicestorno, flagcancellato, imposte, 
            commissioni, dataaggiornamento, id_buono_originario, generated_codicerapporto, imposta_rest
		ORDER BY codicebanca, codice, codiceagenzia, codicerapporto, tiporapporto, codiceinterno, causale, 
            ctvregolato, ctvmercato, ctvregolatodivisa, ctvmercatodivisa, divisa, quantita, prezzomercato, prezzo, rateolordo, 
            rateonetto, cambio, dataordine, datacontabile, datavaluta, flagstorno, codicestorno, flagcancellato, imposte, 
            commissioni, dataaggiornamento, id_buono_originario, generated_codicerapporto, imposta_rest) AS pos
		FROM tmp_pfmovimenti
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_movimenti_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfmovimenti tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOVIMENTI - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOVIMENTI. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;