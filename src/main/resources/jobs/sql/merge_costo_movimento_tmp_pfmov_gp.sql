DECLARE

CURSOR merge_costo_movimento IS 
	SELECT 	/*+ PARALLEL(8) */	  
			'07601'																	as codice_banca,
			r.id																	as idrapporto,
			tmp.codice_transazione													as numreg,
			'MFM'																	as tipo_fonte,
			nvl(tmp.upfront_fee_lorda, 0) - nvl(tmp.upfront_fee_netta, 0) 			as importo_vat_tax,
			nvl(tmp.upfront_fee_netta, 0) - nvl(tmp.upfront_fee_retrocessioni, 0) 	as importo_upfront_fee_netta,
			nvl(tmp.upfront_fee_retrocessioni, 0) 									as importo_upfront_fee_ret,
			trunc(sysdate)															as data_aggiornamento
	FROM tmp_pfmov_gp tmp
		INNER JOIN rapporto r
			ON r.codicerapporto = tmp.numero_deposito || tmp.numero_sottodeposito
		INNER JOIN tbl_bridge_gp gp
    		ON tmp.codicetitolo_interno = gp.codice_linea
	ORDER BY r.id, tmp.codice_transazione;

I NUMBER(38,0):=0;


BEGIN
				
	FOR cur_item IN merge_costo_movimento
    	LOOP
        I := I+1;
        
        /*merge per MFM_vat-tax*/

		MERGE INTO costo_movimento cost
		  USING (SELECT cur_item.codice_banca		as codice_banca, 
						'MFM_vat-tax'				as codice_costo, 
						cur_item.idrapporto			as idrapporto, 
						cur_item.numreg				as numreg,  
						cur_item.importo_vat_tax 	as importo,
						cur_item.data_aggiornamento	as data_aggiornamento
						
			FROM dual
			) tomerge
		  ON (cost.idrapporto = tomerge.idrapporto
		  	 AND cost.numreg = tomerge.numreg
		  	 AND cost.codice_costo = tomerge.codice_costo
		  	 )
		   
	WHEN MATCHED THEN UPDATE
		  SET
			cost.codice_banca = tomerge.codice_banca,
			cost.importo = tomerge.importo,
			cost.data_aggiornamento = tomerge.data_aggiornamento
  	
	WHEN NOT MATCHED THEN 
			INSERT (codice_banca,  
					codice_costo,
					idrapporto,
					numreg,        
					importo,      
					data_aggiornamento
					)
  			VALUES (tomerge.codice_banca,  
					tomerge.codice_costo,
					tomerge.idrapporto,
					tomerge.numreg,        
					tomerge.importo,      
					tomerge.data_aggiornamento     
				);
				
	 I := I+1;
	 
	/*merge per MFM_upfront-fee-netta*/

		MERGE INTO costo_movimento cost
		  USING (SELECT cur_item.codice_banca				as codice_banca, 
						'MFM_upfront-fee-netta'				as codice_costo, 
						cur_item.idrapporto					as idrapporto, 
						cur_item.numreg						as numreg,  
						cur_item.importo_upfront_fee_netta 	as importo,
						cur_item.data_aggiornamento			as data_aggiornamento
						
			FROM dual
			) tomerge
		  ON (cost.idrapporto = tomerge.idrapporto
		  	 AND cost.numreg = tomerge.numreg
		  	 AND cost.codice_costo = tomerge.codice_costo
		  	 )
		   
	WHEN MATCHED THEN UPDATE
		  SET
			cost.codice_banca = tomerge.codice_banca,
			cost.importo = tomerge.importo,
			cost.data_aggiornamento = tomerge.data_aggiornamento
  	
	WHEN NOT MATCHED THEN 
			INSERT (codice_banca,  
					codice_costo,
					idrapporto,
					numreg,        
					importo,      
					data_aggiornamento
					)
  			VALUES (tomerge.codice_banca,  
					tomerge.codice_costo,
					tomerge.idrapporto,
					tomerge.numreg,        
					tomerge.importo,      
					tomerge.data_aggiornamento     
				);
				
	I := I+1;
	 
	/*merge per MFM_retrocessioni upfront-fee*/

		MERGE INTO costo_movimento cost
		  USING (SELECT cur_item.codice_banca				as codice_banca, 
						'MFM_retrocessioni upfront-fee'		as codice_costo, 
						cur_item.idrapporto					as idrapporto, 
						cur_item.numreg						as numreg,  
						cur_item.importo_upfront_fee_ret 	as importo,
						cur_item.data_aggiornamento			as data_aggiornamento
						
			FROM dual
			) tomerge
		  ON (cost.idrapporto = tomerge.idrapporto
		  	 AND cost.numreg = tomerge.numreg
		  	 AND cost.codice_costo = tomerge.codice_costo
		  	 )
		   
	WHEN MATCHED THEN UPDATE
		  SET
			cost.codice_banca = tomerge.codice_banca,
			cost.importo = tomerge.importo,
			cost.data_aggiornamento = tomerge.data_aggiornamento
  	
	WHEN NOT MATCHED THEN 
			INSERT (codice_banca,  
					codice_costo,
					idrapporto,
					numreg,        
					importo,      
					data_aggiornamento
					)
  			VALUES (tomerge.codice_banca,  
					tomerge.codice_costo,
					tomerge.idrapporto,
					tomerge.numreg,        
					tomerge.importo,      
					tomerge.data_aggiornamento     
				);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_MOVIMENTO GP - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_MOVIMENTO GP - COMMIT ON ROW: ' || I);
	COMMIT;
END;

