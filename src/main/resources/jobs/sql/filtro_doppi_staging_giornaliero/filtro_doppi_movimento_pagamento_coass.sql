DECLARE

CURSOR filtro_mov_pagamenti_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY ramo, codice_prodotto, numero_polizza, data_comunicazione_pagamento, 
            codice_fiscale_beneficiario, modalita_pagamento, frazionario_di_emissione, tipo_liquidazione,
            codice_frazionamento, data_effetto_polizza, data_scadenza, data_valuta, data_competenza, 
            codice_fiscale_contraente, strumento_di_pagamento, importo_pagato, interesse_mora, 
            ritenuta_interesse_mora, costo_liquidazione, imposta_sostitutiva, imposta_bollo,
            importo_pagato_coass, costo_liquidazione_coass, imposta_sostitutiva_coass, 
			imposta_bollo_coass, interesse_mora_coass,ritenuta_interesse_mora_coass,data_calcolo_pagamento,
			costo_etf, numero_pratica
		ORDER BY ramo, codice_prodotto, numero_polizza, data_comunicazione_pagamento, 
            codice_fiscale_beneficiario, modalita_pagamento, frazionario_di_emissione, tipo_liquidazione,
            codice_frazionamento, data_effetto_polizza, data_scadenza, data_valuta, data_competenza, 
            codice_fiscale_contraente, strumento_di_pagamento, importo_pagato, interesse_mora, 
            ritenuta_interesse_mora, costo_liquidazione, imposta_sostitutiva, imposta_bollo,
            importo_pagato_coass, costo_liquidazione_coass, imposta_sostitutiva_coass, 
			imposta_bollo_coass, interesse_mora_coass,ritenuta_interesse_mora_coass,data_calcolo_pagamento, 
			costo_etf, numero_pratica) AS pos
		FROM tmp_pfmov_pag_coass
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_mov_pagamenti_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfmov_pag_coass tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_PAG_COASS - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_PAG_COASS. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;