DECLARE

--Movimenti pagamenti fondo polizze premium
CURSOR cerca_movmulti IS 
	SELECT 	/*+ PARALLEL(8) */	  
			r.id																												AS idrapporto,
			CASE WHEN codice_attivita = 'MF' then ramo||'_'||codice_prodotto||'_'||numero_polizza
					||'_'||data_comunicazione_pagamento||'_'||cf_beneficiario
					||'_'||modalita_pagamento||'_'||codice_fondo|| '_' || 'PZ_FGE'
  				 WHEN codice_attivita = 'PM' then ramo||'_'||codice_prodotto||'_'||numero_polizza
  				 	||'_'||data_comunicazione_pagamento||'_'||cf_beneficiario
					||'_'||modalita_pagamento||'_'||codice_fondo|| '_' || 'PZ_FGE_INC'
				ELSE ramo||'_'||codice_prodotto||'_'||numero_polizza||'_'||data_comunicazione_pagamento||'_'||cf_beneficiario
					||'_'||modalita_pagamento||'_'||codice_fondo END															AS numreg,
			ramo																												AS ramo,
			codice_prodotto																										AS codice_prodotto_universo, 
			LPAD(trim(P.numero_polizza),12,'0')																					AS numero_polizza,			
			TO_NUMBER(TO_CHAR(TO_DATE(data_comunicazione_pagamento, 'YYYY-MM-DD'), 'YYYYMMDD')) 								AS data,
			TO_NUMBER(TO_CHAR(TO_DATE(data_comunicazione_pagamento, 'YYYY-MM-DD'), 'YYYYMMDD'))  								AS data_comunicazione_pagamento,
			cf_beneficiario																										AS codice_fiscale_beneficiario,
			modalita_pagamento																									AS modalita_pagamento,
			b.codicetitolo																										AS codicetitolo,
			'13' 																												AS c_procedura,
			CASE WHEN codice_attivita IN ('PM', 'MF') THEN '13_' || codice_attivita
				ELSE '13_' || tipologia_liquidazione END																		AS causale,
			quote																												AS qta,
			nav																													AS prezzo,
			importo																												AS ctv,
			costo_etf																											AS costo_etf,
			provvigioni_intermediario																							AS provvigioni_intermediario,
			commissioni_di_gestione																								AS commissioni_di_gestione,
			numero_pratica																										AS numero_pratica				
	FROM TEMP_MOV_PAG_FONDO p
		INNER JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	INNER JOIN tbl_bridge b
	ON p.codice_fondo = b.cod_universo
	WHERE r.codicetitolo_multiramo is not null
	ORDER BY idrapporto, numreg;


--update flag per i movimenti caricati
CURSOR update_f_cancellato IS 	
	SELECT /*+ parallel(8) */ DISTINCT  mov.idrapporto,
	mov.numreg
	FROM TEMP_MOV_PAG_FONDO TMP
	INNER JOIN MOVIMENTO_RAMO_TERZO MOV
	ON tmp.ramo = MOV.ramo
		AND tmp.numero_pratica = MOV.numero_pratica
	WHERE tmp.codice_attivita not in ('MF', 'PM');
		
I NUMBER(38,0):=0;


BEGIN

	
	FOR cur_item IN cerca_movmulti
    	LOOP
        I := I+1;

		MERGE INTO movimento mov
		  USING (SELECT cur_item.idrapporto           			AS idrapporto,
						cur_item.numreg           				AS numreg,
						cur_item.ramo           				AS ramo,
						cur_item.codice_prodotto_universo		AS codice_prodotto_universo, 
						cur_item.numero_polizza           		AS numero_polizza,
						cur_item.data           				AS data,
						cur_item.data_comunicazione_pagamento   AS data_comunicazione_pagamento,
						cur_item.codice_fiscale_beneficiario    AS codice_fiscale_beneficiario,
						cur_item.modalita_pagamento           	AS modalita_pagamento,
						cur_item.codicetitolo           		AS codicetitolo,
						cur_item.c_procedura           			AS c_procedura,
						cur_item.causale           				AS causale,
						cur_item.qta           					AS qta,
						cur_item.prezzo           				AS prezzo,
						cur_item.ctv           					AS ctv,
						cur_item.costo_etf           			AS costo_etf,
						cur_item.provvigioni_intermediario      AS provvigioni_intermediario,
						cur_item.commissioni_di_gestione        AS commissioni_di_gestione,
						cur_item.numero_pratica 				AS numero_pratica						
			FROM dual
			) tomerge
		  ON (mov.idrapporto = tomerge.idrapporto
		  	 AND mov.numreg = tomerge.numreg)
		   
	WHEN MATCHED THEN UPDATE
		  SET
				mov.ramo = tomerge.ramo,
				mov.codice_prodotto_universo = tomerge.codice_prodotto_universo, 
				mov.numero_polizza = tomerge.numero_polizza,
				mov.data = tomerge.data,
				mov.data_comunicazione_pagamento = tomerge.data_comunicazione_pagamento,
				mov.codice_fiscale_beneficiario = tomerge.codice_fiscale_beneficiario,
				mov.modalita_pagamento = tomerge.modalita_pagamento,
				mov.codicetitolo = tomerge.codicetitolo,
				mov.c_procedura = tomerge.c_procedura,
				mov.causale = tomerge.causale,
				mov.qta = tomerge.qta,
				mov.prezzo = tomerge.prezzo,
				mov.ctv = tomerge.ctv,
				mov.costo_etf = tomerge.costo_etf,
				mov.provvigioni_intermediario = tomerge.provvigioni_intermediario,
				mov.commissioni_di_gestione = tomerge.commissioni_di_gestione,
				mov.numero_pratica = tomerge.numero_pratica		
  	
	WHEN NOT MATCHED THEN 
			INSERT (	idrapporto,
						numreg,
						ramo,
						codice_prodotto_universo, 
						numero_polizza,
						data,
						data_comunicazione_pagamento,
						codice_fiscale_beneficiario,
						modalita_pagamento,
						codicetitolo,
						c_procedura,
						causale,
						qta,
						prezzo,
						ctv,
						costo_etf,
						provvigioni_intermediario,
						commissioni_di_gestione,
						numero_pratica			
					)
  			VALUES (tomerge.idrapporto,
					tomerge.numreg,
					tomerge.ramo,
					tomerge.codice_prodotto_universo, 
					tomerge.numero_polizza,
					tomerge.data,
					tomerge.data_comunicazione_pagamento,
					tomerge.codice_fiscale_beneficiario,
					tomerge.modalita_pagamento,
					tomerge.codicetitolo,
					tomerge.c_procedura,
					tomerge.causale,
					tomerge.qta,
					tomerge.prezzo,
					tomerge.ctv,
					tomerge.costo_etf,
					tomerge.provvigioni_intermediario,
					tomerge.commissioni_di_gestione,
					tomerge.numero_pratica		
				);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_PAG_FONDO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_PAG_FONDO - COMMIT ON ROW: ' || I);
	COMMIT;
	
		
		I:=0;

	
	FOR cur_item IN update_f_cancellato
    	LOOP
        I := I+1;
        
        IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE F_CANCELLATO MOVIMENTO_RAMO_TERZO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	UPDATE MOVIMENTO_RAMO_TERZO m3
	SET f_cancellato = 'S'
	WHERE cur_item.idrapporto = m3.idrapporto
	AND cur_item.numreg = m3.numreg;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE F_CANCELLATO MOVIMENTO_RAMO_TERZO - COMMIT ON ROW: ' || I);
	COMMIT;
	
END;