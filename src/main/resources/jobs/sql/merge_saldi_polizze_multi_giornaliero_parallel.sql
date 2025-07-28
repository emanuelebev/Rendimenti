SELECT sum(column_value)
FROM TABLE (PARALLEL_SALDI_POL_GIORN (CURSOR (

		SELECT	/*+ PARALLEL(8) */		
		MIN(R.idptf)																						AS idptf,
		'07601'																								AS codicebanca,
		MIN(sp.codiceagenzia)																				AS codicefiliale,
		lpad(TRIM(sp.codicerapporto),12,'0')																AS codicerapporto,
		CASE WHEN (b.codicetitolo IS NOT NULL AND sp.codiceinterno NOT IN (
					SELECT s.codicetitolo
					FROM POLIZZE_SOTTOSTANTI s)) THEN b.codicetitolo
             WHEN (b.codicetitolo IS NOT NULL AND sp.codiceinterno IN (
					SELECT s.codicetitolo
					FROM POLIZZE_SOTTOSTANTI s)) THEN b.codicetitolo || 'RI'
			ELSE sp.codiceinterno END																		AS codicetitolo,
		MIN(to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')))					AS "DATA",     
		SUM(sp.controvalore)/100																		    AS ctv,	
		NULL 																								AS ctvvaluta,
		to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD'))				 			AS dataaggiornamento,
		MIN(sp.divisa)																						AS divisa,
		MIN(sp.flagconsolidato)																				AS flag_consolidato,
		MIN(R.ID) 																							AS id_rapporto,
		MIN(sp.ctvversato) 																					AS ctv_versato,
		MIN(sp.ctvprelevato) 																				AS ctv_prelevato,
		MIN(sp.ctvversatonetto)																				AS ctv_versato_netto,
		MIN(sp.codiceinterno)																				AS codice_universo_pz,
		NULL																								AS ramo,
		NULL																								AS sottostante_pz,
		NULL																								AS data_saldo_nav_pz,
		MIN(sp.codiceinternomacroprodotto)																	AS linea_pz,
		MIN(sp.descrizionemacroprodotto)																	AS descr_linea_pz,
		TO_DATE(MIN(sp.datacompleannopolizza), 'YYYYMMDD')													AS data_compleanno_pz,
		'0'																									AS is_calc_costi_imp,
		SUM(sp.controvalore)/100																		    AS saldo_pol,
		'PZ' 																								AS tipo_pol	
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
		AND (b.codicetitolo IS NOT NULL OR sp.codiceinterno IN (   -- Tutte le ramo I con gestione separata 
        											SELECT cod_universo
                                                    FROM tbl_bridge
                                                    WHERE is_ramoI_gs = '1') 
                                        OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
		AND NOT (sp.codiceinterno IN (   --Tutte le polizze non premium più il ramo I delle polizze premium
						SELECT codicetitolo
						FROM POLIZZE_SOTTOSTANTI) 
				 AND RAMO = '03') 
        GROUP BY sp.codicerapporto, 
        CASE WHEN (b.codicetitolo IS NOT NULL AND sp.codiceinterno NOT IN (
					SELECT s.codicetitolo
					FROM POLIZZE_SOTTOSTANTI s)) THEN b.codicetitolo
             WHEN (b.codicetitolo IS NOT NULL AND sp.codiceinterno IN (
					SELECT s.codicetitolo
					FROM POLIZZE_SOTTOSTANTI s)) THEN b.codicetitolo || 'RI'
			ELSE sp.codiceinterno END, 
        b.codicetitolo, 
        sp.codiceinterno,
        to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD'))
		ORDER BY idptf, codicetitolo, data
)));