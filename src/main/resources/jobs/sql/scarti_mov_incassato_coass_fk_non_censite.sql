DECLARE

--Movimenti polizze monoramo
CURSOR scarti_movimenti_mono IS
	SELECT /*+ parallel(8) */	
			R.id 				as idrapporto,
			SF.codicetitolo 	as codicetitolo,
			p.ROWID,
      		p.*
	FROM TMP_PFMOV_INC_COASS P
		LEFT JOIN ( SELECT X.codicetitolo, X.cod_universo, X.is_ramoI_gs, MIN(X.ROWID) AS row_id
					FROM tbl_bridge X 
					INNER JOIN strumentofinanziario y 
						ON X.codicetitolo = y.codicetitolo
					GROUP BY X.codicetitolo, X.cod_universo, X.is_ramoI_gs) b
			ON b.cod_universo = P.codice_prodotto
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = P.codice_prodotto
		LEFT JOIN rapporto R
			ON R.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND R.tipo = '13'
	WHERE (b.codicetitolo IS NULL OR b.is_ramoI_gs = '1') -- includo le ramo I con gestione separata
		AND sf.livello_2 = 'POLIZZE RAMO I';

	
--Movimenti polizze multiramo
CURSOR scarti_movimenti_multi IS 
	SELECT /*+ parallel(8) */	
			R.id 						AS idrapporto,
			p.codice_prodotto 			as codicetitolo,
			r.codicetitolo_multiramo 	as codicetitolo_multiramo,
			p.ROWID,
      		p.*
	FROM TMP_PFMOV_INC_COASS p
		LEFT JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	WHERE EXISTS (	SELECT 1 
					FROM tbl_bridge b 
					WHERE b.cod_universo = P.codice_prodotto
					AND b.is_ramoI_gs = '0'); -- escludo le ramo I con gestione separata

	

--Movimenti polizze altro
CURSOR scarti_movimenti_altro IS
	SELECT 	distinct R.id as idrapporto,
			SF.codicetitolo as codicetitolo,
			p.ROWID,
      		p.*
	FROM TMP_PFMOV_INC_COASS P
		LEFT JOIN ( SELECT X.* 
					FROM tbl_bridge X 
					INNER JOIN strumentofinanziario y 
						ON X.codicetitolo = y.codicetitolo) b
			ON b.cod_universo = P.codice_prodotto
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = P.codice_prodotto
		LEFT JOIN rapporto R
			ON R.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND R.tipo = '13'
	WHERE (b.codicetitolo IS NULL and sf.codicetitolo IS NULL)
	OR r.id IS NULL;	

I                     	NUMBER(38, 0) := 0;
SCARTI_IDRAPPORTO		NUMBER := 0;
SCARTI_CODICETITOLO	 	NUMBER := 0;
SCARTI_CODICETITOLO_M 	NUMBER := 0;

  
BEGIN

  FOR CUR_ITEM IN scarti_movimenti_mono

  LOOP

    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (	ramo, 						 
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
													riproponibile) 
                       			VALUES (	cur_item.ramo, 						 
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
											cur_item.premio_lordo, 				 
											cur_item.premio_netto, 				 
											cur_item.premio_puro, 				 
											cur_item.premio_imponibile, 			 
											cur_item.caricamento, 				 
											cur_item.diritto_fisso, 				 
											cur_item.codice_motivo_storno, 		 
											cur_item.provvigioni_di_acquisto, 	 
											cur_item.provvigioni_di_incasso, 		 
											cur_item.data_carico, 				 
											cur_item.imposte_coass,				 
											cur_item.interesse_mora, 				 
											cur_item.ritenuta_interesse_mora, 	 
											cur_item.costo_compagnia,				
											cur_item.codice_accordo,				 
											cur_item.premio_lordo_coass,			
											cur_item.caricamento_coass,			
											cur_item.imposte_netto_coass,			
											cur_item.diritto_fisso_coass,			
											cur_item.interesse_mora_coass,		
											cur_item.ritenuta_interesse_mora_coass,
											cur_item.provvigioni_di_acquisto_coass,
											cur_item.provvigioni_di_incasso_coass,
											cur_item.costo_etf, 
											cur_item.codice_tipo_contributo,
											cur_item.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
											);
	
		SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_INC_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (	ramo, 						 
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
													riproponibile) 
                       			VALUES (	cur_item.ramo, 						 
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
											cur_item.premio_lordo, 				 
											cur_item.premio_netto, 				 
											cur_item.premio_puro, 				 
											cur_item.premio_imponibile, 			 
											cur_item.caricamento, 				 
											cur_item.diritto_fisso, 				 
											cur_item.codice_motivo_storno, 		 
											cur_item.provvigioni_di_acquisto, 	 
											cur_item.provvigioni_di_incasso, 		 
											cur_item.data_carico, 				 
											cur_item.imposte_coass,				 
											cur_item.interesse_mora, 				 
											cur_item.ritenuta_interesse_mora, 	 
											cur_item.costo_compagnia,				
											cur_item.codice_accordo,				 
											cur_item.premio_lordo_coass,			
											cur_item.caricamento_coass,			
											cur_item.imposte_netto_coass,			
											cur_item.diritto_fisso_coass,			
											cur_item.interesse_mora_coass,		
											cur_item.ritenuta_interesse_mora_coass,
											cur_item.provvigioni_di_acquisto_coass,
											cur_item.provvigioni_di_incasso_coass,
											cur_item.costo_etf, 
											cur_item.codice_tipo_contributo,
											cur_item.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
      DELETE FROM TMP_PFMOV_INC_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  
  COMMIT;
  
 	I :=0;
    
 	FOR CUR_ITEM IN scarti_movimenti_multi

  LOOP
  
	I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (	ramo, 						 
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
													riproponibile) 
                       			VALUES (	cur_item.ramo, 						 
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
											cur_item.premio_lordo, 				 
											cur_item.premio_netto, 				 
											cur_item.premio_puro, 				 
											cur_item.premio_imponibile, 			 
											cur_item.caricamento, 				 
											cur_item.diritto_fisso, 				 
											cur_item.codice_motivo_storno, 		 
											cur_item.provvigioni_di_acquisto, 	 
											cur_item.provvigioni_di_incasso, 		 
											cur_item.data_carico, 				 
											cur_item.imposte_coass,				 
											cur_item.interesse_mora, 				 
											cur_item.ritenuta_interesse_mora, 	 
											cur_item.costo_compagnia,				
											cur_item.codice_accordo,				 
											cur_item.premio_lordo_coass,			
											cur_item.caricamento_coass,			
											cur_item.imposte_netto_coass,			
											cur_item.diritto_fisso_coass,			
											cur_item.interesse_mora_coass,		
											cur_item.ritenuta_interesse_mora_coass,
											cur_item.provvigioni_di_acquisto_coass,
											cur_item.provvigioni_di_incasso_coass,
											cur_item.costo_etf, 
											cur_item.codice_tipo_contributo,
											cur_item.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
											);
	
		SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_INC_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (	ramo, 						 
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
													riproponibile) 
                       			VALUES (	cur_item.ramo, 						 
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
											cur_item.premio_lordo, 				 
											cur_item.premio_netto, 				 
											cur_item.premio_puro, 				 
											cur_item.premio_imponibile, 			 
											cur_item.caricamento, 				 
											cur_item.diritto_fisso, 				 
											cur_item.codice_motivo_storno, 		 
											cur_item.provvigioni_di_acquisto, 	 
											cur_item.provvigioni_di_incasso, 		 
											cur_item.data_carico, 				 
											cur_item.imposte_coass,				 
											cur_item.interesse_mora, 				 
											cur_item.ritenuta_interesse_mora, 	 
											cur_item.costo_compagnia,				
											cur_item.codice_accordo,				 
											cur_item.premio_lordo_coass,			
											cur_item.caricamento_coass,			
											cur_item.imposte_netto_coass,			
											cur_item.diritto_fisso_coass,			
											cur_item.interesse_mora_coass,		
											cur_item.ritenuta_interesse_mora_coass,
											cur_item.provvigioni_di_acquisto_coass,
											cur_item.provvigioni_di_incasso_coass,
											cur_item.costo_etf, 
											cur_item.codice_tipo_contributo,
											cur_item.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
      DELETE FROM TMP_PFMOV_INC_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
    ELSIF (CUR_ITEM.IDRAPPORTO IS NOT NULL AND CUR_ITEM.codicetitolo_multiramo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (	ramo, 						 
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
													riproponibile) 
                       			VALUES (	cur_item.ramo, 						 
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
											cur_item.premio_lordo, 				 
											cur_item.premio_netto, 				 
											cur_item.premio_puro, 				 
											cur_item.premio_imponibile, 			 
											cur_item.caricamento, 				 
											cur_item.diritto_fisso, 				 
											cur_item.codice_motivo_storno, 		 
											cur_item.provvigioni_di_acquisto, 	 
											cur_item.provvigioni_di_incasso, 		 
											cur_item.data_carico, 				 
											cur_item.imposte_coass,				 
											cur_item.interesse_mora, 				 
											cur_item.ritenuta_interesse_mora, 	 
											cur_item.costo_compagnia,				
											cur_item.codice_accordo,				 
											cur_item.premio_lordo_coass,			
											cur_item.caricamento_coass,			
											cur_item.imposte_netto_coass,			
											cur_item.diritto_fisso_coass,			
											cur_item.interesse_mora_coass,		
											cur_item.ritenuta_interesse_mora_coass,
											cur_item.provvigioni_di_acquisto_coass,
											cur_item.provvigioni_di_incasso_coass,
											cur_item.costo_etf, 
											cur_item.codice_tipo_contributo,
											cur_item.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO_MULTIRAMO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO_M := SCARTI_CODICETITOLO_M + 1;
	
      DELETE FROM TMP_PFMOV_INC_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	  
      
      
	END IF;

		
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MULTI PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MULTI PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MULTI FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MULTI FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MULTI FK NON CENSITA (CODICETITOLO_MULTIRAMO): ' || SCARTI_CODICETITOLO_M);
  
  
  I := 0;
  
  FOR CUR_ITEM IN scarti_movimenti_altro

  LOOP

    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (	ramo, 						 
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
													riproponibile) 
                       			VALUES (	cur_item.ramo, 						 
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
											cur_item.premio_lordo, 				 
											cur_item.premio_netto, 				 
											cur_item.premio_puro, 				 
											cur_item.premio_imponibile, 			 
											cur_item.caricamento, 				 
											cur_item.diritto_fisso, 				 
											cur_item.codice_motivo_storno, 		 
											cur_item.provvigioni_di_acquisto, 	 
											cur_item.provvigioni_di_incasso, 		 
											cur_item.data_carico, 				 
											cur_item.imposte_coass,				 
											cur_item.interesse_mora, 				 
											cur_item.ritenuta_interesse_mora, 	 
											cur_item.costo_compagnia,				
											cur_item.codice_accordo,				 
											cur_item.premio_lordo_coass,			
											cur_item.caricamento_coass,			
											cur_item.imposte_netto_coass,			
											cur_item.diritto_fisso_coass,			
											cur_item.interesse_mora_coass,		
											cur_item.ritenuta_interesse_mora_coass,
											cur_item.provvigioni_di_acquisto_coass,
											cur_item.provvigioni_di_incasso_coass,
											cur_item.costo_etf, 
											cur_item.codice_tipo_contributo,
											cur_item.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
											);
	
		SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_INC_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_INC_COASS (	ramo, 						 
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
													riproponibile) 
                       			VALUES (	cur_item.ramo, 						 
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
											cur_item.premio_lordo, 				 
											cur_item.premio_netto, 				 
											cur_item.premio_puro, 				 
											cur_item.premio_imponibile, 			 
											cur_item.caricamento, 				 
											cur_item.diritto_fisso, 				 
											cur_item.codice_motivo_storno, 		 
											cur_item.provvigioni_di_acquisto, 	 
											cur_item.provvigioni_di_incasso, 		 
											cur_item.data_carico, 				 
											cur_item.imposte_coass,				 
											cur_item.interesse_mora, 				 
											cur_item.ritenuta_interesse_mora, 	 
											cur_item.costo_compagnia,				
											cur_item.codice_accordo,				 
											cur_item.premio_lordo_coass,			
											cur_item.caricamento_coass,			
											cur_item.imposte_netto_coass,			
											cur_item.diritto_fisso_coass,			
											cur_item.interesse_mora_coass,		
											cur_item.ritenuta_interesse_mora_coass,
											cur_item.provvigioni_di_acquisto_coass,
											cur_item.provvigioni_di_incasso_coass,
											cur_item.costo_etf, 
											cur_item.codice_tipo_contributo,
											cur_item.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
      DELETE FROM TMP_PFMOV_INC_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_INC_COASS MONO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  
  COMMIT;
  
  
  INSERT INTO CAUSALE (	  CODICECAUSALE,
                          CAUCONTR,
                          DATAAGGIORNAMENTO,
                          DATAINSERIMENTO,
                          DESCRIZIONE,
                          FLAGAGGSALDI,
                          SEGNO,
                          TIPOCAUSALE,
                          SOTL,
                          CODICEBANCA,
                          CANALE,
                          TIPOLOGIA_CAUSALE,
                          CODICECAUSALE_ORI)
               SELECT DISTINCT
               	 r.tipo || '_' || t.tipo_titolo, --CODICECAUSALE
                 NULL,  --CAUCONTR
                 NULL, --DATAAGGIORNAMENTO
                 TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')), --DATAINSERIMENTO
                 t.tipo_titolo, --DESCRIZIONE
                 '1', --FLAGAGGSALDI
                 NULL, --SEGNO
                 '4', --TIPOCAUSALE
                 null, --SOTL
                 '07601', --CODICEBANCA
	         	 r.tipo, --CANALE
                 'VER',
                 t.tipo_titolo --CODICECAUSALE_ORI
               FROM TMP_PFMOV_INC_COASS t
               	INNER JOIN TBL_BRIDGE CC
					ON t.codice_prodotto = CC.cod_universo
				INNER JOIN RAPPORTO R
					ON 0 || numero_polizza = R.codicerapporto
					AND R.tipo = '13'
               WHERE NOT EXISTS
		               (SELECT 1
		                FROM CAUSALE c
		                WHERE c.CODICECAUSALE = r.tipo || '_' || t.tipo_titolo);

  
  COMMIT;
END;