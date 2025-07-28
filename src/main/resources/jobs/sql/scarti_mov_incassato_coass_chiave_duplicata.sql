DECLARE

--Movimenti polizze monoramo
CURSOR scarti_movimenti_mono IS
	SELECT  /*+ parallel(8) */ tmp.ROWID, tmp.*, rapp.id
	FROM TMP_PFMOV_INC_COASS tmp
        INNER JOIN RAPPORTO rapp
      		ON LPAD(trim(tmp.numero_polizza),12,'0') = rapp.codicerapporto
      			AND rapp.tipo = '13'
		INNER JOIN (SELECT  p.numero_polizza||p.codice_prodotto||p.ramo||p.tipo_titolo||p.data_valuta||p.codice_motivo_storno||p.data_carico||p.data_competenza||p.data_effetto_titolo	AS numreg,
							r.id AS idrapporto	
				 	FROM TMP_PFMOV_INC_COASS P
						LEFT JOIN tbl_bridge b
							ON b.cod_universo = P.codice_prodotto
						INNER JOIN strumentofinanziario sf
							ON sf.codicetitolo = P.codice_prodotto
						INNER JOIN rapporto R
							ON R.codicerapporto = LPAD(trim(p.numero_polizza),12,'0')
							AND R.tipo = '13'
					WHERE b.codicetitolo IS NULL
					and sf.livello_2 = 'POLIZZE RAMO I'
				 	GROUP BY 	p.numero_polizza||p.codice_prodotto||p.ramo||p.tipo_titolo||p.data_valuta||p.codice_motivo_storno||p.data_carico||p.data_competenza||p.data_effetto_titolo, 
					 			r.id
					HAVING COUNT(*) >1) A
			ON tmp.numero_polizza||tmp.codice_prodotto||tmp.ramo||tmp.tipo_titolo||tmp.data_valuta||tmp.codice_motivo_storno||tmp.data_carico||tmp.data_competenza||tmp.data_effetto_titolo = A.numreg
				AND rapp.id = A.idrapporto;

				
--Movimenti polizze multiramo
CURSOR scarti_movimenti_multi IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, tmp.*, rapp.id
	FROM TMP_PFMOV_INC_COASS tmp
        INNER JOIN RAPPORTO rapp
      		ON LPAD(trim(tmp.numero_polizza),12,'0') = rapp.codicerapporto
      			AND rapp.tipo = '13'				
		INNER JOIN (SELECT  p.numero_polizza||p.codice_prodotto||p.ramo||p.tipo_titolo||p.data_valuta||p.codice_motivo_storno||p.data_carico||p.data_competenza||p.data_effetto_titolo	AS numreg,
							r.id as idrapporto
					FROM TMP_PFMOV_INC_COASS p
						inner join rapporto r
							on r.codicerapporto = LPAD(trim(p.numero_polizza),12,'0')
							and r.tipo = '13'
					where r.codicetitolo_multiramo is not null
					GROUP BY 	p.numero_polizza||p.codice_prodotto||p.ramo||p.tipo_titolo||p.data_valuta||p.codice_motivo_storno||p.data_carico||p.data_competenza||p.data_effetto_titolo, 
					 			r.id
					HAVING COUNT(*) >1) A
			ON tmp.numero_polizza||tmp.codice_prodotto||tmp.ramo||tmp.tipo_titolo||tmp.data_valuta||tmp.codice_motivo_storno||tmp.data_carico||tmp.data_competenza||tmp.data_effetto_titolo = A.numreg
				AND rapp.id = A.idrapporto;
				
				
TYPE scarti_movimenti_mono_type IS TABLE OF scarti_movimenti_mono%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_movimenti_mono scarti_movimenti_mono_type;

TYPE scarti_movimenti_multi_type IS TABLE OF scarti_movimenti_multi%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_movimenti_multi scarti_movimenti_multi_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_movimenti_mono;
	LOOP
			FETCH scarti_movimenti_mono BULK COLLECT INTO res_scarti_movimenti_mono LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_mono.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_mono.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_mono.FIRST .. res_scarti_movimenti_mono.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (ramo, 						 
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
															codice_linea,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile
														)
												VALUES (	res_scarti_movimenti_mono(j).ramo, 						 
															res_scarti_movimenti_mono(j).codice_prodotto, 			 
															res_scarti_movimenti_mono(j).numero_polizza,				 
															res_scarti_movimenti_mono(j).tipo_titolo, 				 
															res_scarti_movimenti_mono(j).data_effetto_titolo, 		 
															res_scarti_movimenti_mono(j).data_effetto_polizza,		 
															res_scarti_movimenti_mono(j).frazionario_di_emissione, 	 
															res_scarti_movimenti_mono(j).codice_frazionamento, 		 
															res_scarti_movimenti_mono(j).data_scadenza, 				 
															res_scarti_movimenti_mono(j).data_valuta, 				 
															res_scarti_movimenti_mono(j).data_competenza, 			 
															res_scarti_movimenti_mono(j).codice_fiscale_contraente, 	 
															res_scarti_movimenti_mono(j).premio_lordo, 				 
															res_scarti_movimenti_mono(j).premio_netto, 				 
															res_scarti_movimenti_mono(j).premio_puro, 				 
															res_scarti_movimenti_mono(j).premio_imponibile, 			 
															res_scarti_movimenti_mono(j).caricamento, 				 
															res_scarti_movimenti_mono(j).diritto_fisso, 				 
															res_scarti_movimenti_mono(j).codice_motivo_storno, 		 
															res_scarti_movimenti_mono(j).provvigioni_di_acquisto, 	 
															res_scarti_movimenti_mono(j).provvigioni_di_incasso, 		 
															res_scarti_movimenti_mono(j).data_carico, 				 
															res_scarti_movimenti_mono(j).imposte_coass,				 
															res_scarti_movimenti_mono(j).interesse_mora, 				 
															res_scarti_movimenti_mono(j).ritenuta_interesse_mora, 	 
															res_scarti_movimenti_mono(j).costo_compagnia,				
															res_scarti_movimenti_mono(j).codice_accordo,				 
															res_scarti_movimenti_mono(j).premio_lordo_coass,			
															res_scarti_movimenti_mono(j).caricamento_coass,			
															res_scarti_movimenti_mono(j).imposte_netto_coass,			
															res_scarti_movimenti_mono(j).diritto_fisso_coass,			
															res_scarti_movimenti_mono(j).interesse_mora_coass,		
															res_scarti_movimenti_mono(j).ritenuta_interesse_mora_coass,
															res_scarti_movimenti_mono(j).provvigioni_di_acquisto_coass,
															res_scarti_movimenti_mono(j).provvigioni_di_incasso_coass,
															res_scarti_movimenti_mono(j).costo_etf, 
															res_scarti_movimenti_mono(j).codice_tipo_contributo,
															res_scarti_movimenti_mono(j).codice_linea,
															SYSDATE,
															'CHIAVE PRIMARIA "NUMREG, IDRAPPORTO" DUPLICATA',
															'N'
														);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_mono.FIRST .. res_scarti_movimenti_mono.LAST
			        	
			        DELETE FROM TMP_PFMOV_INC_COASS tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_mono(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO PER CHIAVE (NUMREG, IDRAPPORTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_mono;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO PER CHIAVE (NUMREG, IDRAPPORTO) DUPLICATA: ' || totale);
	COMMIT;
	
	
	OPEN scarti_movimenti_multi;
	LOOP
			FETCH scarti_movimenti_multi BULK COLLECT INTO res_scarti_movimenti_multi LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_multi.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_multi.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (ramo, 						 
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
															codice_linea,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile
														)
												VALUES (	res_scarti_movimenti_multi(j).ramo, 						 
															res_scarti_movimenti_multi(j).codice_prodotto, 			 
															res_scarti_movimenti_multi(j).numero_polizza,				 
															res_scarti_movimenti_multi(j).tipo_titolo, 				 
															res_scarti_movimenti_multi(j).data_effetto_titolo, 		 
															res_scarti_movimenti_multi(j).data_effetto_polizza,		 
															res_scarti_movimenti_multi(j).frazionario_di_emissione, 	 
															res_scarti_movimenti_multi(j).codice_frazionamento, 		 
															res_scarti_movimenti_multi(j).data_scadenza, 				 
															res_scarti_movimenti_multi(j).data_valuta, 				 
															res_scarti_movimenti_multi(j).data_competenza, 			 
															res_scarti_movimenti_multi(j).codice_fiscale_contraente, 	 
															res_scarti_movimenti_multi(j).premio_lordo, 				 
															res_scarti_movimenti_multi(j).premio_netto, 				 
															res_scarti_movimenti_multi(j).premio_puro, 				 
															res_scarti_movimenti_multi(j).premio_imponibile, 			 
															res_scarti_movimenti_multi(j).caricamento, 				 
															res_scarti_movimenti_multi(j).diritto_fisso, 				 
															res_scarti_movimenti_multi(j).codice_motivo_storno, 		 
															res_scarti_movimenti_multi(j).provvigioni_di_acquisto, 	 
															res_scarti_movimenti_multi(j).provvigioni_di_incasso, 		 
															res_scarti_movimenti_multi(j).data_carico, 				 
															res_scarti_movimenti_multi(j).imposte_coass,				 
															res_scarti_movimenti_multi(j).interesse_mora, 				 
															res_scarti_movimenti_multi(j).ritenuta_interesse_mora, 	 
															res_scarti_movimenti_multi(j).costo_compagnia,				
															res_scarti_movimenti_multi(j).codice_accordo,				 
															res_scarti_movimenti_multi(j).premio_lordo_coass,			
															res_scarti_movimenti_multi(j).caricamento_coass,			
															res_scarti_movimenti_multi(j).imposte_netto_coass,			
															res_scarti_movimenti_multi(j).diritto_fisso_coass,			
															res_scarti_movimenti_multi(j).interesse_mora_coass,		
															res_scarti_movimenti_multi(j).ritenuta_interesse_mora_coass,
															res_scarti_movimenti_multi(j).provvigioni_di_acquisto_coass,
															res_scarti_movimenti_multi(j).provvigioni_di_incasso_coass,
															res_scarti_movimenti_multi(j).costo_etf, 
															res_scarti_movimenti_multi(j).codice_tipo_contributo,
															res_scarti_movimenti_multi(j).codice_linea,
															SYSDATE,
															'CHIAVE PRIMARIA "NUMREG, IDRAPPORTO" DUPLICATA',
															'N'
														);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST
			        	
			        DELETE FROM TMP_PFMOV_INC_COASS tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_multi(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MULTI PER CHIAVE (NUMREG, IDRAPPORTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_multi;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS PER CHIAVE MULTI (NUMREG, IDRAPPORTO) DUPLICATA: ' || totale);
	COMMIT;
	
END;