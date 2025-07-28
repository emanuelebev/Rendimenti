DECLARE

CURSOR saldi_rend IS
	SELECT	rapp.idptf																							AS idptf,
			rapp.codicebanca																					AS codicebanca,
			rapp.codiceagenzia 																					AS codicefiliale,
			substr(tsr.codicerapporto, instr(tsr.codicerapporto, '-')+1)										AS codicerapporto,
			tsr.codiceinterno 																					AS codicetitolo,
			to_number( to_char( TO_DATE( tsr.datasaldo, 'YYYY-MM-DD' ), 'YYYYMMDD' )) 							AS "DATA",
			tsr.controvalore																					AS ctv,
			NULL 																								AS ctvvaluta,
			to_number(to_char( TO_DATE( tsr.dataaggiornamento, 'YYYY-MM-DD HH24:MI:SS' ), 'YYYYMMDDHH24MISS')) 	AS dataaggiornamento,
			tsr.divisa 																							AS divisa,
			tsr.flagconsolidato 																				AS flag_consolidato,
			rapp.ID 																							AS id_rapporto,
			tsr.ctvversato 																						AS ctv_versato,
			tsr.ctvprelevato 																					AS ctv_prelevato,
			(tsr.ctvversato - tsr.ctvprelevato) 																AS ctv_versato_netto,
			NULL																								AS codicerapporto_ori,
			tsr.codicefasciarendimento																			AS cod_fasciarendimento_bfp,
			tsr.decrizionefasciarendimento																		AS descr_fasciarendimento_bfp,
			tsr.seriebuono																						AS serie_bfp,
			tsr.valorescadenzalordo																				AS valore_scadenza_lordo_bfp,
			tsr.flagnettistalordista																			AS flag_lordista_bfp,
			tsr.importonetto																					AS importo_netto_bfp,
			tsr.valorescadenzanetto																				AS valore_scadenza_netto_bfp,
			tsr.valorenominale																					AS valore_nominale_bfp,
			TO_DATE(tsr.datasottoscrizione, 'YYYY-MM-DD') 														AS datasottoscrizione,
			TO_DATE(tsr.datascadenza, 'YYYY-MM-DD') 															AS datascadenza
		FROM
			tmp_pfsaldistorici tsr
		INNER JOIN rapporto rapp 
		ON tsr.codicerapporto = RAPP.CODICERAPPORTO		
			AND	tsr.codicebanca = rapp.codicebanca
			AND tsr.tiporapporto = rapp.tipo
		WHERE RAPP.id_buono_originario is null;
			
CURSOR saldi_rend_bfpd IS
	SELECT	rapp.idptf																							AS idptf,
			rapp.codicebanca																					AS codicebanca,
			rapp.codiceagenzia 																					AS codicefiliale,
			substr(tsr.codicerapporto, instr(tsr.codicerapporto, '-')+1)										AS codicerapporto,
			tsr.codiceinterno 																					AS codicetitolo,
			to_number( to_char( TO_DATE( tsr.datasaldo, 'YYYY-MM-DD' ), 'YYYYMMDD' )) 							AS "DATA",
			tsr.controvalore																					AS ctv,
			NULL 																								AS ctvvaluta,
			to_number(to_char( TO_DATE( tsr.dataaggiornamento, 'YYYY-MM-DD HH24:MI:SS' ), 'YYYYMMDDHH24MISS')) 	AS dataaggiornamento,
			tsr.divisa 																							AS divisa,
			tsr.flagconsolidato 																				AS flag_consolidato,
			rapp.ID 																							AS id_rapporto,
			tsr.ctvversato 																						AS ctv_versato,
			tsr.ctvprelevato 																					AS ctv_prelevato,
			( tsr.ctvversato - tsr.ctvprelevato ) 																AS ctv_versato_netto,
			tsr.id_buono_originario																				AS codicerapporto_ori,
			tsr.codicefasciarendimento																			AS cod_fasciarendimento_bfp,
			tsr.decrizionefasciarendimento																		AS descr_fasciarendimento_bfp,
			tsr.seriebuono																						AS serie_bfp,
			tsr.valorescadenzalordo																				AS valore_scadenza_lordo_bfp,
			tsr.flagnettistalordista																			AS flag_lordista_bfp,
			tsr.importonetto																					AS importo_netto_bfp,
			tsr.valorescadenzanetto																				AS valore_scadenza_netto_bfp,
			tsr.valorenominale																					AS valore_nominale_bfp,
			TO_DATE(tsr.datasottoscrizione, 'YYYY-MM-DD') 														AS datasottoscrizione,
			TO_DATE(tsr.datascadenza, 'YYYY-MM-DD') 															AS datascadenza
		FROM
			tmp_pfsaldistorici tsr
		INNER JOIN rapporto rapp 
		ON tsr.id_buono_originario = rapp.id_buono_originario
			AND	tsr.codicebanca = rapp.codicebanca
			AND tsr.tiporapporto = rapp.tipo
		WHERE RAPP.id_buono_originario is not null;
				
TYPE saldi_rend_TYPE IS TABLE OF saldi_rend%ROWTYPE INDEX BY PLS_INTEGER;
TYPE saldi_rend_bfpd_TYPE IS TABLE OF saldi_rend_bfpd%ROWTYPE INDEX BY PLS_INTEGER;

RES_saldi_rend saldi_rend_TYPE;
RES_saldi_rend_bfpd saldi_rend_bfpd_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;
totale	NUMBER(38,0):=0;

			
BEGIN
		
		OPEN saldi_rend;
		LOOP
			FETCH saldi_rend BULK COLLECT INTO RES_saldi_rend LIMIT ROWS;
				EXIT WHEN RES_saldi_rend.COUNT = 0;  
			
			I:=0;
			I:= RES_saldi_rend.COUNT;
			TOTALE := TOTALE + I;
				
		FORALL J IN RES_saldi_rend.FIRST .. RES_saldi_rend.LAST		

			INSERT /*+ APPEND */ INTO SALDO_REND(	idptf,
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
													codicerapporto_ori,
													cod_fasciarendimento_bfp,	
													descr_fasciarendimento_bfp,	
													serie_bfp,					
													valore_scadenza_lordo_bfp,	
													flag_lordista_bfp,		
													importo_netto_bfp,			
													valore_scadenza_netto_bfp,
													valore_nominale_bfp,	
													datasottoscrizione,			
													datascadenza
												)
										VALUES( RES_saldi_rend(j).idptf,
												RES_saldi_rend(j).codicebanca,
												RES_saldi_rend(j).codicefiliale,
												RES_saldi_rend(j).codicerapporto,
												RES_saldi_rend(j).codicetitolo,
												RES_saldi_rend(j)."DATA",
												RES_saldi_rend(j).ctv,
												RES_saldi_rend(j).ctvvaluta,
												RES_saldi_rend(j).dataaggiornamento,
												RES_saldi_rend(j).divisa,
												RES_saldi_rend(j).flag_consolidato,
												RES_saldi_rend(j).id_rapporto,
												RES_saldi_rend(j).ctv_versato,
												RES_saldi_rend(j).ctv_prelevato,
												RES_saldi_rend(j).ctv_versato_netto,
												RES_saldi_rend(j).codicerapporto_ori,
												RES_saldi_rend(j).cod_fasciarendimento_bfp,
												RES_saldi_rend(j).descr_fasciarendimento_bfp,
												RES_saldi_rend(j).serie_bfp,
												RES_saldi_rend(j).valore_scadenza_lordo_bfp,
												RES_saldi_rend(j).flag_lordista_bfp,
												RES_saldi_rend(j).importo_netto_bfp,
												RES_saldi_rend(j).valore_scadenza_netto_bfp,
												RES_saldi_rend(j).valore_nominale_bfp,
												RES_saldi_rend(j).datasottoscrizione,
												RES_saldi_rend(j).datascadenza
											  );
								
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' INSERT SALDO_REND - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
	CLOSE saldi_rend;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' INSERT SALDO_REND - COMMIT ON ROW: ' || totale);
	COMMIT;
	
	
		OPEN saldi_rend_bfpd;
		LOOP
			FETCH saldi_rend_bfpd BULK COLLECT INTO RES_saldi_rend_bfpd LIMIT ROWS;
				EXIT WHEN RES_saldi_rend_bfpd.COUNT = 0;  
			
			I:=0;
			I:= RES_saldi_rend_bfpd.COUNT;
			TOTALE := TOTALE + I;
				
		FORALL J IN RES_saldi_rend_bfpd.FIRST .. RES_saldi_rend_bfpd.LAST		

			INSERT /*+ APPEND */ INTO SALDO_REND(	idptf,
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
													codicerapporto_ori,
													cod_fasciarendimento_bfp,	
													descr_fasciarendimento_bfp,	
													serie_bfp,					
													valore_scadenza_lordo_bfp,	
													flag_lordista_bfp,		
													importo_netto_bfp,			
													valore_scadenza_netto_bfp,
													valore_nominale_bfp,	
													datasottoscrizione,			
													datascadenza
												)
										VALUES( RES_saldi_rend_bfpd(j).idptf,
												RES_saldi_rend_bfpd(j).codicebanca,
												RES_saldi_rend_bfpd(j).codicefiliale,
												RES_saldi_rend_bfpd(j).codicerapporto,
												RES_saldi_rend_bfpd(j).codicetitolo,
												RES_saldi_rend_bfpd(j)."DATA",
												RES_saldi_rend_bfpd(j).ctv,
												RES_saldi_rend_bfpd(j).ctvvaluta,
												RES_saldi_rend_bfpd(j).dataaggiornamento,
												RES_saldi_rend_bfpd(j).divisa,
												RES_saldi_rend_bfpd(j).flag_consolidato,
												RES_saldi_rend_bfpd(j).id_rapporto,
												RES_saldi_rend_bfpd(j).ctv_versato,
												RES_saldi_rend_bfpd(j).ctv_prelevato,
												RES_saldi_rend_bfpd(j).ctv_versato_netto,
												RES_saldi_rend_bfpd(j).codicerapporto_ori,
												RES_saldi_rend_bfpd(j).cod_fasciarendimento_bfp,
												RES_saldi_rend_bfpd(j).descr_fasciarendimento_bfp,
												RES_saldi_rend_bfpd(j).serie_bfp,
												RES_saldi_rend_bfpd(j).valore_scadenza_lordo_bfp,
												RES_saldi_rend_bfpd(j).flag_lordista_bfp,
												RES_saldi_rend_bfpd(j).importo_netto_bfp,
												RES_saldi_rend_bfpd(j).valore_scadenza_netto_bfp,
												RES_saldi_rend_bfpd(j).valore_nominale_bfp,
												RES_saldi_rend_bfpd(j).datasottoscrizione,
												RES_saldi_rend_bfpd(j).datascadenza
											  );
								
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' INSERT SALDO_REND BFPD - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
	CLOSE saldi_rend_bfpd;

	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' INSERT SALDO_REND BFPD - COMMIT ON ROW: ' || totale);
	COMMIT;
	
	BEGIN
		dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'SALDO_REND', degree => 4, estimate_percent=>10, cascade=>true); 
	END;
    
END;