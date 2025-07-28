DECLARE

--Movimenti pagamento multiramo premium
CURSOR cerca_movmulti IS 
	SELECT 	/*+ PARALLEL(8) */	  
			r.id																														AS idrapporto,
			numero_polizza||'_'||codice_prodotto||'_'||ramo||'_'||tipo_liquidazione||'_'||data_valuta||'_'||codice_fiscale_beneficiario
				||'_'||data_comunicazione_pagamento||'_'||modalita_pagamento||'_'||codice_frazionamento									AS numreg,
			'1'																															AS cambio,
			r.tipo || '_' || tipo_liquidazione																							AS causale,
			CASE WHEN (ramo = '01' and codice_prodotto IN (
						SELECT codicetitolo
						FROM POLIZZE_SOTTOSTANTI)) THEN r.codicetitolo_multiramo  || 'RI' 
			ELSE b.codicetitolo END	    																								AS codicetitolo,
			(importo_pagato_coass * -1)	+ NVL(INTERESSE_MORA_COASS, 0) + NVL(RITENUTA_INTERESSE_MORA_COASS, 0) 
				+ NVL(COSTO_LIQUIDAZIONE_COASS, 0) + NVL(IMPOSTA_SOSTITUTIVA_COASS, 0) + NVL(IMPOSTA_BOLLO_COASS, 0)					AS ctv,
			(importo_pagato_coass * -1)																									AS ctvnetto,
			importo_pagato_coass																										AS ctvdivisa,
			TO_NUMBER(TO_CHAR(TO_DATE(data_valuta, 'YYYY-MM-DD'), 'YYYYMMDD'))															AS data,
			TO_NUMBER(TO_CHAR(TO_DATE(DATA_VALUTA, 'YYYY-MM-DD'), 'YYYYMMDD'))															AS valuta,
			'EUR' 																														AS divisa,
			'13' 																														AS c_procedura,
			codice_prodotto																												AS codice_prodotto_universo,
			ramo																														AS ramo,
			TO_DATE(data_effetto_polizza, 'YYYYMMDD')																					AS data_effetto_polizza,
			TO_DATE(data_scadenza, 'YYYYMMDD')																							AS data_scadenza,
			interesse_mora_coass 																										AS interesse_mora,
			ritenuta_interesse_mora_coass																								AS rit_interesse_mora,
			costo_liquidazione_coass																									AS costo_liquidazione,
			imposta_sostitutiva_coass																									AS imposta_sostitutiva,
			imposta_bollo_coass																											AS imposta_bollo,
			codice_fiscale_beneficiario																									AS codice_fiscale_beneficiario,
			data_comunicazione_pagamento																								AS data_comunicazione_pagamento,
			modalita_pagamento																											AS modalita_pagamento,
			codice_frazionamento																										AS codice_frazionamento,
			data_competenza																												AS data_competenza
	FROM TMP_PFMOV_PAG_COASS P
		LEFT JOIN (
	        	SELECT codicetitolo, cod_universo, cod_linea
	            FROM tbl_bridge
	        ) b
				ON b.cod_universo = P.codice_prodotto
				AND (b.cod_linea = P.codice_linea
					OR (b.cod_linea IS NULL AND P.codice_linea IS NULL))
		INNER JOIN strumentofinanziario sf
			ON sf.codicetitolo = b.codicetitolo
		INNER JOIN RAPPORTO r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	WHERE sf.livello_2 in ('POLIZZE INDEX LINKED', 'POLIZZE UNIT LINKED', 'POLIZZE MULTIRAMO')
	AND NOT (codice_prodotto IN (
						SELECT codicetitolo
						FROM POLIZZE_SOTTOSTANTI) 
				 AND RAMO = '03')
	ORDER BY r.id, numero_polizza||'_'||codice_prodotto||'_'||ramo||'_'||tipo_liquidazione||'_'||data_valuta||'_'||codice_fiscale_beneficiario
				||'_'||data_comunicazione_pagamento||'_'||modalita_pagamento||'_'||codice_frazionamento;


I NUMBER(38,0):=0;


BEGIN
	
	FOR cur_item IN cerca_movmulti
    	LOOP
        I := I+1;

		MERGE INTO movimento mov
		  USING (SELECT cur_item.idrapporto          				AS idrapporto,
						cur_item.numreg              				AS numreg,
						cur_item.cambio              				AS cambio,
						cur_item.causale             				AS causale,
						cur_item.codicetitolo        				AS codicetitolo,
						cur_item.ctv       		     				AS ctv,
						cur_item.ctvnetto							AS ctvnetto,
						cur_item.ctvdivisa           				AS ctvdivisa,
                        cur_item.divisa           				    AS divisa,
                        cur_item.data                  				AS data,
                        cur_item.valuta                  			AS valuta,
						cur_item.c_procedura        				AS c_procedura,	
						cur_item.codice_prodotto_universo      		AS codice_prodotto_universo,
						cur_item.ramo  				       			AS ramo,
						cur_item.data_effetto_polizza  				AS data_effetto_polizza,
						cur_item.data_scadenza  					AS data_scadenza,
						cur_item.interesse_mora     				AS interesse_mora,
						cur_item.rit_interesse_mora      		    AS rit_interesse_mora,
						cur_item.costo_liquidazione					AS costo_liquidazione,
						cur_item.imposta_sostitutiva				AS imposta_sostitutiva,
						cur_item.imposta_bollo						AS imposta_bollo,
						cur_item.codice_fiscale_beneficiario		AS codice_fiscale_beneficiario,
						cur_item.data_comunicazione_pagamento		AS data_comunicazione_pagamento,
						cur_item.modalita_pagamento					AS modalita_pagamento,
						cur_item.codice_frazionamento 				AS codice_frazionamento,
						cur_item.data_competenza 					AS data_competenza
			FROM dual
			) tomerge
		  ON (mov.idrapporto = tomerge.idrapporto
		  	 AND mov.numreg = tomerge.numreg)
		   
	WHEN MATCHED THEN UPDATE
		  SET
		    mov.cambio = tomerge.cambio,
		    mov.causale = tomerge.causale,
		    mov.codicetitolo = tomerge.codicetitolo,
		    mov.ctv = tomerge.ctv,
		    mov.ctvnetto = tomerge.ctvnetto,
		    mov.ctvdivisa = tomerge.ctvdivisa,
		    mov.divisa = tomerge.divisa,
		    mov.data = tomerge.data,
		    mov.valuta = tomerge.valuta,
		    mov.c_procedura = tomerge.c_procedura,
		    mov.codice_prodotto_universo = tomerge.codice_prodotto_universo,
		    mov.ramo = tomerge.ramo,
		    mov.data_effetto_polizza = tomerge.data_effetto_polizza,
		    mov.data_scadenza = tomerge.data_scadenza,
		    mov.interesse_mora = tomerge.interesse_mora,
		    mov.rit_interesse_mora = tomerge.rit_interesse_mora,
		    mov.costo_liquidazione = tomerge.costo_liquidazione,
		    mov.imposta_sostitutiva = tomerge.imposta_sostitutiva,
		    mov.imposta_bollo = tomerge.imposta_bollo,
		    mov.codice_fiscale_beneficiario = tomerge.codice_fiscale_beneficiario,
		    mov.data_comunicazione_pagamento = tomerge.data_comunicazione_pagamento,
		    mov.modalita_pagamento = tomerge.modalita_pagamento,
		    mov.codice_frazionamento = tomerge.codice_frazionamento,
		    mov.data_competenza = tomerge.data_competenza
  	
	WHEN NOT MATCHED THEN 
			INSERT (idrapporto,
					numreg,
					cambio,
					causale,
					codicetitolo,
					ctv,
					ctvnetto,
					ctvdivisa,
					data,
					valuta,
					divisa,
					c_procedura,
					codice_prodotto_universo,
					ramo,
					data_effetto_polizza,
					data_scadenza,
					interesse_mora,
					rit_interesse_mora,
					costo_liquidazione,
					imposta_sostitutiva,
					imposta_bollo,
					codice_fiscale_beneficiario,
					data_comunicazione_pagamento,
					modalita_pagamento,
					codice_frazionamento,
					data_competenza
					
					)
  			VALUES (tomerge.idrapporto,
					tomerge.numreg,
					tomerge.cambio,
					tomerge.causale,
					tomerge.codicetitolo,
					tomerge.ctv,
					tomerge.ctvnetto,
					tomerge.ctvdivisa,
					tomerge.data,
					tomerge.valuta,
					tomerge.divisa,
					tomerge.c_procedura,
					tomerge.codice_prodotto_universo,
					tomerge.ramo,
					tomerge.data_effetto_polizza,
					tomerge.data_scadenza,
					tomerge.interesse_mora,
					tomerge.rit_interesse_mora,
					tomerge.costo_liquidazione,
					tomerge.imposta_sostitutiva,
					tomerge.imposta_bollo,
					tomerge.codice_fiscale_beneficiario,
					tomerge.data_comunicazione_pagamento,
					tomerge.modalita_pagamento,
					tomerge.codice_frazionamento,
					tomerge.data_competenza		
				);
 
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_PAG_COASS MULTIRAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_PAG_COASS MULTIRAMO - COMMIT ON ROW: ' || I);
	COMMIT;
	
END;