DECLARE

CURSOR filtro_mov_pag_fondo IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY ramo, codice_prodotto, numero_polizza, data_comunicazione_pagamento, numero_pratica,
				cf_beneficiario, modalita_pagamento, codice_fondo, tipologia_liquidazione, isin,
				quote, nav, importo, data_nav, codice_attivita,	provvigioni_intermediario,
				costo_etf, commissioni_di_gestione
		ORDER BY ramo, codice_prodotto, numero_polizza, data_comunicazione_pagamento, numero_pratica,
				cf_beneficiario, modalita_pagamento, codice_fondo, tipologia_liquidazione, isin,
				quote, nav, importo, data_nav, codice_attivita,	provvigioni_intermediario ) AS pos
		FROM tmp_pfmov_pag_fondo
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_mov_pag_fondo

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfmov_pag_fondo tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_PAG_FONDO - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_PAG_FONDO. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;