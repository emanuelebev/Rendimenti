--Controllo sul cambio settimana e sul cambio mese 

DECLARE 

	rowcounts 		NUMBER;
	maxyearweek 	NUMBER;
	maxyearweeksp 	NUMBER;
	maxyearmonth 	NUMBER;
	maxyearmonthsp 	NUMBER;
	t1 				NUMBER;
	t1m 			NUMBER;
		
	ROWS    		PLS_INTEGER := 10000;
	I 				NUMBER(38,0):=0;
	totale			NUMBER(38,0):=0; 
	CNT				NUMBER(38,0):=0;
	CNT_SP			NUMBER(38,0):=0;


--Partizioni da tronacre
	CURSOR weeks_retent IS
	      SELECT DISTINCT yearweek +1 AS yearweek
	      FROM saldo_rend_polizze
	      WHERE yearweek < t1;
	      
	CURSOR weeks_retent_sott IS
	      SELECT DISTINCT yearweek +1 AS yearweek
	      FROM saldo_rend_sott_pol
	      WHERE yearweek < t1;

--Saldi polizze monoramo
	CURSOR salpo_mono IS
		SELECT
			R.idptf																								AS idptf,
			'07601'																								AS codicebanca,
			R.codiceagenzia 																					AS codicefiliale,
			lpad(TRIM(sp.codicerapporto),12,'0')																AS codicerapporto,
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
		FROM tmp_pfsaldi_polizze sp
			LEFT JOIN tbl_bridge b
				ON b.cod_universo = sp.codiceinterno
					AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
						(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
			INNER JOIN strumentofinanziario sf
				ON sf.codicetitolo = sp.codiceinterno
			INNER JOIN rapporto R
				ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
				AND R.tipo = '13'
			WHERE b.codicetitolo IS NULL
			AND sp.flagesclusione = '0'
			AND sf.livello_2 = 'POLIZZE RAMO I'; 
	
		
--Saldi polizze multiramo	
	CURSOR salpo_multi IS
		SELECT
			MIN(R.idptf)																						AS idptf,
			'07601'																								AS codicebanca,
			MIN(sp.codiceagenzia)																				AS codicefiliale,
			lpad(TRIM(sp.codicerapporto),12,'0')																AS codicerapporto,
			CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
				ELSE sp.codiceinterno END																		AS codicetitolo,
			MIN(to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')))					AS "DATA",
			SUM(sp.controvalore)/100																			AS ctv,		
			NULL 																								AS ctvvaluta,
			to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD'))				 			AS dataaggiornamento,
			MIN(sp.divisa)																						AS divisa,
			MIN(sp.flagconsolidato)																				AS flag_consolidato,
			MIN(R.ID) 																							AS id_rapporto,
			MIN(ctvversato) 																					AS ctv_versato,
			MIN(ctvprelevato) 																					AS ctv_prelevato,
			MIN(ctvversatonetto)																				AS ctv_versato_netto,
			MIN(sp.codiceinterno)																				AS codice_universo_pz,
			NULL																								AS ramo,
			NULL																								AS sottostante_pz,
			NULL																								AS data_saldo_nav_pz,
			MIN(sp.codiceinternomacroprodotto)																	AS linea_pz,
			MIN(sp.descrizionemacroprodotto)																	AS descr_linea_pz,
			TO_DATE(MIN(sp.datacompleannopolizza), 'YYYYMMDD')													AS data_compleanno_pz,
			'0'																									AS is_calc_costi_imp,
			SUM(sp.controvalore)/100																			AS saldo_pol		
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
		AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
		GROUP BY sp.codicerapporto, 
				 CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
						ELSE sp.codiceinterno END, 
				 sp.dataaggiornamento;


--Saldi polizze sp monoramo
	CURSOR salpo_sp_mono IS
		SELECT
			R.idptf																								AS idptf,
			'07601'																								AS codicebanca,
			R.codiceagenzia 																					AS codicefiliale,
			lpad(TRIM(sp.codicerapporto),12,'0')																AS codicerapporto,
			sp.codiceinterno																				    AS codicetitolo,
			to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')) 						AS "DATA", 			
			sp.controvalore 																					AS ctv,		
			NULL 																								AS ctvvaluta,
			to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')) 						AS dataaggiornamento,
			sp.divisa 																							AS divisa,
			sp.flagconsolidato 																					AS flag_consolidato,
			R.ID 																								AS id_rapporto,
			sp.ctvversato																						AS ctv_versato,
			sp.ctvprelevato																						AS ctv_prelevato,
			sp.ctvversatonetto																					AS ctv_versato_netto,
			sp.codiceinterno																					AS codice_universo_pz,
			sp.ramo																								AS ramo,
			sp.fondo																							AS sottostante_pz,
			TO_DATE( sp.datasaldo, 'YYYY-MM-DD' )																AS data_saldo_nav_pz,
			sp.codiceinternomacroprodotto																		AS linea_pz,
			sp.descrizionemacroprodotto																			AS descr_linea_pz,
			TO_DATE(sp.datacompleannopolizza, 'YYYYMMDD') 														AS data_compleanno_pz,
			'1'																									AS is_calc_costi_imp,
			sp.controvalore																						AS saldo_pol_sp	
		FROM tmp_pfsaldi_polizze_sp sp
			LEFT JOIN tbl_bridge b
				ON b.cod_universo = sp.codiceinterno
					AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
						(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
			INNER JOIN strumentofinanziario sf
				ON sf.codicetitolo = sp.codiceinterno
			INNER JOIN rapporto R
				ON R.codicerapporto = lpad(TRIM(sp.codicerapporto),12,'0')
				AND R.tipo = '13'
			WHERE b.codicetitolo IS NULL
			AND sp.flagesclusione = '0'
			AND sf.livello_2 = 'POLIZZE RAMO I'; 

	
--Saldi polizze sp multiramo	
	CURSOR salpo_sp_multi IS
		SELECT
			MIN(R.idptf)																						AS idptf,
			'07601'																								AS codicebanca,
			MIN(sp.codiceagenzia)																				AS codicefiliale,
			lpad(TRIM(sp.codicerapporto),12,'0')																AS codicerapporto,
			CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
				ELSE sp.codiceinterno END																		AS codicetitolo,
			MIN(to_number(to_char( TO_DATE(sp.dataaggiornamento, 'YYYYMMDD' ), 'YYYYMMDD')))					AS "DATA",     
			SUM(sp.controvalore) 																			    AS ctv,	
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
			SUM(sp.controvalore) 																			    AS saldo_pol_sp
		FROM tmp_pfsaldi_polizze_sp sp
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
		AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
		GROUP BY sp.codicerapporto, 
				 CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
						ELSE sp.codiceinterno END, 
				 sp.dataaggiornamento;

			 
--Solo per le polizze sottostanti multiramo
	CURSOR rend_sott IS 
		SELECT 	DISTINCT 
				R.idptf																								AS idptf,
				'07061'																								AS codicebanca,
				sp.codiceagenzia 																					AS codicefiliale,
				lpad(TRIM(sp.codicerapporto),12,'0')																AS codicerapporto,
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
		AND (sp.codicerapporto, CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
						ELSE sp.codiceinterno END, sp.dataaggiornamento, sp.ramo, sp.fondo) IN ( --multiramo o monoramo ramo III
				SELECT sp.codicerapporto, 
					   CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
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
				WHERE  sp.flagesclusione = '0'
		AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
		GROUP BY sp.codicerapporto, 
				 CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
						ELSE sp.codiceinterno END, 
				 sp.dataaggiornamento, 
				 sp.ramo, 
				 sp.fondo);


	TYPE salpo_mono_type IS TABLE OF salpo_mono%rowtype INDEX BY PLS_INTEGER;
	TYPE salpo_multi_type IS TABLE OF salpo_multi%rowtype INDEX BY PLS_INTEGER;
		
	res_salpo_mono salpo_mono_type;
	res_salpo_multi salpo_multi_type;
	
	TYPE salpo_sp_mono_type IS TABLE OF salpo_sp_mono%rowtype INDEX BY PLS_INTEGER;
	TYPE salpo_sp_multi_type IS TABLE OF salpo_sp_multi%rowtype INDEX BY PLS_INTEGER;
		
	res_salpo_sp_mono salpo_sp_mono_type;
	res_salpo_sp_multi salpo_sp_multi_type;


BEGIN
	
	SELECT MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), to_char(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW')))) 
    INTO maxyearweek
    FROM tmp_pfsaldi_polizze;
    
    SELECT MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0'))))
    INTO maxyearmonth
    FROM tmp_pfsaldi_polizze;
    
    SELECT MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), to_char(TO_DATE(dataaggiornamento, 'YYYYMMDD'), 'IW')))) 
    INTO maxyearweeksp
    FROM tmp_pfsaldi_polizze_sp;
    
    SELECT MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0'))))
    INTO maxyearmonthsp
    FROM tmp_pfsaldi_polizze_sp;

	SELECT nvl(MAX(yearweek), 0)
	INTO t1
	FROM saldo_rend_polizze;
  
    SELECT nvl(MAX(to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0')))),0) as yeawmonth
	INTO t1m
    FROM saldo_rend_polizze;
    
    SELECT COUNT(*) INTO CNT FROM tmp_pfsaldi_polizze;
    SELECT COUNT(*) INTO CNT_SP FROM tmp_pfsaldi_polizze_sp;

	IF (CNT >= 1000000 OR CNT_SP >= 1000000) THEN
	
		EXECUTE IMMEDIATE 'ALTER TABLE RENDIMPC.SALDO_REND NOLOGGING';
		EXECUTE IMMEDIATE 'ALTER TABLE RENDIMPC.SALDO_REND DISABLE CONSTRAINT FK_SALDO_REND_PORTAFOGLIO';
		EXECUTE IMMEDIATE 'ALTER TABLE RENDIMPC.SALDO_REND DISABLE CONSTRAINT FK_SALDO_REND_STRUMENTOFINANZI';
	    EXECUTE IMMEDIATE 'ALTER INDEX RENDIMPC.IDX_SALDO_REND_PK NOLOGGING';
	    
	END IF;
    
   --Carico delle SALDO_REND_POLIZZE e SALDO_REND_SOTT_POL

OPEN salpo_mono; --Saldi polizze monoramo
		LOOP
			FETCH salpo_mono BULK COLLECT INTO res_salpo_mono LIMIT ROWS;
				EXIT WHEN res_salpo_mono.COUNT = 0;  
			
			I:=0;
			I:= res_salpo_mono.COUNT;
			totale := totale + I;
				
		FORALL j IN res_salpo_mono.FIRST .. res_salpo_mono.LAST		

		MERGE INTO saldo_rend_polizze sr
		  USING (SELECT res_salpo_mono(j).idptf 				AS idptf,
						res_salpo_mono(j).codicebanca		 	AS codicebanca,
						res_salpo_mono(j).codicefiliale		 	AS codicefiliale,
						res_salpo_mono(j).codicerapporto 	 	AS codicerapporto,
						res_salpo_mono(j).codicetitolo		 	AS codicetitolo,
						res_salpo_mono(j)."DATA"				AS "DATA",
						res_salpo_mono(j).ctv					AS ctv,		
						res_salpo_mono(j).ctvvaluta			 	AS ctvvaluta,
						res_salpo_mono(j).dataaggiornamento	 	AS dataaggiornamento,
						res_salpo_mono(j).divisa				AS divisa,
						res_salpo_mono(j).flag_consolidato	 	AS flag_consolidato,
						res_salpo_mono(j).id_rapporto		 	AS id_rapporto,
						res_salpo_mono(j).ctv_versato		 	AS ctv_versato,
						res_salpo_mono(j).ctv_prelevato		 	AS ctv_prelevato,
						res_salpo_mono(j).ctv_versato_netto	 	AS ctv_versato_netto,
						res_salpo_mono(j).codice_universo_pz  	AS codice_universo_pz,
						res_salpo_mono(j).ramo 				 	AS ramo,
						res_salpo_mono(j).sottostante_pz		AS sottostante_pz,
						res_salpo_mono(j).data_saldo_nav_pz   	AS data_saldo_nav_pz,
						res_salpo_mono(j).linea_pz			 	AS linea_pz,
						res_salpo_mono(j).descr_linea_pz		AS descr_linea_pz,
						res_salpo_mono(j).data_compleanno_pz 	AS data_compleanno_pz,
						res_salpo_mono(j).is_calc_costi_imp   	AS is_calc_costi_imp,
						res_salpo_mono(j).saldo_pol 			AS saldo_pol,
                        'PZ'                                    AS tipo_pol
				FROM dual
			) tomerge
			 ON (sr.idptf = tomerge.idptf
			  	 AND sr.codicetitolo = tomerge.codicetitolo
			  	 AND sr."DATA" = tomerge."DATA")

		WHEN MATCHED THEN UPDATE
				  SET sr.codicebanca = tomerge.codicebanca,
					sr.codicefiliale = tomerge.codicefiliale,
					sr.codicerapporto = tomerge.codicerapporto,
					sr.ctv = nvl(sr.saldo_pol_sp,0) + tomerge.ctv,
					sr.ctvvaluta = tomerge.ctvvaluta,
					sr.dataaggiornamento = tomerge.dataaggiornamento,
					sr.divisa = tomerge.divisa,
					sr.flag_consolidato = tomerge.flag_consolidato,
					sr.id_rapporto = tomerge.id_rapporto,
					sr.ctv_versato = tomerge.ctv_versato,
					sr.ctv_prelevato = tomerge.ctv_prelevato,
					sr.ctv_versato_netto = tomerge.ctv_versato_netto,
					sr.codice_universo_pz = tomerge.codice_universo_pz,
					sr.ramo = tomerge.ramo,
					sr.sottostante_pz = tomerge.sottostante_pz,
					sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
					sr.linea_pz = tomerge.linea_pz,
					sr.descr_linea_pz = tomerge.descr_linea_pz,
					sr.data_compleanno_pz = tomerge.data_compleanno_pz,
					sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
					sr.saldo_pol = tomerge.saldo_pol,
                    sr.tipo_pol = tomerge.tipo_pol
					
		WHEN NOT MATCHED 
			THEN INSERT	(	idptf,
							codicebanca,
							codicefiliale,
							codicerapporto,
							codicetitolo,
							"DATA",
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
							is_calc_costi_imp,
							saldo_pol,
                            tipo_pol
							)
			VALUES( tomerge.idptf ,
					tomerge.codicebanca,
					tomerge.codicefiliale,
					tomerge.codicerapporto,
					tomerge.codicetitolo,
					tomerge."DATA",
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
					tomerge.is_calc_costi_imp,
					tomerge.saldo_pol,
                    tomerge.tipo_pol
					);
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE MONORAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
	CLOSE salpo_mono;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE MONORAMO - COMMIT ON ROW: ' || totale);
	COMMIT;     
	
        
 OPEN salpo_multi; --Saldi polizze multiramo
		LOOP
			FETCH salpo_multi BULK COLLECT INTO res_salpo_multi LIMIT ROWS;
				EXIT WHEN res_salpo_multi.COUNT = 0;  
			
			I:=0;
			totale:=0;
			I:= res_salpo_multi.COUNT;
			totale := totale + I;
				
		FORALL j IN res_salpo_multi.FIRST .. res_salpo_multi.LAST		

		MERGE INTO saldo_rend_polizze sr
		  USING (SELECT res_salpo_multi(j).idptf 				 AS idptf,
						res_salpo_multi(j).codicebanca		 	 AS codicebanca,
						res_salpo_multi(j).codicefiliale		 AS codicefiliale,
						res_salpo_multi(j).codicerapporto 	 	 AS codicerapporto,
						res_salpo_multi(j).codicetitolo		 	 AS codicetitolo,
						res_salpo_multi(j)."DATA"				 AS "DATA",
						res_salpo_multi(j).ctv					 AS ctv,		
						res_salpo_multi(j).ctvvaluta			 AS ctvvaluta,
						res_salpo_multi(j).dataaggiornamento	 AS dataaggiornamento,
						res_salpo_multi(j).divisa				 AS divisa,
						res_salpo_multi(j).flag_consolidato		 AS flag_consolidato,
						res_salpo_multi(j).id_rapporto			 AS id_rapporto,
						res_salpo_multi(j).ctv_versato			 AS ctv_versato,
						res_salpo_multi(j).ctv_prelevato		 AS ctv_prelevato,
						res_salpo_multi(j).ctv_versato_netto	 AS ctv_versato_netto,
						res_salpo_multi(j).codice_universo_pz 	 AS codice_universo_pz,
						res_salpo_multi(j).ramo 				 AS ramo,
						res_salpo_multi(j).sottostante_pz		 AS sottostante_pz,
						res_salpo_multi(j).data_saldo_nav_pz 	 AS data_saldo_nav_pz,
						res_salpo_multi(j).linea_pz				 AS linea_pz,
						res_salpo_multi(j).descr_linea_pz		 AS descr_linea_pz,
						res_salpo_multi(j).data_compleanno_pz	 AS data_compleanno_pz,
						res_salpo_multi(j).is_calc_costi_imp 	 AS is_calc_costi_imp,
						res_salpo_multi(j).saldo_pol 			 AS saldo_pol,
                        'PZ'                                     AS tipo_pol
				FROM dual
			) tomerge
			 ON (sr.idptf = tomerge.idptf
			  	 AND sr.codicetitolo = tomerge.codicetitolo
			  	 AND sr."DATA" = tomerge."DATA")

		WHEN MATCHED THEN UPDATE
				SET sr.codicebanca = tomerge.codicebanca,
					sr.codicefiliale = tomerge.codicefiliale,
					sr.codicerapporto = tomerge.codicerapporto,
					sr.ctv = nvl(sr.saldo_pol_sp,0) + tomerge.ctv,
					sr.ctvvaluta = tomerge.ctvvaluta,
					sr.dataaggiornamento = tomerge.dataaggiornamento,
					sr.divisa = tomerge.divisa,
					sr.flag_consolidato = tomerge.flag_consolidato,
					sr.id_rapporto = tomerge.id_rapporto,
					sr.ctv_versato = tomerge.ctv_versato,
					sr.ctv_prelevato = tomerge.ctv_prelevato,
					sr.ctv_versato_netto = tomerge.ctv_versato_netto,
					sr.codice_universo_pz = tomerge.codice_universo_pz,
					sr.ramo = tomerge.ramo,
					sr.sottostante_pz = tomerge.sottostante_pz,
					sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
					sr.linea_pz = tomerge.linea_pz,
					sr.descr_linea_pz = tomerge.descr_linea_pz,
					sr.data_compleanno_pz = tomerge.data_compleanno_pz,
					sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
					sr.saldo_pol = tomerge.saldo_pol,
                    sr.tipo_pol = tomerge.tipo_pol
					
		WHEN NOT MATCHED 
			THEN INSERT	(	idptf,
							codicebanca,
							codicefiliale,
							codicerapporto,
							codicetitolo,
							"DATA",
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
							is_calc_costi_imp,
							saldo_pol,
                            tipo_pol
					)
			VALUES( tomerge.idptf ,
					tomerge.codicebanca,
					tomerge.codicefiliale,
					tomerge.codicerapporto,
					tomerge.codicetitolo,
					tomerge."DATA",
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
					tomerge.is_calc_costi_imp,
					tomerge.saldo_pol,
                    tomerge.tipo_pol
					);
					
			FORALL j IN res_salpo_multi.FIRST .. res_salpo_multi.LAST
					
				UPDATE rapporto SET 
				codicetitolo_multiramo = res_salpo_multi(j).codicetitolo
				WHERE ID = res_salpo_multi(j).id_rapporto;
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE MULTIRAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
	CLOSE salpo_multi;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE MULTIRAMO - COMMIT ON ROW: ' || totale);
	COMMIT;
 
 OPEN salpo_sp_mono; --Saldi polizze sp monoramo
		LOOP
			FETCH salpo_sp_mono BULK COLLECT INTO res_salpo_sp_mono LIMIT ROWS;
				EXIT WHEN res_salpo_sp_mono.COUNT = 0;  
			
			I:=0;
			I:= res_salpo_sp_mono.COUNT;
			totale := totale + I;
				
	FORALL j IN res_salpo_sp_mono.FIRST .. res_salpo_sp_mono.LAST		

		MERGE INTO saldo_rend_polizze sr
		  USING (SELECT res_salpo_sp_mono(j).idptf 			 AS idptf,
						res_salpo_sp_mono(j).codicebanca		 AS codicebanca,
						res_salpo_sp_mono(j).codicefiliale		 AS codicefiliale,
						res_salpo_sp_mono(j).codicerapporto 	 AS codicerapporto,
						res_salpo_sp_mono(j).codicetitolo		 AS codicetitolo,
						res_salpo_sp_mono(j)."DATA"			 AS "DATA",
						res_salpo_sp_mono(j).ctv				 AS ctv,		
						res_salpo_sp_mono(j).ctvvaluta			 AS ctvvaluta,
						res_salpo_sp_mono(j).dataaggiornamento	 AS dataaggiornamento,
						res_salpo_sp_mono(j).divisa			 AS divisa,
						res_salpo_sp_mono(j).flag_consolidato	 AS flag_consolidato,
						res_salpo_sp_mono(j).id_rapporto		 AS id_rapporto,
						res_salpo_sp_mono(j).ctv_versato		 AS ctv_versato,
						res_salpo_sp_mono(j).ctv_prelevato		 AS ctv_prelevato,
						res_salpo_sp_mono(j).ctv_versato_netto	 AS ctv_versato_netto,
						res_salpo_sp_mono(j).codice_universo_pz AS codice_universo_pz,
						res_salpo_sp_mono(j).ramo 				 AS ramo,
						res_salpo_sp_mono(j).sottostante_pz	 AS sottostante_pz,
						res_salpo_sp_mono(j).data_saldo_nav_pz  AS data_saldo_nav_pz,
						res_salpo_sp_mono(j).linea_pz			 AS linea_pz,
						res_salpo_sp_mono(j).descr_linea_pz	 AS descr_linea_pz,
						res_salpo_sp_mono(j).data_compleanno_pz AS data_compleanno_pz,
						res_salpo_sp_mono(j).is_calc_costi_imp  AS is_calc_costi_imp,
						res_salpo_sp_mono(j).saldo_pol_sp 		 AS saldo_pol_sp,
                        'SP'                                       AS tipo_pol
				FROM dual
			) tomerge
			 ON (sr.idptf = tomerge.idptf
			  	 AND sr.codicetitolo = tomerge.codicetitolo
			  	 AND sr."DATA" = tomerge."DATA")

		WHEN MATCHED THEN UPDATE
				  SET sr.codicebanca = tomerge.codicebanca,
					sr.codicefiliale = tomerge.codicefiliale,
					sr.codicerapporto = tomerge.codicerapporto,
					sr.ctv = nvl(sr.saldo_pol,0) + tomerge.ctv,
					sr.ctvvaluta = tomerge.ctvvaluta,
					sr.dataaggiornamento = tomerge.dataaggiornamento,
					sr.divisa = tomerge.divisa,
					sr.flag_consolidato = tomerge.flag_consolidato,
					sr.id_rapporto = tomerge.id_rapporto,
					sr.ctv_versato = tomerge.ctv_versato,
					sr.ctv_prelevato = tomerge.ctv_prelevato,
					sr.ctv_versato_netto = tomerge.ctv_versato_netto,
					sr.codice_universo_pz = tomerge.codice_universo_pz,
					sr.ramo = tomerge.ramo,
					sr.sottostante_pz = tomerge.sottostante_pz,
					sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
					sr.linea_pz = tomerge.linea_pz,
					sr.descr_linea_pz = tomerge.descr_linea_pz,
					sr.data_compleanno_pz = tomerge.data_compleanno_pz,
					sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
					sr.saldo_pol_sp = tomerge.saldo_pol_sp,
                    sr.tipo_pol = tomerge.tipo_pol
					
		WHEN NOT MATCHED 
			THEN INSERT	(	idptf,
							codicebanca,
							codicefiliale,
							codicerapporto,
							codicetitolo,
							"DATA",
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
							is_calc_costi_imp,
							saldo_pol_sp,
                            tipo_pol
							)
			VALUES( tomerge.idptf ,
					tomerge.codicebanca,
					tomerge.codicefiliale,
					tomerge.codicerapporto,
					tomerge.codicetitolo,
					tomerge."DATA",
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
					tomerge.is_calc_costi_imp,
					tomerge.saldo_pol_sp,
                    tomerge.tipo_pol
					);
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP MONORAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
	CLOSE salpo_sp_mono;

		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP MONORAMO - COMMIT ON ROW: ' || totale);
	COMMIT;
	
	 OPEN salpo_sp_multi; --Saldi polizze sp multiramo
		LOOP
			FETCH salpo_sp_multi BULK COLLECT INTO res_salpo_sp_multi LIMIT ROWS;
				EXIT WHEN res_salpo_sp_multi.COUNT = 0;  
			
			I:=0;
			totale:=0;
			I:= res_salpo_sp_multi.COUNT;
			totale := totale + I;
				
	FORALL j IN res_salpo_sp_multi.FIRST .. res_salpo_sp_multi.LAST	
		
		MERGE INTO saldo_rend_polizze sr
		  USING (SELECT res_salpo_sp_multi(j).idptf 				 AS idptf,
						res_salpo_sp_multi(j).codicebanca		 	 AS codicebanca,
						res_salpo_sp_multi(j).codicefiliale		 AS codicefiliale,
						res_salpo_sp_multi(j).codicerapporto 		 AS codicerapporto,
						res_salpo_sp_multi(j).codicetitolo			 AS codicetitolo,
						res_salpo_sp_multi(j)."DATA"				 AS "DATA",
						res_salpo_sp_multi(j).ctv					 AS ctv,		
						res_salpo_sp_multi(j).ctvvaluta			 AS ctvvaluta,
						res_salpo_sp_multi(j).dataaggiornamento	 AS dataaggiornamento,
						res_salpo_sp_multi(j).divisa				 AS divisa,
						res_salpo_sp_multi(j).flag_consolidato		 AS flag_consolidato,
						res_salpo_sp_multi(j).id_rapporto			 AS id_rapporto,
						res_salpo_sp_multi(j).ctv_versato			 AS ctv_versato,
						res_salpo_sp_multi(j).ctv_prelevato		    AS ctv_prelevato,
						res_salpo_sp_multi(j).ctv_versato_netto	    AS ctv_versato_netto,
						res_salpo_sp_multi(j).codice_universo_pz 	 AS codice_universo_pz,
						res_salpo_sp_multi(j).ramo 				     AS ramo,
						res_salpo_sp_multi(j).sottostante_pz		 AS sottostante_pz,
						res_salpo_sp_multi(j).data_saldo_nav_pz 	 AS data_saldo_nav_pz,
						res_salpo_sp_multi(j).linea_pz				 AS linea_pz,
						res_salpo_sp_multi(j).descr_linea_pz		 AS descr_linea_pz,
						res_salpo_sp_multi(j).data_compleanno_pz	 AS data_compleanno_pz,
						res_salpo_sp_multi(j).is_calc_costi_imp     AS is_calc_costi_imp,
						res_salpo_sp_multi(j).saldo_pol_sp 		    AS saldo_pol_sp,
                        'SP'                                          AS tipo_pol
				FROM dual
			) tomerge
			 ON (sr.idptf = tomerge.idptf
			  	 AND sr.codicetitolo = tomerge.codicetitolo
			  	 AND sr."DATA" = tomerge."DATA")

		WHEN MATCHED THEN UPDATE
				SET sr.codicebanca = tomerge.codicebanca,
					sr.codicefiliale = tomerge.codicefiliale,
					sr.codicerapporto = tomerge.codicerapporto,
					sr.ctv = nvl(sr.saldo_pol,0) + tomerge.ctv,
					sr.ctvvaluta = tomerge.ctvvaluta,
					sr.dataaggiornamento = tomerge.dataaggiornamento,
					sr.divisa = tomerge.divisa,
					sr.flag_consolidato = tomerge.flag_consolidato,
					sr.id_rapporto = tomerge.id_rapporto,
					sr.ctv_versato = tomerge.ctv_versato,
					sr.ctv_prelevato = tomerge.ctv_prelevato,
					sr.ctv_versato_netto = tomerge.ctv_versato_netto,
					sr.codice_universo_pz = tomerge.codice_universo_pz,
					sr.ramo = tomerge.ramo,
					sr.sottostante_pz = tomerge.sottostante_pz,
					sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
					sr.linea_pz = tomerge.linea_pz,
					sr.descr_linea_pz = tomerge.descr_linea_pz,
					sr.data_compleanno_pz = tomerge.data_compleanno_pz,
					sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
					sr.saldo_pol_sp = tomerge.saldo_pol_sp,
                    sr.tipo_pol = tomerge.tipo_pol
					
		WHEN NOT MATCHED 
			THEN INSERT	(	idptf,
							codicebanca,
							codicefiliale,
							codicerapporto,
							codicetitolo,
							"DATA",
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
							is_calc_costi_imp,
							saldo_pol_sp,
                            tipo_pol
					)
			VALUES( tomerge.idptf ,
					tomerge.codicebanca,
					tomerge.codicefiliale,
					tomerge.codicerapporto,
					tomerge.codicetitolo,
					tomerge."DATA",
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
					tomerge.is_calc_costi_imp,
					tomerge.saldo_pol_sp,
                    tomerge.tipo_pol
					);
					
				FORALL j IN res_salpo_sp_multi.FIRST .. res_salpo_sp_multi.LAST
					
				UPDATE rapporto SET 
				codicetitolo_multiramo = res_salpo_sp_multi(j).codicetitolo
				WHERE ID = res_salpo_sp_multi(j).id_rapporto;
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP MULTIRAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
	CLOSE salpo_sp_multi;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP MULTIRAMO - COMMIT ON ROW: ' || totale);
	COMMIT;

--Saldo rend sott	

	I := 0;
	
FOR cur_item IN rend_sott
    LOOP
        I := I+1;

		MERGE 
			INTO saldo_rend_sott_pol sott
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
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT_POL - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT_POL - COMMIT ON ROW: ' || I);
	COMMIT;	
	


IF (maxyearweek > t1) THEN

    MERGE INTO saldo_rend sr
        USING (SELECT 	idptf,
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
				        is_calc_costi_imp,
				        saldo_pol,
				        saldo_pol_sp
				        FROM saldo_rend_polizze 
				        WHERE (idptf, codicetitolo, DATA) IN ( SELECT	idptf,
															        	codicetitolo,
															        	MAX(DATA) 		AS DATA
																FROM saldo_rend_polizze 
																WHERE yearweek <= t1
															    AND tipo_pol = 'PZ'
															    GROUP BY idptf, codicetitolo, yearweek)
            ) tomerge
	ON (sr.idptf = tomerge.idptf
		AND sr.codicetitolo = tomerge.codicetitolo
		AND sr."DATA" = tomerge."DATA")
        
WHEN MATCHED THEN
 UPDATE SET sr.codicebanca = tomerge.codicebanca,
            sr.codicefiliale = tomerge.codicefiliale,
            sr.codicerapporto = tomerge.codicerapporto,
            sr.ctv = nvl(sr.saldo_pol_sp,0) + tomerge.ctv,
            sr.ctvvaluta = tomerge.ctvvaluta,
            sr.dataaggiornamento = tomerge.dataaggiornamento,
            sr.divisa = tomerge.divisa,
            sr.flag_consolidato = tomerge.flag_consolidato,
            sr.id_rapporto = tomerge.id_rapporto,
            sr.ctv_versato = tomerge.ctv_versato,
            sr.ctv_prelevato = tomerge.ctv_prelevato,
            sr.ctv_versato_netto = tomerge.ctv_versato_netto,
            sr.codice_universo_pz = tomerge.codice_universo_pz,
            sr.ramo = tomerge.ramo,
            sr.sottostante_pz = tomerge.sottostante_pz,
            sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
            sr.linea_pz = tomerge.linea_pz,
            sr.descr_linea_pz = tomerge.descr_linea_pz,
            sr.data_compleanno_pz = tomerge.data_compleanno_pz,
            sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
            sr.saldo_pol = tomerge.saldo_pol,
            sr.saldo_pol_sp = tomerge.saldo_pol_sp
        
WHEN NOT MATCHED THEN
INSERT (idptf,
        codicebanca,
        codicefiliale,
        codicerapporto,
        codicetitolo,
        "DATA",
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
        is_calc_costi_imp,
        saldo_pol,
        saldo_pol_sp
    )
    VALUES( tomerge.idptf,
            tomerge.codicebanca,
            tomerge.codicefiliale,
            tomerge.codicerapporto,
            tomerge.codicetitolo,
            tomerge."DATA",
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
            tomerge.is_calc_costi_imp,
            tomerge.saldo_pol,
            tomerge.saldo_pol_sp
            );
        
        rowcounts := SQL%rowcount;
		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE POLIZZE WEEK: ' || rowcounts);
	COMMIT;  

--Saldo rend sott
MERGE INTO saldo_rend_sott sott
USING (SELECT  idptf,
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
		FROM saldo_rend_sott_pol
        WHERE (idptf, codicetitolo, DATA) IN (	SELECT	idptf,
														codicetitolo,
														MAX(DATA) 		AS DATA
												FROM saldo_rend_sott_pol 
												WHERE yearweek <= t1
											    GROUP BY idptf, codicetitolo, yearweek)
       )tomerge
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
				
	 rowcounts := SQL%rowcount;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT WEEK - COMMIT ON ROW: ' || rowcounts);
	COMMIT;
	
    END IF;
    
--cambio mese
    
    IF (maxyearmonth > t1m) THEN

    MERGE INTO saldo_rend sr
        USING (SELECT 	idptf,
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
				        is_calc_costi_imp,
				        saldo_pol,
				        saldo_pol_sp
				        FROM saldo_rend_polizze 
				        WHERE (idptf, codicetitolo, DATA) IN ( SELECT	idptf,
															        	codicetitolo,
															        	MAX(DATA) 		AS DATA
																FROM saldo_rend_polizze 
																WHERE to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0'))) = t1m
															    AND tipo_pol = 'PZ'
															    GROUP BY idptf, codicetitolo)

            ) tomerge
	ON (sr.idptf = tomerge.idptf
		AND sr.codicetitolo = tomerge.codicetitolo
		AND sr."DATA" = tomerge."DATA")
        
WHEN MATCHED THEN
 UPDATE SET sr.codicebanca = tomerge.codicebanca,
            sr.codicefiliale = tomerge.codicefiliale,
            sr.codicerapporto = tomerge.codicerapporto,
            sr.ctv = nvl(sr.saldo_pol_sp,0) + tomerge.ctv,
            sr.ctvvaluta = tomerge.ctvvaluta,
            sr.dataaggiornamento = tomerge.dataaggiornamento,
            sr.divisa = tomerge.divisa,
            sr.flag_consolidato = tomerge.flag_consolidato,
            sr.id_rapporto = tomerge.id_rapporto,
            sr.ctv_versato = tomerge.ctv_versato,
            sr.ctv_prelevato = tomerge.ctv_prelevato,
            sr.ctv_versato_netto = tomerge.ctv_versato_netto,
            sr.codice_universo_pz = tomerge.codice_universo_pz,
            sr.ramo = tomerge.ramo,
            sr.sottostante_pz = tomerge.sottostante_pz,
            sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
            sr.linea_pz = tomerge.linea_pz,
            sr.descr_linea_pz = tomerge.descr_linea_pz,
            sr.data_compleanno_pz = tomerge.data_compleanno_pz,
            sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
            sr.saldo_pol = tomerge.saldo_pol,
            sr.saldo_pol_sp = tomerge.saldo_pol_sp
        
WHEN NOT MATCHED THEN
INSERT (idptf,
        codicebanca,
        codicefiliale,
        codicerapporto,
        codicetitolo,
        "DATA",
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
        is_calc_costi_imp,
        saldo_pol,
        saldo_pol_sp
    )
    VALUES( tomerge.idptf,
            tomerge.codicebanca,
            tomerge.codicefiliale,
            tomerge.codicerapporto,
            tomerge.codicetitolo,
            tomerge."DATA",
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
            tomerge.is_calc_costi_imp,
            tomerge.saldo_pol,
            tomerge.saldo_pol_sp
            );
        
        rowcounts := SQL%rowcount;
		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE POLIZZE MONTH: ' || rowcounts);
	COMMIT;  

--Saldo rend sott
MERGE INTO saldo_rend_sott sott
USING (SELECT  idptf,
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
		FROM saldo_rend_sott_pol
        WHERE (idptf, codicetitolo, DATA) IN (	SELECT	idptf,
														codicetitolo,
														MAX(DATA) 		AS DATA
												FROM saldo_rend_sott_pol 
												WHERE to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0'))) = t1m
											    GROUP BY idptf, codicetitolo)
       )tomerge
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
				
	 rowcounts := SQL%rowcount;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT MONTH - COMMIT ON ROW: ' || rowcounts);
	COMMIT;
	
    END IF;

    --Saldi polizze sp
    
	IF (maxyearweeksp > t1) THEN

    MERGE INTO saldo_rend sr
        USING (SELECT 	idptf,
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
				        is_calc_costi_imp,
				        saldo_pol,
				        saldo_pol_sp
				        FROM saldo_rend_polizze 
				        WHERE (idptf, codicetitolo, DATA) IN ( SELECT	idptf,
															        	codicetitolo,
															        	MAX(DATA) 		AS DATA
																FROM saldo_rend_polizze 
																WHERE yearweek <= t1
															    AND tipo_pol = 'SP'
															    GROUP BY idptf, codicetitolo, yearweek)
            ) tomerge
	ON (sr.idptf = tomerge.idptf
		AND sr.codicetitolo = tomerge.codicetitolo
		AND sr."DATA" = tomerge."DATA")
        
WHEN MATCHED THEN
 UPDATE SET sr.codicebanca = tomerge.codicebanca,
            sr.codicefiliale = tomerge.codicefiliale,
            sr.codicerapporto = tomerge.codicerapporto,
            sr.ctv = nvl(sr.saldo_pol_sp,0) + tomerge.ctv,
            sr.ctvvaluta = tomerge.ctvvaluta,
            sr.dataaggiornamento = tomerge.dataaggiornamento,
            sr.divisa = tomerge.divisa,
            sr.flag_consolidato = tomerge.flag_consolidato,
            sr.id_rapporto = tomerge.id_rapporto,
            sr.ctv_versato = tomerge.ctv_versato,
            sr.ctv_prelevato = tomerge.ctv_prelevato,
            sr.ctv_versato_netto = tomerge.ctv_versato_netto,
            sr.codice_universo_pz = tomerge.codice_universo_pz,
            sr.ramo = tomerge.ramo,
            sr.sottostante_pz = tomerge.sottostante_pz,
            sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
            sr.linea_pz = tomerge.linea_pz,
            sr.descr_linea_pz = tomerge.descr_linea_pz,
            sr.data_compleanno_pz = tomerge.data_compleanno_pz,
            sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
            sr.saldo_pol = tomerge.saldo_pol,
            sr.saldo_pol_sp = tomerge.saldo_pol_sp
        
WHEN NOT MATCHED THEN
INSERT (idptf,
        codicebanca,
        codicefiliale,
        codicerapporto,
        codicetitolo,
        "DATA",
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
        is_calc_costi_imp,
        saldo_pol,
        saldo_pol_sp
    )
    VALUES( tomerge.idptf,
            tomerge.codicebanca,
            tomerge.codicefiliale,
            tomerge.codicerapporto,
            tomerge.codicetitolo,
            tomerge."DATA",
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
            tomerge.is_calc_costi_imp,
            tomerge.saldo_pol,
            tomerge.saldo_pol_sp
            );
        
        rowcounts := SQL%rowcount;
		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP POLIZZE WEEK: ' || rowcounts);
	COMMIT;  

END IF;

--cambio mese
    
    IF (maxyearmonthsp > t1m) THEN

    MERGE INTO saldo_rend sr
        USING (SELECT 	idptf,
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
				        is_calc_costi_imp,
				        saldo_pol,
				        saldo_pol_sp
				        FROM saldo_rend_polizze 
				        WHERE (idptf, codicetitolo, DATA) IN ( SELECT	idptf,
															        	codicetitolo,
															        	MAX(DATA) 		AS DATA
																FROM saldo_rend_polizze 
																WHERE to_number(CONCAT(EXTRACT(YEAR FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' )), LPAD(trim(EXTRACT(MONTH FROM TO_DATE(dataaggiornamento, 'YYYYMMDD' ))),2,'0'))) = t1m
															    AND tipo_pol = 'SP'
															    GROUP BY idptf, codicetitolo)
            ) tomerge
	ON (sr.idptf = tomerge.idptf
		AND sr.codicetitolo = tomerge.codicetitolo
		AND sr."DATA" = tomerge."DATA")
        
WHEN MATCHED THEN
 UPDATE SET sr.codicebanca = tomerge.codicebanca,
            sr.codicefiliale = tomerge.codicefiliale,
            sr.codicerapporto = tomerge.codicerapporto,
            sr.ctv = nvl(sr.saldo_pol_sp,0) + tomerge.ctv,
            sr.ctvvaluta = tomerge.ctvvaluta,
            sr.dataaggiornamento = tomerge.dataaggiornamento,
            sr.divisa = tomerge.divisa,
            sr.flag_consolidato = tomerge.flag_consolidato,
            sr.id_rapporto = tomerge.id_rapporto,
            sr.ctv_versato = tomerge.ctv_versato,
            sr.ctv_prelevato = tomerge.ctv_prelevato,
            sr.ctv_versato_netto = tomerge.ctv_versato_netto,
            sr.codice_universo_pz = tomerge.codice_universo_pz,
            sr.ramo = tomerge.ramo,
            sr.sottostante_pz = tomerge.sottostante_pz,
            sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
            sr.linea_pz = tomerge.linea_pz,
            sr.descr_linea_pz = tomerge.descr_linea_pz,
            sr.data_compleanno_pz = tomerge.data_compleanno_pz,
            sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
            sr.saldo_pol = tomerge.saldo_pol,
            sr.saldo_pol_sp = tomerge.saldo_pol_sp
        
WHEN NOT MATCHED THEN
INSERT (idptf,
        codicebanca,
        codicefiliale,
        codicerapporto,
        codicetitolo,
        "DATA",
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
        is_calc_costi_imp,
        saldo_pol,
        saldo_pol_sp
    )
    VALUES( tomerge.idptf,
            tomerge.codicebanca,
            tomerge.codicefiliale,
            tomerge.codicerapporto,
            tomerge.codicetitolo,
            tomerge."DATA",
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
            tomerge.is_calc_costi_imp,
            tomerge.saldo_pol,
            tomerge.saldo_pol_sp
            );
        
        rowcounts := SQL%rowcount;
		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP POLIZZE MONTH: ' || rowcounts);
	COMMIT;  

END IF;


--truncate partizioni 
 
    IF(maxyearweek > t1 OR maxyearweeksp > t1) THEN
    
       FOR cur_item IN weeks_retent
         LOOP
          
          FOR R IN (SELECT partition_name, high_value 
                       FROM all_tab_partitions
                      WHERE table_name = 'SALDO_REND_POLIZZE') 
                      
            LOOP
             EXECUTE IMMEDIATE
                'BEGIN 
                  IF  '|| R.high_value ||' = '||cur_item.yearweek||'
                    THEN 
                    EXECUTE IMMEDIATE '' 
                    ALTER TABLE SALDO_REND_POLIZZE TRUNCATE PARTITION ' || R.partition_name || '''; 
                  END IF;
                END;';
          END LOOP;
          
         END LOOP;
          
          FOR cur_item IN weeks_retent_sott
         	LOOP
          
          FOR R IN (SELECT partition_name, high_value 
                       FROM all_tab_partitions
                      WHERE table_name = 'SALDO_REND_SOTT_POL') 
                      
            LOOP
             EXECUTE IMMEDIATE
                'BEGIN 
                  IF  '|| R.high_value ||' = '||cur_item.yearweek||'
                    THEN 
                    EXECUTE IMMEDIATE '' 
                    ALTER TABLE SALDO_REND_SOTT_POL TRUNCATE PARTITION ' || R.partition_name || '''; 
                  END IF;
                END;';
          END LOOP;
         
          END LOOP;
          
            INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' TRUNCATE PARTITION');
          COMMIT;
          
          EXECUTE IMMEDIATE'ALTER INDEX RENDIMPC.SALDO_REND_POL_PK REBUILD';
          EXECUTE IMMEDIATE'ALTER INDEX RENDIMPC.SALDO_REND_SOTT_POL_PK REBUILD';

END IF;

	BEGIN
	    dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'SALDO_REND_POLIZZE', degree => 4, estimate_percent=>1, cascade=>true); 
		dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'SALDO_REND_SOTT_POL', degree => 4, estimate_percent=>1, cascade=>true); 
	END;
    
END;