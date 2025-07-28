DECLARE

CURSOR update_inc IS
SELECT	/*+ PARALLEL(8) */	  
		'07601' 																			AS codice_banca,
  		'PZ_FGE'  																			AS codice_costo,
  		rapp.ID    																			AS idrapporto,
  		mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza||'_'||
  		mov.data_comunicazione_pagamento||'_'||mov.cf_beneficiario
		||'_'||mov.modalita_pagamento||'_'||mov.codice_fondo|| '_' || 'PZ_FGE' 		 		AS numreg,
  		M.ctv																				AS importo,
  		'CM' 																				AS tipo_fonte,
  		NULL 																				AS data_da,
  		NULL 																				AS data_a,
  		sysdate 																			AS data_aggiornamento,
  		NULL 																				AS ssa
  FROM TEMP_MOV_PAG_FONDO mov
 	 INNER JOIN rapporto rapp 
 	 	ON rapp.codicerapporto = lpad(TRIM(mov.numero_polizza),12,'0')
 	 		AND rapp.tipo = '13'
 	 INNER JOIN movimento M
     	 ON (mov.ramo||'_'||mov.codice_prodotto||'_'||mov.numero_polizza||'_'||
  		mov.data_comunicazione_pagamento||'_'||mov.cf_beneficiario
		||'_'||mov.modalita_pagamento||'_'||mov.codice_fondo|| '_' || 'PZ_FGE_INC') = M.numreg
		AND rapp.ID = M.idrapporto
  WHERE codice_attivita = 'PM' 
  ORDER BY idrapporto, numreg, codice_costo;

				 
TYPE update_inc_type IS TABLE OF update_inc%rowtype INDEX BY PLS_INTEGER;

res_update_inc update_inc_type;
	
ROWS    PLS_INTEGER := 10000;

I 		NUMBER(38,0):=0;
totale	NUMBER(38,0):=0;


BEGIN
	    
	OPEN update_inc; 
		LOOP
			FETCH update_inc BULK COLLECT INTO res_update_inc LIMIT ROWS;
				EXIT WHEN res_update_inc.COUNT = 0;  
			
			I:=0;
			I:= res_update_inc.COUNT;
			totale := totale + I;
				
		FORALL j IN res_update_inc.FIRST .. res_update_inc.LAST		

		MERGE INTO costo_movimento cmov
		  USING (SELECT res_update_inc(j).codice_banca			 AS codice_banca,
						res_update_inc(j).codice_costo			 AS codice_costo,
						res_update_inc(j).idrapporto			 AS idrapporto,
						res_update_inc(j).numreg		 	     AS numreg,
						res_update_inc(j).importo   			 AS importo,
						res_update_inc(j).tipo_fonte			 AS tipo_fonte,
						res_update_inc(j).data_da				 AS data_da,
						res_update_inc(j).data_a				 AS data_a,
						res_update_inc(j).data_aggiornamento	 AS data_aggiornamento,
						res_update_inc(j).ssa           		 AS ssa
				FROM dual
			) tomerge
			 	ON (cmov.idrapporto = tomerge.idrapporto
			 		AND cmov.numreg = tomerge.numreg
			 		AND cmov.codice_costo = tomerge.codice_costo)

		WHEN MATCHED THEN UPDATE
				  SET 	cmov.codice_banca = tomerge.codice_banca,
						cmov.importo = (cmov.importo - tomerge.importo),
						cmov.tipo_fonte = tomerge.tipo_fonte,
						cmov.data_da = tomerge.data_da,
						cmov.data_a = tomerge.data_a,
						cmov.data_aggiornamento = tomerge.data_aggiornamento,
						cmov.ssa = tomerge.ssa                   
		;
                    
        COMMIT;
		
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE COSTO_MOVIMENTO INCENTIVI: ' || I || ' RECORD');
	
	END LOOP;
	
	CLOSE update_inc;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE COSTO_MOVIMENTO INCENTIVI: ' || totale);
	COMMIT;
	
END;