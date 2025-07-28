SELECT sum(column_value)
FROM TABLE (PARALLEL_SALDI_REND_SOTT_GIORN (CURSOR (

	    SELECT	/*+ PARALLEL (4) */	DISTINCT 
			R.idptf																								AS idptf,
			'07061'																								AS codicebanca,
			sp.codiceagenzia 																					AS codicefiliale,
			lpad(TRIM(sp.codicerapporto),12,'0')																AS codicerapporto,
			CASE WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '01') THEN b.codicetitolo || 'RI'
            WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '03') THEN b.codicetitolo || 'RIII'
            ELSE sp.codiceinterno END										                                    AS codicetitolo,
			to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD'), 'YYYYMMDD')) 							AS DATA,
			(sp.controvalore)/100																				AS ctv,
			NULL 																								AS ctvvaluta,
			to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD'), 'YYYYMMDD')) 							AS dataaggiornamento,
			'EUR'																								AS divisa,
			sp.flagconsolidato																					AS flag_consolidato,
			R.ID																								AS id_rapporto,
			sp.ctvversato																						AS ctv_versato,
			sp.ctvprelevato																						AS ctv_prelevato,
			sp.ctvversatonetto																					AS ctv_versato_netto,
			sp.codiceinterno																					AS codice_universo_pz,
			sp.ramo																								AS ramo,
			sp.fondo																							AS sottostante_pz,
			TO_DATE(sp.datasaldo, 'YYYYMMDD')																	AS data_saldo_nav_pz,
			sp.codiceinternomacroprodotto																		AS linea_pz,
  			sp.descrizionemacroprodotto																			AS descr_linea_pz,
    		TO_DATE(sp.datacompleannopolizza, 'YYYYMMDD')														AS data_compleanno_pz,
    		'1'																									AS is_calc_costi_imp,
    		numero_quote /100000																				AS numero_quote,
    		nav/100																								AS nav,
    		cod_tipo_attivita																					AS cod_tipo_attivita
    	FROM tmp_pfsaldi_polizze sp
		LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		INNER JOIN rapporto R
			ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
			AND R.tipo = '13'
	WHERE  sp.flagesclusione = '0'
	AND sp.codiceinterno IN (
		SELECT codicetitolo
		FROM POLIZZE_SOTTOSTANTI)
	AND (sp.codicerapporto, 
			CASE WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '01') THEN b.codicetitolo || 'RI'
            WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '03') THEN b.codicetitolo || 'RIII'
            ELSE sp.codiceinterno END,	 
          sp.dataaggiornamento, 
          sp.ramo, 
          sp.fondo) IN 
          	( --multiramo o monoramo ramo III
			SELECT sp.codicerapporto, 
			CASE WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '01') THEN b.codicetitolo || 'RI'
            WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '03') THEN b.codicetitolo || 'RIII'
            ELSE sp.codiceinterno END, 
				   sp.dataaggiornamento, 
				   sp.ramo, 
				   sp.fondo
			FROM tmp_pfsaldi_polizze sp
			LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
			WHERE sp.flagesclusione = '0'
			AND sp.codiceinterno IN (
				SELECT codicetitolo
				FROM POLIZZE_SOTTOSTANTI)            
	AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
	GROUP BY sp.codicerapporto, 
            CASE WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '01') THEN b.codicetitolo || 'RI'
            WHEN (b.codicetitolo IS NOT NULL AND sp.ramo = '03') THEN b.codicetitolo || 'RIII'
            ELSE sp.codiceinterno END, 
				 sp.dataaggiornamento, 
				 sp.ramo, 
				 sp.fondo)
)));