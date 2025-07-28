DECLARE

CURSOR filtro_mov_gp_doppi IS
	SELECT ROWID
	FROM (
		SELECT ROWID,  
		row_number() OVER (PARTITION BY codice_transazione, data_settlement, data_transazione, numero_deposito, 
										numero_sottodeposito, codicetitolo_interno, importo_transato, causale_movimento, 
										quantita_ordinata, quantita_effettiva, segno, commissioni, divisa_trattazione, 
										cambio, canale_ordine, ndg, codicefiscale, id_prodotto, upfront_fee_lorda, upfront_fee_netta, upfront_fee_retrocessioni
		ORDER BY codice_transazione, data_settlement, data_transazione, numero_deposito, 
										numero_sottodeposito, codicetitolo_interno, importo_transato, causale_movimento, 
										quantita_ordinata, quantita_effettiva, segno, commissioni, divisa_trattazione, 
										cambio, canale_ordine, ndg, codicefiscale, id_prodotto, upfront_fee_lorda, upfront_fee_netta, upfront_fee_retrocessioni )
										AS pos
		FROM tmp_pfmov_gp
	) 
	WHERE pos > 1;
       
I NUMBER(38,0):=0;


BEGIN
	
FOR cur_item IN filtro_mov_gp_doppi

	LOOP 			
	
	 I := I+1;
	 
	DELETE FROM tmp_pfmov_gp tmp_del
	WHERE tmp_del.ROWID = cur_item.ROWID;
					
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_GP - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
					
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' FILTRO DOPPI TMP_PFMOV_GP. RECORD ELIMINATI: '|| I);
		
COMMIT;

END;