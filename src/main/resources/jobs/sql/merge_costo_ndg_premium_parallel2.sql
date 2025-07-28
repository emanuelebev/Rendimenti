SELECT sum(column_value)
FROM TABLE (PARALLEL_COSTI_NDG (CURSOR (

	SELECT	/*+ PARALLEL(8) */	 
  		'07601' 								AS codice_banca,
  		'PZ_DIRFISSO' 							AS codice_costo,
  		RAPP.ndg								AS ndg,
  		RAPP.id    								AS idrapporto,
  		MOV.numero_polizza||'_'||MOV.codice_prodotto||'_'||MOV.ramo||'_'||MOV.tipo_titolo||'_'||MOV.data_valuta||'_'||MOV.codice_motivo_storno
		||'_'||MOV.data_carico||'_'||MOV.data_competenza||'_'||MOV.data_effetto_titolo	 			
												AS numreg,
  		MOV.diritto_fisso_coass 				AS importo,
  		'CM' 									AS tipo_fonte,
  		null 									AS data_da,
  		null 									AS data_a,
  		m.data									AS data
  FROM TMP_PFMOV_INC_COASS MOV
 	 INNER JOIN rapporto RAPP 
 	 	ON RAPP.codicerapporto = LPAD(trim(MOV.numero_polizza),12,'0')
 	 		AND RAPP.tipo = '13'
 	 INNER JOIN MOVIMENTO_RAMO_TERZO M
     	 ON MOV.numero_polizza||'_'||MOV.codice_prodotto||'_'||MOV.ramo||'_'||MOV.tipo_titolo||'_'||MOV.data_valuta||'_'||MOV.codice_motivo_storno
			||'_'||MOV.data_carico||'_'||MOV.data_competenza||'_'||MOV.data_effetto_titolo = m.numreg
		AND rapp.id = m.idrapporto
  WHERE mov.diritto_fisso_coass != 0
  ORDER BY idrapporto, numreg, codice_costo, data

)));