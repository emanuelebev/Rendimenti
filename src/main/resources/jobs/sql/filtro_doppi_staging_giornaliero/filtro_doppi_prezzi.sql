DECLARE

CURSOR filtro_prezzi_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codicebanca, codicetitolo, dataprezzo, codicedivisa, prezzocontrovalore, prezzomercato, 
            rateolordo, rateonetto, rateodisaggio, ritenutadisaggio, datarateo, codicefonte, coefficientecorrezione, 
            poolfactor, coefficienteindicizzazione, descrcoeffindicizzazione, moltiplicatore, prezzocontrovalorelordista, 
            dataaggiornamento
		ORDER BY codicebanca, codicetitolo, dataprezzo, codicedivisa, prezzocontrovalore, prezzomercato, 
            rateolordo, rateonetto, rateodisaggio, ritenutadisaggio, datarateo, codicefonte, coefficientecorrezione, 
            poolfactor, coefficienteindicizzazione, descrcoeffindicizzazione, moltiplicatore, prezzocontrovalorelordista, 
            dataaggiornamento) AS pos
		FROM tmp_pfprezzi
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_prezzi_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfprezzi tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFPREZZI - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFPREZZI. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;