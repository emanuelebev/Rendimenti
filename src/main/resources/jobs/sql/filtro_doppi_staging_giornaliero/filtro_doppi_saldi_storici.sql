DECLARE

CURSOR filtro_saldistorici_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codiceagenzia, codicerapporto, codiceinterno, datasaldo, tiporapporto, 
            controvalore, divisa, flagconsolidato, ctvversato, ctvprelevato, ctvversatonetto, dataaggiornamento, 
            codicefasciarendimento, decrizionefasciarendimento, seriebuono, valorescadenzalordo, flagnettistalordista, 
            importonetto, valorescadenzanetto, valorenominale, datasottoscrizione, datascadenza, id_buono_originario
		ORDER BY codicebanca, codiceagenzia, codicerapporto, codiceinterno, datasaldo, tiporapporto, 
            controvalore, divisa, flagconsolidato, ctvversato, ctvprelevato, ctvversatonetto, dataaggiornamento, 
            codicefasciarendimento, decrizionefasciarendimento, seriebuono, valorescadenzalordo, flagnettistalordista, 
            importonetto, valorescadenzanetto, valorenominale, datasottoscrizione, datascadenza, id_buono_originario) AS pos
		FROM tmp_pfsaldistorici
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_saldistorici_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfsaldistorici tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDISTORICI - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDISTORICI. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;