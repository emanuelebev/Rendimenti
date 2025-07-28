SELECT sum(column_value)
FROM TABLE (PARALLEL_SALDI_POL_RECUP (CURSOR (

	SELECT	/*+ PARALLEL(8) */	 
		R.idptf																								AS idptf,
		'07601'																								AS codicebanca,
		R.codiceagenzia 																					AS codicefiliale,
		LPAD(trim(sp.codicerapporto),12,'0')																AS codicerapporto,
		sp.codiceinterno																				    AS codicetitolo,
		to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')) 						AS "DATA",	
		sp.controvalore/100																					AS ctv,		
		NULL 																								AS ctvvaluta,
		to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')) 						AS dataaggiornamento,
		sp.divisa 																							AS divisa,
		sp.flagconsolidato 																					AS flag_consolidato,
		R.ID 																								AS id_rapporto,
		sp.ctvversato 																						AS ctv_versato,
		sp.ctvprelevato 																					AS ctv_prelevato,
		sp.ctvversatonetto																					AS ctv_versato_netto,
		sp.codiceinterno																					AS codice_universo_pz,
		sp.ramo																								AS ramo,
		sp.fondo																							AS sottostante_pz,
		TO_DATE( sp.datasaldo, 'YYYY-MM-DD' )																AS data_saldo_nav_pz,
		sp.codiceinternomacroprodotto																		AS linea_pz,
		sp.descrizionemacroprodotto																			AS descr_linea_pz,
		TO_DATE(sp.datacompleannopolizza, 'YYYYMMDD') 														AS data_compleanno_pz,
		'1'																									AS is_calc_costi_imp,
		sp.controvalore/100																					AS saldo_pol	
	FROM TMP_PFSALPOL_RECUP sp
		LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		INNER JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		INNER JOIN rapporto R
			ON R.codicerapporto = LPAD(trim(sp.codicerapporto),12,'0')
			AND R.tipo = '13'
		WHERE b.codicetitolo IS NULL
		AND sp.flagesclusione = '0'
		AND sf.livello_2 = 'POLIZZE RAMO I'
		AND sp.codiceinterno NOT IN (
        		SELECT cod_universo
                FROM tbl_bridge
                WHERE is_ramoI_gs = '1') -- escludo le ramo I con gestione separata
	ORDER BY idptf, codicetitolo, data
)));