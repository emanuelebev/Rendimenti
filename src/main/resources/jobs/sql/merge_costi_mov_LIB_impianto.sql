--PTR-215 - BFP eliminare la generazione del costo con codice 'TASSE BFP'

DECLARE 

    rowcounts NUMBER;
    

BEGIN
   
	MERGE INTO
	    costo_movimento cmov
	 USING (
	          SELECT   
	          		'07601'			 	AS codice_banca,
	          		'TASSE LIB' 		AS codice_costo,
	          		mov.idrapporto 		AS idrapporto,
	          		mov.numreg 			AS numreg,
	          		mov.tassazione 		AS importo,
	          		'CM' 				AS tipo_fonte,
	          		NULL 				AS data_da,
	          		NULL 				AS data_a,
	          		sysdate 			AS data_aggiornamento
	          FROM movimento mov
	         	 INNER JOIN rapporto rapp 
	         	 	ON mov.idrapporto = rapp.ID
	          WHERE rapp.tipo = '02'
	          AND (mov.tassazione IS NOT NULL AND mov.tassazione <> '0')
	        ) tomerge
	  ON
	  (cmov.idrapporto = tomerge.idrapporto
	   AND cmov.numreg = tomerge.numreg
	   AND cmov.codice_banca = tomerge.codice_banca
	   AND cmov.codice_costo = tomerge.codice_costo) 
	    
	   WHEN MATCHED THEN UPDATE
	  SET  	
	  	cmov.importo = tomerge.importo,
	  	cmov.tipo_fonte = tomerge.tipo_fonte,
	  	cmov.data_da = tomerge.data_da,
	  	cmov.data_a = tomerge.data_a,
	  	cmov.data_aggiornamento = tomerge.data_aggiornamento
	  	
	  	WHEN NOT MATCHED THEN
	  INSERT
	    (	codice_banca,
		  	codice_costo,
		  	idrapporto,
		  	numreg,
		  	importo,
		  	tipo_fonte,
		  	data_da,
		  	data_a,
		  	data_aggiornamento
		 )
	  VALUES 
	  (	  	tomerge.codice_banca,
		  	tomerge.codice_costo,
		  	tomerge.idrapporto,
		  	tomerge.numreg,
		  	tomerge.importo,
		  	tomerge.tipo_fonte,
		  	tomerge.data_da,
		  	tomerge.data_a,
		  	tomerge.data_aggiornamento
		);
		
		rowcounts := SQL%rowcount;
		
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI TASSE LIB IN COSTO_MOVIMENTO: ' || rowcounts);
		COMMIT;
  
END;