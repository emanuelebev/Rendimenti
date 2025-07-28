DECLARE

--Movimenti polizze monoramo
CURSOR cerca_movmono IS 
	SELECT 	/*+ PARALLEL(8) */	  
			r.id																												AS idrapporto,
			numero_polizza||'_'||codice_prodotto||'_'||ramo||'_'||tipo_titolo||'_'||data_valuta||'_'||codice_motivo_storno
				||'_'||data_carico||'_'||data_competenza||'_'||data_effetto_titolo												AS numreg,
			1																													AS cambio,
			r.tipo || '_' || tipo_titolo																						AS causale,
			codice_prodotto																										AS codicetitolo,
			premio_lordo_coass 																									AS ctv,
			premio_lordo_coass																									AS ctvdivisa,
			CASE WHEN (tipo_titolo IN ('01', '02') AND 
			TO_NUMBER(TO_CHAR(TO_DATE(data_effetto_titolo, 'YYYY-MM-DD'), 'YYYYMMDD')) < TO_NUMBER(TO_CHAR(TO_DATE(data_valuta, 'YYYY-MM-DD'), 'YYYYMMDD'))	)
				THEN LEAST(TO_NUMBER(TO_CHAR(TO_DATE(data_valuta, 'YYYY-MM-DD'), 'YYYYMMDD')), TO_NUMBER(TO_CHAR(TO_DATE(data_effetto_titolo, 'YYYY-MM-DD'), 'YYYYMMDD')))
				ELSE TO_NUMBER(TO_CHAR(TO_DATE(data_valuta, 'YYYY-MM-DD'), 'YYYYMMDD')) END										AS data,
			TO_NUMBER(TO_CHAR(TO_DATE(data_valuta, 'YYYY-MM-DD'), 'YYYYMMDD'))													AS valuta,
			'EUR' 																												AS divisa,
			imposte_coass																										AS tassazione,
			'13' 																												AS c_procedura,
			codice_prodotto																										AS codice_prodotto_universo, 
			ramo																												AS ramo,
			TO_DATE(data_effetto_titolo, 'YYYYMMDD')																			AS data_effetto_titolo,
			TO_DATE(data_effetto_polizza, 'YYYYMMDD')																			AS data_effetto_polizza,
			CASE WHEN data_scadenza = '00000000' THEN NULL ELSE TO_DATE(data_scadenza, 'YYYYMMDD') END							AS data_scadenza,
			premio_netto																										AS premio_netto,
			premio_puro																											AS premio_puro,
			premio_imponibile																									AS premio_imponibile,
			caricamento_coass																									AS caricamento_ori,
			diritto_fisso_coass																									AS diritto_fisso,
			provvigioni_di_acquisto_coass																						AS provvigioni_di_acquisto_ori,
			provvigioni_di_incasso_coass																						AS provvigioni_di_incasso_ori,
			TO_DATE(data_carico, 'YYYYMMDD')																					AS data_carico,
			interesse_mora_coass																								AS interesse_mora,
			ritenuta_interesse_mora_coass																						AS rit_interesse_mora,
			codice_motivo_storno																								AS cod_motivostorno_pz,
			data_competenza																										AS data_competenza,			
			CASE WHEN provvigioni_di_incasso_coass > 0 THEN (caricamento_coass - LEAST(caricamento_coass, provvigioni_di_incasso_coass))
				 WHEN provvigioni_di_acquisto_coass > 0 THEN (caricamento_coass - LEAST(caricamento_coass, provvigioni_di_acquisto_coass))
				 WHEN provvigioni_di_incasso_coass < 0 THEN (caricamento_coass - GREATEST(caricamento_coass, provvigioni_di_incasso_coass))
				 WHEN provvigioni_di_acquisto_coass < 0 THEN (caricamento_coass - GREATEST(caricamento_coass, provvigioni_di_acquisto_coass))
				 WHEN (provvigioni_di_incasso_coass = 0 AND provvigioni_di_acquisto_coass = 0) 
				 		THEN caricamento_coass END	 	 	   																		AS caricamento,	 
			CASE WHEN provvigioni_di_acquisto_coass > 0 THEN LEAST(caricamento_coass, provvigioni_di_acquisto_coass) 
				 WHEN provvigioni_di_acquisto_coass < 0 THEN GREATEST(caricamento_coass, provvigioni_di_acquisto_coass)
						ELSE provvigioni_di_acquisto_coass END 																		AS provv_acquisto,			
			CASE WHEN provvigioni_di_incasso_coass > 0 THEN LEAST(caricamento_coass, provvigioni_di_incasso_coass) 
				 WHEN provvigioni_di_incasso_coass < 0 THEN GREATEST(caricamento_coass, provvigioni_di_incasso_coass)
						ELSE provvigioni_di_incasso_coass END 																		AS provv_incasso,
			costo_compagnia																											AS altri_costi
	FROM TMP_PFMOV_INC_COASS P
		LEFT JOIN (
        	SELECT codicetitolo, cod_universo, is_ramoI_gs, MIN(ROWID) AS min_rowid
            FROM tbl_bridge
         	GROUP BY codicetitolo, cod_universo, is_ramoI_gs
        ) b
			ON b.cod_universo = P.codice_prodotto
		INNER JOIN strumentofinanziario sf
			ON sf.codicetitolo = P.codice_prodotto
		INNER JOIN rapporto R
			ON R.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND R.tipo = '13'
	WHERE (b.codicetitolo IS NULL OR b.is_ramoI_gs = '1') -- includo le ramo I con gestione separata
	and sf.livello_2 = 'POLIZZE RAMO I'
	ORDER BY r.id, numero_polizza||'_'||codice_prodotto||'_'||ramo||'_'||tipo_titolo||'_'||data_valuta||'_'||codice_motivo_storno
				||'_'||data_carico||'_'||data_competenza||'_'||data_effetto_titolo;

I NUMBER(38,0):=0;


BEGIN
	
 FOR cur_item IN cerca_movmono
    LOOP
        I := I+1;

		MERGE INTO movimento mov
		  USING (SELECT cur_item.idrapporto          				AS idrapporto,
						cur_item.numreg              				AS numreg,
						cur_item.cambio              				AS cambio,
						cur_item.causale             				AS causale,
						cur_item.codicetitolo        				AS codicetitolo,
						cur_item.ctv       		     				AS ctv,
						cur_item.ctvdivisa           				AS ctvdivisa,
                        cur_item.divisa       					    AS divisa,
                        cur_item.data       					    AS data,
                        cur_item.valuta       					    AS valuta,
						cur_item.tassazione       					AS tassazione,
						cur_item.c_procedura        				AS c_procedura,	
						cur_item.codice_prodotto_universo      		AS codice_prodotto_universo,
						cur_item.ramo  				       			AS ramo,
						cur_item.data_effetto_titolo         		AS data_effetto_titolo,
						cur_item.data_effetto_polizza  				AS data_effetto_polizza,
						cur_item.data_scadenza  					AS data_scadenza,
						cur_item.premio_netto 						AS premio_netto,
						cur_item.premio_puro      					AS premio_puro,
						cur_item.premio_imponibile 					AS premio_imponibile,
						cur_item.caricamento_ori       				AS caricamento_ori,
						cur_item.diritto_fisso            			AS diritto_fisso,
						cur_item.provvigioni_di_acquisto_ori        AS provvigioni_di_acquisto_ori,
						cur_item.provvigioni_di_incasso_ori         AS provvigioni_di_incasso_ori,
						cur_item.data_carico  						AS data_carico,
						cur_item.interesse_mora     				AS interesse_mora,
						cur_item.rit_interesse_mora      		    AS rit_interesse_mora,
						cur_item.cod_motivostorno_pz				AS cod_motivostorno_pz,
						cur_item.data_competenza					AS data_competenza,
						cur_item.caricamento						AS caricamento,
						cur_item.provv_acquisto						AS provv_acquisto,
						cur_item.provv_incasso						AS provv_incasso,
						cur_item.altri_costi						AS altri_costi
						
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
		    mov.ctvdivisa = tomerge.ctvdivisa,
		    mov.divisa = tomerge.divisa,
		    mov.data = tomerge.data,
		    mov.valuta = tomerge.valuta,
		    mov.tassazione = tomerge.tassazione,
		    mov.c_procedura = tomerge.c_procedura,
		    mov.codice_prodotto_universo = tomerge.codice_prodotto_universo,
		    mov.ramo = tomerge.ramo,
		    mov.data_effetto_titolo = tomerge.data_effetto_titolo,
		    mov.data_effetto_polizza = tomerge.data_effetto_polizza,
		    mov.data_scadenza = tomerge.data_scadenza,
		    mov.premio_netto = tomerge.premio_netto,
		    mov.premio_puro = tomerge.premio_puro,
		    mov.premio_imponibile = tomerge.premio_imponibile,
		    mov.caricamento_ori = tomerge.caricamento_ori,
		    mov.diritto_fisso = tomerge.diritto_fisso,		    
		    mov.provvigioni_di_acquisto_ori = tomerge.provvigioni_di_acquisto_ori,
		    mov.provvigioni_di_incasso_ori = tomerge.provvigioni_di_incasso_ori,
		    mov.data_carico = tomerge.data_carico,
		    mov.interesse_mora = tomerge.interesse_mora,
		    mov.rit_interesse_mora = tomerge.rit_interesse_mora,
		    mov.cod_motivostorno_pz = tomerge.cod_motivostorno_pz,
		    mov.data_competenza = tomerge.data_competenza,
		    mov.caricamento = tomerge.caricamento,
		    mov.provv_acquisto = tomerge.provv_acquisto,
		    mov.provv_incasso = tomerge.provv_incasso,
		    mov.altri_costi = tomerge.altri_costi
  	
	WHEN NOT MATCHED THEN 
			INSERT (idrapporto,
					numreg,
					cambio,
					causale,
					codicetitolo,
					ctv,
					ctvdivisa,
					data,
					valuta,
					divisa,
					tassazione,
					c_procedura,
					codice_prodotto_universo,
					ramo,
					data_effetto_titolo,
					data_effetto_polizza,
					data_scadenza,
					premio_netto,
					premio_puro,
					premio_imponibile,
					caricamento_ori,
					diritto_fisso,
					provvigioni_di_acquisto_ori,
					provvigioni_di_incasso_ori,
					data_carico,
					interesse_mora,
					rit_interesse_mora,
					cod_motivostorno_pz,
					data_competenza,
					caricamento,
					provv_acquisto,
					provv_incasso,
					altri_costi
					)
  			VALUES (tomerge.idrapporto,
					tomerge.numreg,
					tomerge.cambio,
					tomerge.causale,
					tomerge.codicetitolo,
					tomerge.ctv,
					tomerge.ctvdivisa,
					tomerge.data,
					tomerge.valuta,
					tomerge.divisa,
					tomerge.tassazione,
					tomerge.c_procedura,
					tomerge.codice_prodotto_universo,
					tomerge.ramo,
					tomerge.data_effetto_titolo,
					tomerge.data_effetto_polizza,
					tomerge.data_scadenza,
					tomerge.premio_netto,
					tomerge.premio_puro,
					tomerge.premio_imponibile,
					tomerge.caricamento_ori,
					tomerge.diritto_fisso,
					tomerge.provvigioni_di_acquisto_ori,
					tomerge.provvigioni_di_incasso_ori,
					tomerge.data_carico,
					tomerge.interesse_mora,
					tomerge.rit_interesse_mora,
					tomerge.cod_motivostorno_pz,
					tomerge.data_competenza,
					tomerge.caricamento,
					tomerge.provv_acquisto,
					tomerge.provv_incasso,
					tomerge.altri_costi
				);
				
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_INC_COASS MONORAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_INC_COASS MONORAMO - COMMIT ON ROW: ' || I);
	COMMIT;
	
END;