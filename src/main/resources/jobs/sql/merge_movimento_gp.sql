DECLARE

CURSOR merge_mov_gp IS 
	SELECT 	/*+ PARALLEL(8) */	  
			r.id																					AS idrapporto,
			tmp.codice_transazione																	AS numreg,
			TO_NUMBER(TO_CHAR(TO_DATE(data_settlement, 'YYYY-MM-DD'), 'YYYYMMDD')) 					AS data,
			TO_NUMBER(TO_CHAR(TO_DATE(data_settlement, 'YYYY-MM-DD'), 'YYYYMMDD')) 					AS valuta,
			gp.codicetitolo																			AS codicetitolo,			
			CASE WHEN causale_movimento = 'RIMB' THEN tmp.importo_transato * (-1)
			     ELSE tmp.importo_transato END 														AS ctv,
			'GP_' || causale_movimento																AS causale,
			CASE WHEN causale_movimento = 'RIMB' THEN tmp.quantita_ordinata * (-1)
			     ELSE tmp.quantita_ordinata END  													AS ctvnetto,
			CASE WHEN tmp.segno = '-' THEN (tmp.commissioni * (-1))
				ELSE tmp.commissioni END															AS spesecomm,
			tmp.divisa_trattazione																	AS divisa,
			tmp.cambio																				AS cambio,
			tmp.canale_ordine																		AS c_canale,
			'N'																						AS flag_fittiziocosti,
			tmp.upfront_fee_lorda																	AS upfront_fee_lorda, 
			tmp.upfront_fee_netta																	AS upfront_fee_netta, 	
			tmp.upfront_fee_retrocessioni															AS upfront_fee_retrocessioni
	FROM tmp_pfmov_gp tmp
		INNER JOIN rapporto r
			ON r.codicerapporto = tmp.numero_deposito || tmp.numero_sottodeposito
		INNER JOIN tbl_bridge_gp gp
    		ON tmp.codicetitolo_interno = gp.codice_linea
	ORDER BY r.id, tmp.codice_transazione;

I NUMBER(38,0):=0;


BEGIN
				
	FOR cur_item IN merge_mov_gp
    	LOOP
        I := I+1;

		MERGE INTO movimento mov
		  USING (SELECT cur_item.idrapporto 				AS idrapporto,
						cur_item.numreg 					AS numreg,
						cur_item.data						AS data,
						cur_item.valuta 					AS valuta,
						cur_item.codicetitolo				AS codicetitolo,
						cur_item.ctv 						AS ctv,
						cur_item.causale 					AS causale,
						cur_item.ctvnetto 					AS ctvnetto,
						cur_item.spesecomm 					AS spesecomm,
						cur_item.divisa 					AS divisa,
						cur_item.cambio     				AS cambio,      
						cur_item.c_canale 					AS c_canale,
						cur_item.flag_fittiziocosti			AS flag_fittiziocosti,
						cur_item.upfront_fee_lorda			AS upfront_fee_lorda, 
						cur_item.upfront_fee_netta			AS upfront_fee_netta, 	
						cur_item.upfront_fee_retrocessioni	AS upfront_fee_retrocessioni
						
			FROM dual
			) tomerge
		  ON (mov.idrapporto = tomerge.idrapporto
		  	 AND mov.numreg = tomerge.numreg)
		   
	WHEN MATCHED THEN UPDATE
		  SET
			mov.data = tomerge.data,
			mov.valuta = tomerge.valuta,
			mov.codicetitolo = tomerge.codicetitolo,
			mov.ctv = tomerge.ctv,
			mov.causale = tomerge.causale,
			mov.ctvnetto = tomerge.ctvnetto,
			mov.spesecomm = tomerge.spesecomm,
			mov.divisa = tomerge.divisa,
			mov.cambio = tomerge.cambio,
			mov.c_canale = tomerge.c_canale,
			mov.flag_fittiziocosti = tomerge.flag_fittiziocosti,
			mov.upfront_fee_lorda = tomerge.upfront_fee_lorda,
			mov.upfront_fee_netta = tomerge.upfront_fee_netta,
			mov.upfront_fee_retrocessioni = tomerge.upfront_fee_retrocessioni
  	
	WHEN NOT MATCHED THEN 
			INSERT (idrapporto,
					numreg,
					data,
					valuta,
					codicetitolo,
					ctv,
					causale,
					ctvnetto,
					spesecomm,
					divisa,
					cambio,
					c_canale,
					flag_fittiziocosti,
					upfront_fee_lorda, 
					upfront_fee_netta, 	
					upfront_fee_retrocessioni
					)
  			VALUES (tomerge.idrapporto,
					tomerge.numreg,
					tomerge.data,
					tomerge.valuta,
					tomerge.codicetitolo,
					tomerge.ctv,
					tomerge.causale,
					tomerge.ctvnetto,
					tomerge.spesecomm,
					tomerge.divisa,
					tomerge.cambio,
					tomerge.c_canale,
					tomerge.flag_fittiziocosti,
					tomerge.upfront_fee_lorda,
					tomerge.upfront_fee_netta,
					tomerge.upfront_fee_retrocessioni
					);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE MOVIMENTI GP - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE MOVIMENTI GP - COMMIT ON ROW: ' || I);
	COMMIT;
END;

