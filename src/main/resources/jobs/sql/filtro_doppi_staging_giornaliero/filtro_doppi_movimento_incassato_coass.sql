DECLARE

CURSOR filtro_mov_incassato_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY ramo, codice_prodotto, numero_polizza, tipo_titolo, data_effetto_titolo, 
            data_effetto_polizza, frazionario_di_emissione, codice_frazionamento, data_scadenza, data_valuta, data_competenza,    
            codice_fiscale_contraente, premio_lordo, premio_netto, premio_puro, premio_imponibile, caricamento, 
            diritto_fisso, codice_motivo_storno, provvigioni_di_acquisto, provvigioni_di_incasso, data_carico,        
            imposte_coass, interesse_mora, ritenuta_interesse_mora, costo_compagnia, codice_accordo, premio_lordo_coass,
			caricamento_coass, imposte_netto_coass, diritto_fisso_coass, interesse_mora_coass, ritenuta_interesse_mora_coass,
			provvigioni_di_acquisto_coass, provvigioni_di_incasso_coass, costo_etf, codice_tipo_contributo
		ORDER BY ramo, codice_prodotto, numero_polizza, tipo_titolo, data_effetto_titolo, 
            data_effetto_polizza, frazionario_di_emissione, codice_frazionamento, data_scadenza, data_valuta, data_competenza,    
            codice_fiscale_contraente, premio_lordo, premio_netto, premio_puro, premio_imponibile, caricamento, 
            diritto_fisso, codice_motivo_storno, provvigioni_di_acquisto, provvigioni_di_incasso, data_carico,        
            imposte_coass, interesse_mora, ritenuta_interesse_mora, costo_compagnia, codice_accordo, premio_lordo_coass,
			caricamento_coass, imposte_netto_coass, diritto_fisso_coass, interesse_mora_coass, ritenuta_interesse_mora_coass,
			provvigioni_di_acquisto_coass, provvigioni_di_incasso_coass, costo_etf, codice_tipo_contributo) AS pos
		FROM tmp_pfmov_inc_coass
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_mov_incassato_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfmov_inc_coass tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_INC_COASS - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_INC_COASS. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;