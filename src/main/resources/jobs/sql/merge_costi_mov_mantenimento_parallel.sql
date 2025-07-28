SELECT sum(column_value)
FROM TABLE (PARALLEL_COSTI_MOV_POL (CURSOR (

	SELECT	/*+ PARALLEL(8) */	  
		'07601' 																			AS codice_banca,
  		CASE WHEN mov.codice_attivita = 'MF' THEN 'PZ_FGE'
  			 WHEN mov.codice_attivita = 'PM' THEN 'PZ_FGE_INC' END 							AS codice_costo,
  		RAPP.id    																			AS idrapporto,
  		CASE WHEN mov.codice_attivita = 'MF' THEN mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza
					||'_'||mov.data_comunicazione_pagamento||'_'||mov.cf_beneficiario
					||'_'||mov.modalita_pagamento||'_'||mov.codice_fondo|| '_' || 'PZ_FGE'
  			WHEN mov.codice_attivita = 'PM' THEN mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza
  				 	||'_'||mov.data_comunicazione_pagamento||'_'||mov.cf_beneficiario
					||'_'||mov.modalita_pagamento||'_'||mov.codice_fondo|| '_' || 'PZ_FGE_INC'				
																END 						AS numreg,
  		m.ctv																				AS importo,
  		'CM' 																				AS tipo_fonte,
  		null 																				AS data_da,
  		null 																				AS data_a,
  		sysdate 																			AS data_aggiornamento,
  		null 																				AS ssa
  FROM TEMP_MOV_PAG_FONDO MOV
 	 INNER JOIN RAPPORTO RAPP 
 	 	ON RAPP.codicerapporto = LPAD(trim(MOV.numero_polizza),12,'0')
 	 		AND RAPP.tipo = '13'
 	 INNER JOIN MOVIMENTO M
     	 ON (CASE WHEN mov.codice_attivita = 'MF' THEN mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza
					||'_'||mov.data_comunicazione_pagamento||'_'||mov.cf_beneficiario
					||'_'||mov.modalita_pagamento||'_'||mov.codice_fondo|| '_' || 'PZ_FGE'
  			WHEN mov.codice_attivita = 'PM' THEN mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza
  				 	||'_'||mov.data_comunicazione_pagamento||'_'||mov.cf_beneficiario
					||'_'||mov.modalita_pagamento||'_'||mov.codice_fondo|| '_' || 'PZ_FGE_INC'				
																END ) = m.numreg
		AND rapp.id = m.idrapporto
  WHERE codice_attivita in ('MF', 'PM') 
  ORDER BY idrapporto, numreg, codice_costo

)));