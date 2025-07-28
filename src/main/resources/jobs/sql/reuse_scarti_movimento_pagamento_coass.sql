DECLARE

CURSOR del_cur IS
	SELECT /*+ parallel(8) */ scarto.ROWID AS scarto_rowid, 
			scarto.*, 
			tmp.ROWID AS tmp_rowid
	FROM tbl_scarti_tmp_pfmov_pag_coass scarto
	LEFT JOIN tmp_pfmov_pag_coass tmp
		ON tmp.numero_polizza||tmp.codice_prodotto||tmp.ramo||tmp.tipo_liquidazione||tmp.data_valuta||tmp.codice_fiscale_beneficiario||
									tmp.data_comunicazione_pagamento||tmp.modalita_pagamento||tmp.codice_frazionamento = 
			scarto.numero_polizza||scarto.codice_prodotto||scarto.ramo||scarto.tipo_liquidazione||scarto.data_valuta||scarto.codice_fiscale_beneficiario||
									scarto.data_comunicazione_pagamento||scarto.modalita_pagamento||scarto.codice_frazionamento
		AND tmp.numero_polizza = scarto.numero_polizza
	WHERE scarto.riproponibile = 'S';

I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN

	FOR cur_item IN del_cur 

		LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
		INSERT /*+ append nologging parallel(8) */
				INTO TMP_PFMOV_PAG_COASS (	ramo,
											codice_prodotto,
											numero_polizza,
											data_comunicazione_pagamento,
											codice_fiscale_beneficiario,
											modalita_pagamento,
											frazionario_di_emissione,
											tipo_liquidazione,
											codice_frazionamento,
											data_effetto_polizza,
											data_scadenza,
											data_valuta,
											data_competenza,
											codice_fiscale_contraente,
											strumento_di_pagamento,
											importo_pagato,
											interesse_mora,
											ritenuta_interesse_mora,
											costo_liquidazione,
											imposta_sostitutiva,
											imposta_bollo,
											importo_pagato_coass, 
											costo_liquidazione_coass,
											imposta_sostitutiva_coass,
											imposta_bollo_coass,
											interesse_mora_coass,
											ritenuta_interesse_mora_coass,
											data_calcolo_pagamento,
											costo_etf, 
											numero_pratica,
											codice_linea
										)
								VALUES (cur_item.ramo,
										cur_item.codice_prodotto,
										cur_item.numero_polizza,
										cur_item.data_comunicazione_pagamento,
										cur_item.codice_fiscale_beneficiario,
										cur_item.modalita_pagamento,
										cur_item.frazionario_di_emissione,
										cur_item.tipo_liquidazione,
										cur_item.codice_frazionamento,
										cur_item.data_effetto_polizza,
										cur_item.data_scadenza,
										cur_item.data_valuta,
										cur_item.data_competenza,
										cur_item.codice_fiscale_contraente,
										cur_item.strumento_di_pagamento,
										to_number(cur_item.importo_pagato, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.interesse_mora, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.ritenuta_interesse_mora, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.costo_liquidazione, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.imposta_sostitutiva, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.imposta_bollo, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.importo_pagato_coass, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.costo_liquidazione_coass, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.imposta_sostitutiva_coass, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.imposta_bollo_coass, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.interesse_mora_coass, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.ritenuta_interesse_mora_coass, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.data_calcolo_pagamento,
										to_number(cur_item.costo_etf, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.numero_pratica,
										cur_item.codice_linea
								);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM tbl_scarti_tmp_pfmov_pag_coass tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_PAG_COASS. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_PAG_COASS. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;