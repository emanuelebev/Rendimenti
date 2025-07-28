SELECT sum(column_value)
FROM TABLE (PARALLEL_COSTI_MOV_POL (CURSOR (

	SELECT	/*+ PARALLEL(8) */	  
		'07601' 												AS codice_banca,
  		'TRN' 													AS codice_costo,
  		RAPP.id    												AS idrapporto,
  		mov.id_titolo||'_'||mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza||'_'||mov.tipo_titolo||'_'||mov.data_effetto_titolo
				||'_'||mov.codice_motivo_storno||'_'||mov.data_carico||'_'||mov.codice_fondo			
																AS numreg,
  		mov.costo_etf											AS importo,
  		'CM' 													as tipo_fonte,
  		null 													AS data_da,
  		null 													AS data_a,
  		sysdate						 							AS data_aggiornamento,
  		null 													AS ssa
  FROM TMP_PFMOV_INC_FONDO MOV
 	 INNER JOIN RAPPORTO RAPP 
 	 	ON RAPP.codicerapporto = LPAD(trim(MOV.numero_polizza),12,'0')
 	 		AND RAPP.tipo = '13'
 	 INNER JOIN MOVIMENTO M
     	 ON mov.id_titolo||'_'||mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza||'_'||mov.tipo_titolo||'_'||mov.data_effetto_titolo
				||'_'||mov.codice_motivo_storno||'_'||mov.data_carico||'_'||mov.codice_fondo = m.numreg
		AND rapp.id = m.idrapporto
  WHERE mov.costo_etf != 0
  ORDER BY idrapporto, numreg, codice_costo

)));