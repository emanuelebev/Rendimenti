DECLARE

CURSOR filtro_saldi_polizze_sp_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codiceagenzia, codicerapporto, codiceinterno, ramo, fondo, datasaldo, 
            tiporapporto, controvalore, divisa, flagconsolidato, ctvversato, ctvprelevato, ctvversatonetto, dataaggiornamento, 
            codiceinternomacroprodotto, descrizionemacroprodotto, valorenominale, datacompleannopolizza, idtitolo, flagesclusione
		ORDER BY codicebanca, codiceagenzia, codicerapporto, codiceinterno, ramo, fondo, datasaldo, 
            tiporapporto, controvalore, divisa, flagconsolidato, ctvversato, ctvprelevato, ctvversatonetto, dataaggiornamento, 
            codiceinternomacroprodotto, descrizionemacroprodotto, valorenominale, datacompleannopolizza, idtitolo, flagesclusione) AS pos
		FROM tmp_pfsaldi_polizze_sp
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_saldi_polizze_sp_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfsaldi_polizze_sp tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDI_POLIZZE_SP - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDI_POLIZZE_SP. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;