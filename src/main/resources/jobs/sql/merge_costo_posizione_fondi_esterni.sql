DECLARE

CURSOR merge_costo_posizione IS    
		SELECT /*+ PARALLEL(8) */ 
		    rapp.id 																					AS idrapporto,
		    sf.codicetitolo 																			AS codicetitolo,
		    tmp.concept 																				AS codice_costo,
		    TO_NUMBER(TO_CHAR(TO_DATE(tmp.period_final_date, 'YYYY-MM-DD'),'YYYYMMDD')) 				AS data,
		    to_number(to_char(to_date(tmp.period_initial_date, 'yyyy-mm-dd'), 'yyyymmdd')) || 
		    	'_' || to_number(to_char(to_date(tmp.period_final_date, 'yyyy-mm-dd'), 'yyyymmdd')) || 
		    	'_' || tmp.source_contract || '_' || tmp.isin || '_' || tmp.concept  														AS numreg,
		    CASE WHEN tmp.sign_amt = '-' THEN (tmp.amount * (-1)) ELSE tmp.amount END					AS importo,
		    'AFB' 																						AS tipo_fonte,
		    TO_NUMBER(TO_CHAR(TO_DATE(tmp.period_initial_date, 'YYYY-MM-DD'), 'YYYYMMDD')) 				AS data_da,
		    TO_NUMBER(TO_CHAR(TO_DATE(tmp.period_final_date, 'YYYY-MM-DD'), 'YYYYMMDD')) 				AS data_a,
		    '07601' 																					AS codice_banca
		FROM tmp_pfcosti_afb tmp
		INNER JOIN rapporto rapp
		    ON tmp.source_contract = rapp.codicerapporto
		INNER JOIN strumentofinanziario sf
			ON tmp.isin = sf.isin
		INNER JOIN tipo_costo tc
			ON tmp.concept = tc.codice
		ORDER BY idrapporto, codicetitolo, codice_costo, data;

I NUMBER(38,0):=0;


BEGIN
				
	FOR cur_item IN merge_costo_posizione
    	LOOP
        I := I+1;

		MERGE INTO costo_posizione cost
		  USING (SELECT cur_item.idrapporto		AS idrapporto,  
						cur_item.codicetitolo	AS codicetitolo,
						cur_item.codice_costo	AS codice_costo, 
						cur_item.data			AS data, 
						cur_item.numreg			AS numreg,      
						cur_item.importo		AS importo,     
						cur_item.tipo_fonte		AS tipo_fonte,  
						cur_item.data_da		AS data_da,     
						cur_item.data_a			AS data_a,      
						cur_item.codice_banca	AS codice_banca	
						
			FROM dual
			) tomerge
		  ON (cost.idrapporto = tomerge.idrapporto
		  	 AND cost.codicetitolo = tomerge.codicetitolo
		  	 AND cost.numreg = tomerge.numreg
		  	 AND cost.codice_costo = tomerge.codice_costo
		  	 AND cost.data = tomerge.data)
		   
	WHEN MATCHED THEN UPDATE
		  SET
			cost.importo = tomerge.importo,
			cost.tipo_fonte = tomerge.tipo_fonte,
			cost.data_da = tomerge.data_da,
			cost.data_a = tomerge.data_a,
			cost.codice_banca = tomerge.codice_banca
  	
	WHEN NOT MATCHED THEN 
			INSERT (idrapporto,  
					codicetitolo,
					codice_costo,
					data,        
					numreg,      
					importo,     
					tipo_fonte,  
					data_da,     
					data_a,      
					codice_banca	
					)
  			VALUES (tomerge.idrapporto,  
					tomerge.codicetitolo,
					tomerge.codice_costo,
					tomerge.data,        
					tomerge.numreg,      
					tomerge.importo,     
					tomerge.tipo_fonte,  
					tomerge.data_da,     
					tomerge.data_a,      
					tomerge.codice_banca	
				);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_POSIZIONE FONDI ESTERNI - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_POSIZIONE FONDI ESTERNI - COMMIT ON ROW: ' || I);
	COMMIT;
END;

