DECLARE

CURSOR cerca_movmulti IS 
	SELECT 	TMP.ramo,
			TMP.codice_prodotto,
			TMP.numero_polizza,
			TMP.data_comunicazione_pagamento,
			TMP.cf_beneficiario,
			TMP.modalita_pagamento,
			TMP.codice_fondo,
			TMP.tipologia_liquidazione,
			TMP.isin,
			TMP.quote,
			TMP.nav,
			CASE WHEN TMP.codice_attivita = 'MF' THEN TMP.importo * (-1) 
				 ELSE TMP.importo END AS importo,
			TMP.data_nav,
			TMP.codice_attivita,
			TMP.provvigioni_intermediario,
			TMP.costo_etf,
			TMP.commissioni_di_gestione,
			TMP.numero_pratica																		
	FROM TMP_PFMOV_PAG_FONDO TMP;


--update data movimento con quella del padre
CURSOR update_data_movimento IS 	
	SELECT /*+ parallel(8) */  
			MOV.data AS data_padre,
			tmp.ramo AS ramo,
			tmp.codice_prodotto AS codice_prodotto,
			tmp.numero_polizza AS numero_polizza,
			tmp.data_comunicazione_pagamento AS data_comunicazione_pagamento,
			tmp.cf_beneficiario AS cf_beneficiario,
			tmp.modalita_pagamento AS modalita_pagamento,
			tmp.codice_fondo AS codice_fondo
	FROM TEMP_MOV_PAG_FONDO TMP
	INNER JOIN MOVIMENTO_RAMO_TERZO MOV
	ON tmp.ramo = MOV.ramo
		AND tmp.numero_pratica = MOV.numero_pratica
	WHERE codice_attivita NOT IN ('MF', 'PM')
	AND (MOV.F_CANCELLATO is null OR MOV.F_CANCELLATO != 'S');

		
I 				NUMBER(38,0):=0;
CHECK_TBL		NUMBER(38,0):=0;



BEGIN

	FOR cur_item IN cerca_movmulti
    	LOOP
        I := I+1;
	  	
	INSERT INTO TEMP_MOV_PAG_FONDO (ramo,
									codice_prodotto,
									numero_polizza,
									data_comunicazione_pagamento,
									cf_beneficiario,
									modalita_pagamento,
									codice_fondo,
									tipologia_liquidazione,
									isin,
									quote,
									nav,
									importo,
									data_nav,
									codice_attivita,
									provvigioni_intermediario,
									costo_etf,
									commissioni_di_gestione,
									numero_pratica
								)
						VALUES (	cur_item.ramo,
									cur_item.codice_prodotto,
									cur_item.numero_polizza,
									cur_item.data_comunicazione_pagamento,
									cur_item.cf_beneficiario,
									cur_item.modalita_pagamento,
									cur_item.codice_fondo,
									cur_item.tipologia_liquidazione,
									cur_item.isin,
									cur_item.quote,
									cur_item.nav,
									cur_item.importo,
									cur_item.data_nav,
									cur_item.codice_attivita,
									cur_item.provvigioni_intermediario,
									cur_item.costo_etf,
									cur_item.commissioni_di_gestione,
									cur_item.numero_pratica
								);
				

	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' CARICO TEMP_MOV_PAG_FONDO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' CARICO TEMP_MOV_PAG_FONDO - COMMIT ON ROW: ' || I);
	COMMIT;
	
		
		I:=0;
	
	FOR cur_item IN update_data_movimento
    	LOOP
        I := I+1;
        
        IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE DATA MOVIMENTO PER TEMP_MOV_PAG_FONDO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	
	
	BEGIN
		dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'TEMP_MOV_PAG_FONDO', degree => 4, estimate_percent=>10, cascade=>true);
	END;
	
	UPDATE TEMP_MOV_PAG_FONDO mov
	SET mov.data_comunicazione_pagamento = cur_item.data_padre
	WHERE mov.ramo = cur_item.ramo
		AND mov.codice_prodotto = cur_item.codice_prodotto
		AND mov.numero_polizza = cur_item.numero_polizza
		AND mov.data_comunicazione_pagamento = cur_item.data_comunicazione_pagamento
		AND mov.cf_beneficiario = cur_item.cf_beneficiario
		AND mov.modalita_pagamento = cur_item.modalita_pagamento
		AND mov.codice_fondo = cur_item.codice_fondo;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE DATA MOVIMENTO PER TEMP_MOV_PAG_FONDO - COMMIT ON ROW: ' || I);
	COMMIT;
	
END;