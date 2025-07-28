SELECT sum(column_value)
FROM TABLE (PARALLEL_COSTI_NDG (CURSOR (

	SELECT	/*+ PARALLEL(8) */	  
		'07601' 								AS codice_banca,
  		'PZ_IMPSOSTITUTIVA'						AS codice_costo,
  		RAPP.ndg								AS ndg,
  		RAPP.ID									AS idrapporto,
  		MOV.numero_polizza||'_'||MOV.codice_prodotto||'_'||MOV.ramo||'_'||MOV.tipo_liquidazione||'_'||MOV.data_valuta||'_'||MOV.codice_fiscale_beneficiario
		||'_'||MOV.data_comunicazione_pagamento||'_'||MOV.modalita_pagamento||'_'||MOV.codice_frazionamento	 				
												AS numreg,
  		MOV.imposta_sostitutiva_coass			AS importo,
  		'CM' 									AS tipo_fonte,
  		null 									AS data_da,
  		null 									AS data_a,
  		m.data									AS data
  FROM TMP_PFMOV_PAG_COASS MOV
 	 INNER JOIN RAPPORTO RAPP 
 	 	ON RAPP.codicerapporto = LPAD(trim(MOV.numero_polizza),12,'0')
 	 		AND RAPP.tipo = '13'
 	 INNER JOIN MOVIMENTO_RAMO_TERZO M
 	 ON MOV.numero_polizza||'_'||MOV.codice_prodotto||'_'||MOV.ramo||'_'||MOV.tipo_liquidazione||'_'||MOV.data_valuta||'_'||MOV.codice_fiscale_beneficiario
		||'_'||MOV.data_comunicazione_pagamento||'_'||MOV.modalita_pagamento||'_'||MOV.codice_frazionamento = m.numreg
	AND rapp.id = m.idrapporto
  WHERE mov.imposta_sostitutiva_coass != 0 
  ORDER BY idrapporto, numreg, codice_costo, data

)));