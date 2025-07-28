DECLARE

--Saldi polizze monoramo
CURSOR salpo_mono IS
	SELECT
		R.idptf																								AS idptf,
		'07601'																								AS codicebanca,
		R.codiceagenzia 																					AS codicefiliale,
		LPAD(trim(sp.codicerapporto),12,'0')																AS codicerapporto,
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
	FROM TMP_PFSALPOSP_RECUP sp
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
		AND sf.livello_2 = 'POLIZZE RAMO I'; 

	
--Saldi polizze multiramo	
CURSOR salpo_multi IS
	SELECT
		MIN(R.idptf)																						AS idptf,
		'07601'																								AS codicebanca,
		MIN(sp.codiceagenzia)																				AS codicefiliale,
		LPAD(trim(sp.codicerapporto),12,'0')																AS codicerapporto,
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
	FROM TMP_PFSALPOSP_RECUP sp
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
	AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
	GROUP BY sp.codicerapporto, 
			 CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
					ELSE sp.codiceinterno END, 
			 sp.dataaggiornamento;

TYPE SALPO_MONO_TYPE IS TABLE OF SALPO_MONO%ROWTYPE INDEX BY PLS_INTEGER;
TYPE SALPO_MULTI_TYPE IS TABLE OF SALPO_MULTI%ROWTYPE INDEX BY PLS_INTEGER;
	
RES_SALPO_MONO SALPO_MONO_TYPE;
RES_SALPO_MULTI SALPO_MULTI_TYPE;
	
ROWS    PLS_INTEGER := 10000;

I 		NUMBER(38,0):=0;
totale	NUMBER(38,0):=0;
CNT		NUMBER(38,0):=0;


BEGIN
	
SELECT COUNT(*) INTO CNT FROM TMP_PFSALPOSP_RECUP;

IF (CNT >= 1000000) THEN

	EXECUTE IMMEDIATE 'ALTER TABLE RENDIMPC.SALDO_REND NOLOGGING';
	EXECUTE IMMEDIATE 'ALTER TABLE RENDIMPC.SALDO_REND DISABLE CONSTRAINT FK_SALDO_REND_PORTAFOGLIO';
	EXECUTE IMMEDIATE 'ALTER TABLE RENDIMPC.SALDO_REND DISABLE CONSTRAINT FK_SALDO_REND_STRUMENTOFINANZI';
	EXECUTE IMMEDIATE 'ALTER INDEX RENDIMPC.IDX_SALDO_REND_PK NOLOGGING';
        
END IF;
	
 OPEN SALPO_MONO; --Saldi polizze monoramo
		LOOP
			FETCH SALPO_MONO BULK COLLECT INTO RES_SALPO_MONO LIMIT ROWS;
				EXIT WHEN RES_SALPO_MONO.COUNT = 0;  
			
			I:=0;
			I:= RES_SALPO_MONO.COUNT;
			TOTALE := TOTALE + I;
				
	FORALL J IN RES_SALPO_MONO.FIRST .. RES_SALPO_MONO.LAST		

		MERGE INTO saldo_rend sr
		  USING (SELECT RES_SALPO_MONO(j).idptf 			 AS idptf,
						RES_SALPO_MONO(j).codicebanca		 AS codicebanca,
						RES_SALPO_MONO(j).codicefiliale		 AS codicefiliale,
						RES_SALPO_MONO(j).codicerapporto 	 AS codicerapporto,
						RES_SALPO_MONO(j).codicetitolo		 AS codicetitolo,
						RES_SALPO_MONO(j)."DATA"			 AS "DATA",
						RES_SALPO_MONO(j).ctv				 AS ctv,		
						RES_SALPO_MONO(j).ctvvaluta			 AS ctvvaluta,
						RES_SALPO_MONO(j).dataaggiornamento	 AS dataaggiornamento,
						RES_SALPO_MONO(j).divisa			 AS divisa,
						RES_SALPO_MONO(j).flag_consolidato	 AS flag_consolidato,
						RES_SALPO_MONO(j).id_rapporto		 AS id_rapporto,
						RES_SALPO_MONO(j).ctv_versato		 AS ctv_versato,
						RES_SALPO_MONO(j).ctv_prelevato		 AS ctv_prelevato,
						RES_SALPO_MONO(j).ctv_versato_netto	 AS ctv_versato_netto,
						RES_SALPO_MONO(j).codice_universo_pz AS codice_universo_pz,
						RES_SALPO_MONO(j).ramo 				 AS ramo,
						RES_SALPO_MONO(j).sottostante_pz	 AS sottostante_pz,
						RES_SALPO_MONO(j).data_saldo_nav_pz  AS data_saldo_nav_pz,
						RES_SALPO_MONO(j).linea_pz			 AS linea_pz,
						RES_SALPO_MONO(j).descr_linea_pz	 AS descr_linea_pz,
						RES_SALPO_MONO(j).data_compleanno_pz AS data_compleanno_pz,
						RES_SALPO_MONO(j).is_calc_costi_imp  AS is_calc_costi_imp,
						RES_SALPO_MONO(j).saldo_pol_sp 		 AS saldo_pol_sp
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
					sr.saldo_pol_sp = tomerge.saldo_pol_sp
					
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
							saldo_pol_sp
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
					tomerge.saldo_pol_sp
					);
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND POLIZZE IN LIQUIDAZIONE MONORAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
	CLOSE SALPO_MONO;

		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND POLIZZE IN LIQUIDAZIONE MONORAMO - COMMIT ON ROW: ' || totale);
	COMMIT;
	
	

	 OPEN SALPO_MULTI; --Saldi polizze multiramo
		LOOP
			FETCH SALPO_MULTI BULK COLLECT INTO RES_SALPO_MULTI LIMIT ROWS;
				EXIT WHEN RES_SALPO_MULTI.COUNT = 0;  
			
			I:=0;
			TOTALE:=0;
			I:= RES_SALPO_MULTI.COUNT;
			TOTALE := TOTALE + I;
				
	FORALL J IN RES_SALPO_MULTI.FIRST .. RES_SALPO_MULTI.LAST	
		
		MERGE INTO saldo_rend sr
		  USING (SELECT RES_SALPO_MULTI(j).idptf 				 AS idptf,
						RES_SALPO_MULTI(j).codicebanca		 	 AS codicebanca,
						RES_SALPO_MULTI(j).codicefiliale		 AS codicefiliale,
						RES_SALPO_MULTI(j).codicerapporto 		 AS codicerapporto,
						RES_SALPO_MULTI(j).codicetitolo			 AS codicetitolo,
						RES_SALPO_MULTI(j)."DATA"				 AS "DATA",
						RES_SALPO_MULTI(j).ctv					 AS ctv,		
						RES_SALPO_MULTI(j).ctvvaluta			 AS ctvvaluta,
						RES_SALPO_MULTI(j).dataaggiornamento	 AS dataaggiornamento,
						RES_SALPO_MULTI(j).divisa				 AS divisa,
						RES_SALPO_MULTI(j).flag_consolidato		 AS flag_consolidato,
						RES_SALPO_MULTI(j).id_rapporto			 AS id_rapporto,
						RES_SALPO_MULTI(j).ctv_versato			 AS ctv_versato,
						RES_SALPO_MULTI(j).ctv_prelevato		 AS ctv_prelevato,
						RES_SALPO_MULTI(j).ctv_versato_netto	 AS ctv_versato_netto,
						RES_SALPO_MULTI(j).codice_universo_pz 	 AS codice_universo_pz,
						RES_SALPO_MULTI(j).ramo 				 AS ramo,
						RES_SALPO_MULTI(j).sottostante_pz		 AS sottostante_pz,
						RES_SALPO_MULTI(j).data_saldo_nav_pz 	 AS data_saldo_nav_pz,
						RES_SALPO_MULTI(j).linea_pz				 AS linea_pz,
						RES_SALPO_MULTI(j).descr_linea_pz		 AS descr_linea_pz,
						RES_SALPO_MULTI(j).data_compleanno_pz	 AS data_compleanno_pz,
						RES_SALPO_MULTI(j).is_calc_costi_imp     AS is_calc_costi_imp,
						RES_SALPO_MULTI(j).saldo_pol_sp 		 AS saldo_pol_sp
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
					sr.saldo_pol_sp = tomerge.saldo_pol_sp
					
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
							saldo_pol_sp
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
					tomerge.saldo_pol_sp
					);
					
				FORALL J IN RES_SALPO_MULTI.FIRST .. RES_SALPO_MULTI.LAST
					
				UPDATE rapporto SET 
				codicetitolo_multiramo = RES_SALPO_MULTI(j).codicetitolo
				WHERE ID = RES_SALPO_MULTI(j).id_rapporto;
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND POLIZZE IN LIQUIDAZIONE MULTIRAMO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
	CLOSE SALPO_MULTI;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND POLIZZE IN LIQUIDAZIONE MULTIRAMO - COMMIT ON ROW: ' || totale);
	COMMIT;
END;