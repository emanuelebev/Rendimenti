SELECT sum(column_value)
FROM TABLE (PARALLEL_SALDI_REND (CURSOR (

	SELECT	/*+ PARALLEL(4) index(rapp IX_RAP_SALDIREND2) index(tsr IX_TMP_PFSALDISTORICI2) */
			rapp.idptf																							AS idptf,
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
		WHERE RAPP.id_buono_originario is not null
		ORDER BY rapp.idptf, tsr.codiceinterno, tsr.datasaldo
)));