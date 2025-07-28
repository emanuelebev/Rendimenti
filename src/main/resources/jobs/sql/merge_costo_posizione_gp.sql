DECLARE

CURSOR merge_costo_posizione IS 
		WITH tmp_saldo_rend_sott_gp AS (
        	SELECT DISTINCT portafoglio_id, id_rapporto
        	FROM saldo_rend_sott_gp
		)        
		SELECT /*+ PARALLEL(8) */ 
		    sgp.id_rapporto 																		AS idrapporto,
		    gp.codicetitolo 																		AS codicetitolo,
		    tmp.reason 																				AS codice_costo,
		    TO_NUMBER(TO_CHAR(TO_DATE(tmp.period_end_date, 'YYYY-MM-DD'),           'YYYYMMDD')) 	AS data,
		    tmp.portfolio_id || '_' || tmp.reason || '_' || 
		    	to_number(to_char(to_date(tmp.period_start_date, 'yyyy-mm-dd'), 'yyyymmdd')) || 
		    	'_' || to_number(to_char(to_date(tmp.period_end_date, 'yyyy-mm-dd'), 'yyyymmdd')) || 
		    	'_' || tmp.codicetitolo_interno 													AS numreg,
		    tmp.amount 																				AS importo,
		    'MFM' 																					AS tipo_fonte,
		    TO_NUMBER(TO_CHAR(TO_DATE(tmp.period_start_date, 'YYYY-MM-DD'), 'YYYYMMDD')) 			AS data_da,
		    TO_NUMBER(TO_CHAR(TO_DATE(tmp.period_end_date, 'YYYY-MM-DD'), 'YYYYMMDD')) 				AS data_a,
		    tmp.abi_code 																			AS codice_banca,
		    tmp.portfolio_id 																		AS portfolio_id,
		    tmp.codicetitolo_interno 																AS codice_linea 
		FROM tmp_pfcosti_gp tmp
		-- estraggo l'NDG attraverso il CODICEFISCALE del Cliente
		INNER JOIN ndg ndg
		    ON tmp.identifier_value = ndg.codicefiscale
		-- aggiungo il BridgeGP
		INNER JOIN tbl_bridge_gp gp
		    ON tmp.codicetitolo_interno = gp.codice_linea
		-- filtro sulla SALDO_REND_SOTT_GP per assegnazione univoca sottostanti GP
		INNER JOIN tmp_saldo_rend_sott_gp sgp
			ON tmp.portfolio_id = sgp.portafoglio_id
		ORDER BY idrapporto, codicetitolo, codice_costo, portfolio_id, data;

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
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_POSIZIONE GP - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_POSIZIONE GP - COMMIT ON ROW: ' || I);
	COMMIT;
END;

