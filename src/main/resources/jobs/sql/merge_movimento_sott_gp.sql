DECLARE

CURSOR merge_mov_sott_gp IS 
	SELECT 	/*+ PARALLEL(8) */	  
			tmp.codice_transazione 			AS codice_transazione,
			tmp.data_settlement 			AS data_settlement,
			tmp.data_transazione 			AS data_transazione,
			tmp.numero_deposito 			AS numero_deposito,
			tmp.numero_sottodeposito 		AS numero_sottodeposito,
			tmp.codicetitolo_interno 		AS codicetitolo_interno,
			tmp.importo_transato 			AS importo_transato,
			tmp.causale_movimento 			AS causale_movimento,
			tmp.quantita_ordinata 			AS quantita_ordinata,
			tmp.quantita_effettiva 			AS quantita_effettiva,
			tmp.segno 						AS segno,
			tmp.commissioni 				AS commissioni,
			tmp.divisa_trattazione 			AS divisa_trattazione,
			tmp.cambio 						AS cambio,
			tmp.canale_ordine 				AS canale_ordine,
			tmp.ndg 						AS ndg,
			tmp.codicefiscale 				AS codicefiscale,
			tmp.upfront_fee_lorda			AS upfront_fee_lorda, 
			tmp.upfront_fee_netta			AS upfront_fee_netta, 	
			tmp.upfront_fee_retrocessioni	AS upfront_fee_retrocessioni
	FROM tmp_pfmov_gp tmp;

I NUMBER(38,0):=0;


BEGIN
				
	FOR cur_item IN merge_mov_sott_gp
    	LOOP
        I := I+1;

		MERGE INTO movimento_sott_gp mov
		  USING (SELECT cur_item.codice_transazione 		AS codice_transazione,
						cur_item.data_settlement 			AS data_settlement,
						cur_item.data_transazione 			AS data_transazione,
						cur_item.numero_deposito 			AS numero_deposito,
						cur_item.numero_sottodeposito 		AS numero_sottodeposito,
						cur_item.codicetitolo_interno 		AS codicetitolo_interno,
						cur_item.importo_transato 			AS importo_transato,
						cur_item.causale_movimento 			AS causale_movimento,
						cur_item.quantita_ordinata 			AS quantita_ordinata,
						cur_item.quantita_effettiva 		AS quantita_effettiva,
						cur_item.segno 						AS segno,
						cur_item.commissioni 				AS commissioni,
						cur_item.divisa_trattazione 		AS divisa_trattazione,
						cur_item.cambio 					AS cambio,
						cur_item.canale_ordine 				AS canale_ordine,
						cur_item.ndg 						AS ndg,
						cur_item.codicefiscale 				AS codicefiscale,
						cur_item.upfront_fee_lorda			AS upfront_fee_lorda, 
						cur_item.upfront_fee_netta			AS upfront_fee_netta, 	
						cur_item.upfront_fee_retrocessioni	AS upfront_fee_retrocessioni
			FROM dual
			) tomerge
		  ON (mov.codice_transazione = tomerge.codice_transazione)
		   
	WHEN MATCHED THEN UPDATE
		  SET
			mov.data_settlement = tomerge.data_settlement,
			mov.data_transazione = tomerge.data_transazione,
			mov.numero_deposito = tomerge.numero_deposito,
			mov.numero_sottodeposito = tomerge.numero_sottodeposito,
			mov.codicetitolo_interno = tomerge.codicetitolo_interno,
			mov.importo_transato = tomerge.importo_transato,
			mov.causale_movimento = tomerge.causale_movimento,
			mov.quantita_ordinata = tomerge.quantita_ordinata,
			mov.quantita_effettiva = tomerge.quantita_effettiva,
			mov.segno = tomerge.segno,
			mov.commissioni = tomerge.commissioni,
			mov.divisa_trattazione = tomerge.divisa_trattazione,
			mov.cambio = tomerge.cambio,
			mov.canale_ordine = tomerge.canale_ordine,
			mov.ndg = tomerge.ndg,
			mov.codicefiscale = tomerge.codicefiscale,
			mov.upfront_fee_lorda = tomerge.upfront_fee_lorda,
			mov.upfront_fee_netta = tomerge.upfront_fee_netta,
			mov.upfront_fee_retrocessioni= tomerge.upfront_fee_retrocessioni
  	
	WHEN NOT MATCHED THEN 
			INSERT (codice_transazione,
					data_settlement,
					data_transazione,
					numero_deposito,
					numero_sottodeposito,
					codicetitolo_interno,
					importo_transato,
					causale_movimento,
					quantita_ordinata,
					quantita_effettiva,
					segno,
					commissioni,
					divisa_trattazione,
					cambio,
					canale_ordine,
					ndg,
					codicefiscale,
					upfront_fee_lorda, 
					upfront_fee_netta, 	
					upfront_fee_retrocessioni
					)
  			VALUES (
  					tomerge.codice_transazione,
  					tomerge.data_settlement,
					tomerge.data_transazione,
					tomerge.numero_deposito,
					tomerge.numero_sottodeposito,
					tomerge.codicetitolo_interno,
					tomerge.importo_transato,
					tomerge.causale_movimento,
					tomerge.quantita_ordinata,
					tomerge.quantita_effettiva,
					tomerge.segno,
					tomerge.commissioni,
					tomerge.divisa_trattazione,
					tomerge.cambio,
					tomerge.canale_ordine,
					tomerge.ndg,
					tomerge.codicefiscale,
					tomerge.upfront_fee_lorda, 
					tomerge.upfront_fee_netta, 	
					tomerge.upfront_fee_retrocessioni
				);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MOVIMENTO_SOTT_GP - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE MOVIMENTO_SOTT_GP - COMMIT ON ROW: ' || I);
	COMMIT;
END;

