DECLARE

CURSOR filtro_saldi_polizze_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codiceagenzia, codicerapporto, codiceinterno, ramo, fondo, datasaldo, 
            tiporapporto, controvalore, divisa, flagconsolidato, ctvversato, ctvprelevato, ctvversatonetto, dataaggiornamento, 
            codiceinternomacroprodotto, descrizionemacroprodotto, valorenominale, datacompleannopolizza, idtitolo, flagesclusione,
            numero_quote, nav, cod_tipo_attivita
		ORDER BY codicebanca, codiceagenzia, codicerapporto, codiceinterno, ramo, fondo, datasaldo, 
            tiporapporto, controvalore, divisa, flagconsolidato, ctvversato, ctvprelevato, ctvversatonetto, dataaggiornamento, 
            codiceinternomacroprodotto, descrizionemacroprodotto, valorenominale, datacompleannopolizza, idtitolo, flagesclusione,
            numero_quote, nav, cod_tipo_attivita) AS pos
		FROM tmp_pfsaldi_polizze
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_saldi_polizze_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfsaldi_polizze tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDI_POLIZZE - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFSALDI_POLIZZE. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;