--Solo per le polizze sottostanti multiramo

DECLARE

CURSOR rend_sott IS 
	SELECT 	DISTINCT 
			R.idptf																								AS idptf,
			'07061'																								AS codicebanca,
			sp.codiceagenzia 																					AS codicefiliale,
			LPAD(trim(sp.codicerapporto),12,'0')																AS codicerapporto,
			--r.id || '_' || SP.codiceinterno || '_' || sp.ramo || '_' || sp.fondo || '_' || SP.datasaldo			AS codicetitolo,
			CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
				ELSE sp.codiceinterno END																		AS codicetitolo,
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
    		'1'																									AS is_calc_costi_imp
    	FROM TMP_PFSALPOL_RECUP sp
		LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		INNER JOIN rapporto R
			ON R.codicerapporto = LPAD(trim(sp.codicerapporto),12,'0')
			AND R.tipo = '13'
	WHERE  sp.flagesclusione = '0'
	AND (sp.codicerapporto, CASE WHEN B.CODICETITOLO IS NOT NULL THEN  B.CODICETITOLO
					ELSE SP.CODICEINTERNO END, sp.dataaggiornamento, sp.ramo, sp.fondo) IN ( --multiramo o monoramo ramo III
			SELECT sp.codicerapporto, 
				   CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
					ELSE sp.codiceinterno END, 
				   sp.dataaggiornamento, 
				   sp.ramo, 
				   sp.fondo
			FROM TMP_PFSALPOL_RECUP sp
			LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
			WHERE  sp.flagesclusione = '0'
	AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
	GROUP BY sp.codicerapporto, 
			 CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
					ELSE sp.codiceinterno END, 
			 sp.dataaggiornamento, 
			 sp.ramo, 
			 sp.fondo);
      
I NUMBER(38,0):=0;


BEGIN
	
 FOR cur_item IN rend_sott
    LOOP
        I := I+1;

		MERGE 
			INTO saldo_rend_sott sott
	 	 USING (SELECT 	cur_item.idptf         						AS idptf,
	 	 				cur_item.codicebanca         				AS codicebanca,
		  				cur_item.codicefiliale 						AS codicefiliale,
					    cur_item.codicerapporto 					AS codicerapporto,
					    cur_item.codicetitolo						AS codicetitolo,
					    cur_item.DATA								AS DATA,
					    cur_item.ctv 								AS ctv,
					    cur_item.ctvvaluta 							AS ctvvaluta,
					    cur_item.dataaggiornamento 					AS dataaggiornamento,
					    cur_item.divisa 							AS divisa,
					    cur_item.flag_consolidato 					AS flag_consolidato,
					    cur_item.id_rapporto 						AS id_rapporto,
					    cur_item.ctv_versato 						AS ctv_versato,
					    cur_item.ctv_prelevato 						AS ctv_prelevato,
					    cur_item.ctv_versato_netto 					AS ctv_versato_netto,
					    cur_item.codice_universo_pz 				AS codice_universo_pz,
					    cur_item.ramo 								AS ramo,
					    cur_item.sottostante_pz 					AS sottostante_pz,
					    cur_item.data_saldo_nav_pz 					AS data_saldo_nav_pz,
					    cur_item.linea_pz 							AS linea_pz,
					    cur_item.descr_linea_pz 					AS descr_linea_pz,
					    cur_item.data_compleanno_pz					AS data_compleanno_pz,
					    cur_item.is_calc_costi_imp					AS is_calc_costi_imp
			FROM dual
			) tomerge
		  ON (sott.codicetitolo = tomerge.codicetitolo
		  	 AND sott.idptf = tomerge.idptf
		  	 AND sott.DATA = tomerge.DATA
		  	 AND sott.ramo = tomerge.ramo
		  	 AND sott.sottostante_pz = tomerge.sottostante_pz)
		   
	WHEN MATCHED THEN UPDATE
		  SET
		    sott.codicebanca = tomerge.codicebanca,
		    sott.codicefiliale = tomerge.codicefiliale,
		    sott.codicerapporto = tomerge.codicerapporto,
		    sott.ctv = tomerge.ctv,
		    sott.ctvvaluta = tomerge.ctvvaluta,
		    sott.dataaggiornamento = tomerge.dataaggiornamento,
		    sott.flag_consolidato = tomerge.flag_consolidato,
		    sott.id_rapporto = tomerge.id_rapporto,
		    sott.ctv_versato = tomerge.ctv_versato,
		    sott.ctv_prelevato = tomerge.ctv_prelevato,
		    sott.ctv_versato_netto = tomerge.ctv_versato_netto,
		    sott.codice_universo_pz = tomerge.codice_universo_pz,
		    sott.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
		    sott.linea_pz = tomerge.linea_pz,
		    sott.descr_linea_pz = tomerge.descr_linea_pz,
		    sott.data_compleanno_pz = tomerge.data_compleanno_pz,
		    sott.is_calc_costi_imp = tomerge.is_calc_costi_imp  
  	
	WHEN NOT MATCHED THEN 
			INSERT (idptf,
				    codicebanca,
				    codicefiliale,
				    codicerapporto,
				    codicetitolo,
				    DATA,
				    ctv,
				    ctvvaluta,
				    dataaggiornamento,
				    divisa,
				    flag_consolidato,
				    id_rapporto,
				    ctv_versato,
				    ctv_prelevato,
				    ctv_versato_netto,
				    codice_universo_pz,
				    ramo,
				    sottostante_pz,
				    data_saldo_nav_pz,
				    linea_pz,
				    descr_linea_pz,
				    data_compleanno_pz,
				    is_calc_costi_imp
					)
  			VALUES (tomerge.idptf,
				    tomerge.codicebanca,
				    tomerge.codicefiliale,
				    tomerge.codicerapporto,
				    tomerge.codicetitolo,
				    tomerge.DATA,
				    tomerge.ctv,
				    tomerge.ctvvaluta,
				    tomerge.dataaggiornamento,
				    tomerge.divisa,
				    tomerge.flag_consolidato,
				    tomerge.id_rapporto,
				    tomerge.ctv_versato,
				    tomerge.ctv_prelevato,
				    tomerge.ctv_versato_netto,
				    tomerge.codice_universo_pz,
				    tomerge.ramo,
				    tomerge.sottostante_pz,
				    tomerge.data_saldo_nav_pz,
				    tomerge.linea_pz,
				    tomerge.descr_linea_pz,
				    tomerge.data_compleanno_pz,
				    tomerge.is_calc_costi_imp
					);
				
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT - COMMIT ON ROW: ' || I);
	COMMIT;
END;