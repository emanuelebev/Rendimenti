DECLARE

CURSOR del_cur IS
	SELECT /*+ parallel(8) */ scarto.ROWID AS scarto_rowid, 
			scarto.*, 
			tmp.ROWID AS tmp_rowid
	FROM tbl_scarti_tmp_pfmov_inc_coass scarto
	LEFT JOIN tmp_pfmov_inc_coass tmp
		ON tmp.numero_polizza||tmp.codice_prodotto||tmp.ramo||tmp.tipo_titolo||tmp.data_valuta||tmp.codice_motivo_storno||tmp.data_carico||tmp.data_competenza||tmp.data_effetto_titolo = 
		   scarto.numero_polizza||scarto.codice_prodotto||scarto.ramo||scarto.tipo_titolo||scarto.data_valuta||scarto.codice_motivo_storno||scarto.data_carico||scarto.data_competenza||scarto.data_effetto_titolo
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
				INTO TMP_PFMOV_INC_COASS (	ramo, 						 
											codice_prodotto, 			 
											numero_polizza,				 
											tipo_titolo, 				 
											data_effetto_titolo, 		 
											data_effetto_polizza,		 
											frazionario_di_emissione, 	 
											codice_frazionamento, 		 
											data_scadenza, 				 
											data_valuta, 				 
											data_competenza, 			 
											codice_fiscale_contraente, 	 
											premio_lordo, 				 
											premio_netto, 				 
											premio_puro, 				 
											premio_imponibile, 			 
											caricamento, 				 
											diritto_fisso, 				 
											codice_motivo_storno, 		 
											provvigioni_di_acquisto, 	 
											provvigioni_di_incasso, 		 
											data_carico, 				 
											imposte_coass,				 
											interesse_mora, 				 
											ritenuta_interesse_mora, 	 
											costo_compagnia,				
											codice_accordo,				 
											premio_lordo_coass,			
											caricamento_coass,			
											imposte_netto_coass,			
											diritto_fisso_coass,			
											interesse_mora_coass,		
											ritenuta_interesse_mora_coass,
											provvigioni_di_acquisto_coass,
											provvigioni_di_incasso_coass,
											costo_etf, 
											codice_tipo_contributo,
											codice_linea)
								VALUES (cur_item.ramo, 						 
										cur_item.codice_prodotto, 			 
										cur_item.numero_polizza,				 
										cur_item.tipo_titolo, 				 
										cur_item.data_effetto_titolo, 		 
										cur_item.data_effetto_polizza,		 
										cur_item.frazionario_di_emissione, 	 
										cur_item.codice_frazionamento, 		 
										cur_item.data_scadenza, 				 
										cur_item.data_valuta, 				 
										cur_item.data_competenza, 			 
										cur_item.codice_fiscale_contraente, 	 
										to_number(cur_item.premio_lordo, '999999999999999999999999999.999999999999999999999999999'),  		 
										to_number(cur_item.premio_netto, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.premio_puro, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.premio_imponibile, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.caricamento, '999999999999999999999999999.999999999999999999999999999'),     	 
										to_number(cur_item.diritto_fisso, '999999999999999999999999999.999999999999999999999999999'),     	 
										cur_item.codice_motivo_storno, 		 
										to_number(cur_item.provvigioni_di_acquisto, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.provvigioni_di_incasso, '999999999999999999999999999.999999999999999999999999999'),    
										cur_item.data_carico, 				 
										to_number(cur_item.imposte_coass, '999999999999999999999999999.999999999999999999999999999'),   
										to_number(cur_item.interesse_mora, '999999999999999999999999999.999999999999999999999999999'),     
										to_number(cur_item.ritenuta_interesse_mora, '999999999999999999999999999.999999999999999999999999999'),  
										to_number(cur_item.costo_compagnia, '999999999999999999999999999.999999999999999999999999999'),  		
										cur_item.codice_accordo,				 
										to_number(cur_item.premio_lordo_coass, '999999999999999999999999999.999999999999999999999999999'),  		
										to_number(cur_item.caricamento_coass, '999999999999999999999999999.999999999999999999999999999'),  			
										to_number(cur_item.imposte_netto_coass, '999999999999999999999999999.999999999999999999999999999'),  			
										to_number(cur_item.diritto_fisso_coass, '999999999999999999999999999.999999999999999999999999999'),  			
										to_number(cur_item.interesse_mora_coass, '999999999999999999999999999.999999999999999999999999999'),  		
										to_number(cur_item.ritenuta_interesse_mora_coass, '999999999999999999999999999.999999999999999999999999999'),  	
										to_number(cur_item.provvigioni_di_acquisto_coass, '999999999999999999999999999.999999999999999999999999999'),  	
										to_number(cur_item.provvigioni_di_incasso_coass, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.costo_etf, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.codice_tipo_contributo,
										cur_item.codice_linea,
									);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM tbl_scarti_tmp_pfmov_inc_coass tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_INC_COASS. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_INC_COASS. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;