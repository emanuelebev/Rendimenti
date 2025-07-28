SELECT sum(column_value)
FROM TABLE (PARALLEL_COSTI_MOV_POL (CURSOR (

	SELECT	/*+ PARALLEL(8) */	  
		'07601' 						as codice_banca,
  		'PZ_INTERESSE_MORA' 			as codice_costo,
  		RAPP.id    						as idrapporto,
  		MOV.numero_polizza||'_'||MOV.codice_prodotto||'_'||MOV.ramo||'_'||MOV.tipo_titolo||'_'||MOV.data_valuta||'_'||MOV.codice_motivo_storno
		||'_'||MOV.data_carico||'_'||MOV.data_competenza||'_'||MOV.data_effetto_titolo	 			
										as numreg,
  		MOV.interesse_mora_coass		as importo,
  		'CM' 							as tipo_fonte,
  		null 							as data_da,
  		null 							as data_a,
  		sysdate 						as data_aggiornamento,
  		null 							as ssa
  FROM TMP_PFMOV_INC_COASS MOV
 	 INNER JOIN RAPPORTO RAPP 
 	 	ON RAPP.codicerapporto = LPAD(trim(MOV.numero_polizza),12,'0')
 	 		AND RAPP.tipo = '13'
 	 INNER JOIN movimento m
 	 ON MOV.numero_polizza||'_'||MOV.codice_prodotto||'_'||MOV.ramo||'_'||MOV.tipo_titolo||'_'||MOV.data_valuta||'_'||MOV.codice_motivo_storno
		||'_'||MOV.data_carico||'_'||MOV.data_competenza||'_'||MOV.data_effetto_titolo = m.numreg
	AND rapp.id = m.idrapporto
  WHERE mov.interesse_mora_coass != 0
  ORDER BY idrapporto, numreg, codice_costo

)));