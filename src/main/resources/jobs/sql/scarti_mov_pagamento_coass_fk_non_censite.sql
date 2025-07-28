DECLARE

--Movimenti polizze monoramo
CURSOR scarti_movimenti_mono IS
	SELECT /*+ parallel(8) */	
				R.id 				as idrapporto,
				SF.codicetitolo 	as codicetitolo,
				p.ROWID,
	      		p.*
	FROM TMP_PFMOV_PAG_COASS P
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
			R.id 						as idrapporto,
			p.codice_prodotto 			as codicetitolo,
			r.codicetitolo_multiramo 	as codicetitolo_multiramo,
			p.ROWID,
      		p.*	
	FROM TMP_PFMOV_PAG_COASS P
		LEFT JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	WHERE EXISTS (	SELECT 1 
					FROM tbl_bridge b 
					WHERE b.cod_universo = P.codice_prodotto
					AND b.is_ramoI_gs = '0'); -- escludo le ramo I con gestione separata

	
	
--Movimenti polizze altro
CURSOR scarti_movimenti_altro IS
	SELECT /*+ parallel(8) */ DISTINCT R.id as idrapporto,
				SF.codicetitolo as codicetitolo,
				p.ROWID,
	      		p.*
	FROM TMP_PFMOV_PAG_COASS P
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
	WHERE (b.codicetitolo IS NULL AND sf.codicetitolo IS NULL)
	OR r.id is null;
	
		
  I                     	NUMBER(38, 0) := 0;
  SCARTI_IDRAPPORTO		 	NUMBER := 0;
  SCARTI_CODICETITOLO	 	NUMBER := 0;
  SCARTI_CODICETITOLO_M	 	NUMBER := 0;
  
  
  
BEGIN

  FOR CUR_ITEM IN scarti_movimenti_mono

  LOOP

    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (	ramo,
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
													codice_linea,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	CUR_ITEM.ramo,
											CUR_ITEM.codice_prodotto,
											CUR_ITEM.numero_polizza,
											CUR_ITEM.data_comunicazione_pagamento,
											CUR_ITEM.codice_fiscale_beneficiario,
											CUR_ITEM.modalita_pagamento,
											CUR_ITEM.frazionario_di_emissione,
											CUR_ITEM.tipo_liquidazione,
											CUR_ITEM.codice_frazionamento,
											CUR_ITEM.data_effetto_polizza,
											CUR_ITEM.data_scadenza,
											CUR_ITEM.data_valuta,
											CUR_ITEM.data_competenza,
											CUR_ITEM.codice_fiscale_contraente,
											CUR_ITEM.strumento_di_pagamento,
											CUR_ITEM.importo_pagato,
											CUR_ITEM.interesse_mora,
											CUR_ITEM.ritenuta_interesse_mora,
											CUR_ITEM.costo_liquidazione,
											CUR_ITEM.imposta_sostitutiva,
											CUR_ITEM.imposta_bollo,
											CUR_ITEM.importo_pagato_coass, 
											CUR_ITEM.costo_liquidazione_coass,
											CUR_ITEM.imposta_sostitutiva_coass,
											CUR_ITEM.imposta_bollo_coass,
											CUR_ITEM.interesse_mora_coass,
											CUR_ITEM.ritenuta_interesse_mora_coass,
											CUR_ITEM.data_calcolo_pagamento,
											CUR_ITEM.costo_etf, 
											CUR_ITEM.numero_pratica,
											CUR_ITEM.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
											);
	
	SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_PAG_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (	ramo,
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
													codice_linea,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	CUR_ITEM.ramo,
											CUR_ITEM.codice_prodotto,
											CUR_ITEM.numero_polizza,
											CUR_ITEM.data_comunicazione_pagamento,
											CUR_ITEM.codice_fiscale_beneficiario,
											CUR_ITEM.modalita_pagamento,
											CUR_ITEM.frazionario_di_emissione,
											CUR_ITEM.tipo_liquidazione,
											CUR_ITEM.codice_frazionamento,
											CUR_ITEM.data_effetto_polizza,
											CUR_ITEM.data_scadenza,
											CUR_ITEM.data_valuta,
											CUR_ITEM.data_competenza,
											CUR_ITEM.codice_fiscale_contraente,
											CUR_ITEM.strumento_di_pagamento,
											CUR_ITEM.importo_pagato,
											CUR_ITEM.interesse_mora,
											CUR_ITEM.ritenuta_interesse_mora,
											CUR_ITEM.costo_liquidazione,
											CUR_ITEM.imposta_sostitutiva,
											CUR_ITEM.imposta_bollo,
											CUR_ITEM.importo_pagato_coass, 
											CUR_ITEM.costo_liquidazione_coass,
											CUR_ITEM.imposta_sostitutiva_coass,
											CUR_ITEM.imposta_bollo_coass,
											CUR_ITEM.interesse_mora_coass,
											CUR_ITEM.ritenuta_interesse_mora_coass,
											CUR_ITEM.data_calcolo_pagamento,
											CUR_ITEM.costo_etf, 
											CUR_ITEM.numero_pratica,
											CUR_ITEM.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
  DELETE FROM TMP_PFMOV_PAG_COASS DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	END IF;
	
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  
  	I:=0;
  
  FOR CUR_ITEM IN scarti_movimenti_multi

  LOOP

    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (	ramo,
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
													codice_linea,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	CUR_ITEM.ramo,
											CUR_ITEM.codice_prodotto,
											CUR_ITEM.numero_polizza,
											CUR_ITEM.data_comunicazione_pagamento,
											CUR_ITEM.codice_fiscale_beneficiario,
											CUR_ITEM.modalita_pagamento,
											CUR_ITEM.frazionario_di_emissione,
											CUR_ITEM.tipo_liquidazione,
											CUR_ITEM.codice_frazionamento,
											CUR_ITEM.data_effetto_polizza,
											CUR_ITEM.data_scadenza,
											CUR_ITEM.data_valuta,
											CUR_ITEM.data_competenza,
											CUR_ITEM.codice_fiscale_contraente,
											CUR_ITEM.strumento_di_pagamento,
											CUR_ITEM.importo_pagato,
											CUR_ITEM.interesse_mora,
											CUR_ITEM.ritenuta_interesse_mora,
											CUR_ITEM.costo_liquidazione,
											CUR_ITEM.imposta_sostitutiva,
											CUR_ITEM.imposta_bollo,
											CUR_ITEM.importo_pagato_coass, 
											CUR_ITEM.costo_liquidazione_coass,
											CUR_ITEM.imposta_sostitutiva_coass,
											CUR_ITEM.imposta_bollo_coass,
											CUR_ITEM.interesse_mora_coass,
											CUR_ITEM.ritenuta_interesse_mora_coass,
											CUR_ITEM.data_calcolo_pagamento,
											CUR_ITEM.costo_etf, 
											CUR_ITEM.numero_pratica,
											CUR_ITEM.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
											);
	
	SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_PAG_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (	ramo,
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
													codice_linea,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	CUR_ITEM.ramo,
											CUR_ITEM.codice_prodotto,
											CUR_ITEM.numero_polizza,
											CUR_ITEM.data_comunicazione_pagamento,
											CUR_ITEM.codice_fiscale_beneficiario,
											CUR_ITEM.modalita_pagamento,
											CUR_ITEM.frazionario_di_emissione,
											CUR_ITEM.tipo_liquidazione,
											CUR_ITEM.codice_frazionamento,
											CUR_ITEM.data_effetto_polizza,
											CUR_ITEM.data_scadenza,
											CUR_ITEM.data_valuta,
											CUR_ITEM.data_competenza,
											CUR_ITEM.codice_fiscale_contraente,
											CUR_ITEM.strumento_di_pagamento,
											CUR_ITEM.importo_pagato,
											CUR_ITEM.interesse_mora,
											CUR_ITEM.ritenuta_interesse_mora,
											CUR_ITEM.costo_liquidazione,
											CUR_ITEM.imposta_sostitutiva,
											CUR_ITEM.imposta_bollo,
											CUR_ITEM.importo_pagato_coass, 
											CUR_ITEM.costo_liquidazione_coass,
											CUR_ITEM.imposta_sostitutiva_coass,
											CUR_ITEM.imposta_bollo_coass,
											CUR_ITEM.interesse_mora_coass,
											CUR_ITEM.ritenuta_interesse_mora_coass,
											CUR_ITEM.data_calcolo_pagamento,
											CUR_ITEM.costo_etf, 
											CUR_ITEM.numero_pratica,
											CUR_ITEM.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
  DELETE FROM TMP_PFMOV_PAG_COASS DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
  ELSIF (CUR_ITEM.IDRAPPORTO IS NOT NULL AND CUR_ITEM.codicetitolo_multiramo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (	ramo,
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
													codice_linea,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	CUR_ITEM.ramo,
											CUR_ITEM.codice_prodotto,
											CUR_ITEM.numero_polizza,
											CUR_ITEM.data_comunicazione_pagamento,
											CUR_ITEM.codice_fiscale_beneficiario,
											CUR_ITEM.modalita_pagamento,
											CUR_ITEM.frazionario_di_emissione,
											CUR_ITEM.tipo_liquidazione,
											CUR_ITEM.codice_frazionamento,
											CUR_ITEM.data_effetto_polizza,
											CUR_ITEM.data_scadenza,
											CUR_ITEM.data_valuta,
											CUR_ITEM.data_competenza,
											CUR_ITEM.codice_fiscale_contraente,
											CUR_ITEM.strumento_di_pagamento,
											CUR_ITEM.importo_pagato,
											CUR_ITEM.interesse_mora,
											CUR_ITEM.ritenuta_interesse_mora,
											CUR_ITEM.costo_liquidazione,
											CUR_ITEM.imposta_sostitutiva,
											CUR_ITEM.imposta_bollo,
											CUR_ITEM.importo_pagato_coass, 
											CUR_ITEM.costo_liquidazione_coass,
											CUR_ITEM.imposta_sostitutiva_coass,
											CUR_ITEM.imposta_bollo_coass,
											CUR_ITEM.interesse_mora_coass,
											CUR_ITEM.ritenuta_interesse_mora_coass,
											CUR_ITEM.data_calcolo_pagamento,
											CUR_ITEM.costo_etf, 
											CUR_ITEM.numero_pratica,
											CUR_ITEM.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO_MULTIRAMO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO_M := SCARTI_CODICETITOLO_M + 1;
	
  DELETE FROM TMP_PFMOV_PAG_COASS DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;	
 
	END IF;
	
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MULTI PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MULTI PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MULTI FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MULTI FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MULTI FK NON CENSITA (CODICETITOLO_MULTIRAMO): ' || SCARTI_CODICETITOLO_M);
  
	I:= 0;
  
  FOR CUR_ITEM IN scarti_movimenti_altro

  LOOP
    I := I + 1;

    IF (CUR_ITEM.IDRAPPORTO IS NULL)
    THEN
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (	ramo,
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
													codice_linea,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	CUR_ITEM.ramo,
											CUR_ITEM.codice_prodotto,
											CUR_ITEM.numero_polizza,
											CUR_ITEM.data_comunicazione_pagamento,
											CUR_ITEM.codice_fiscale_beneficiario,
											CUR_ITEM.modalita_pagamento,
											CUR_ITEM.frazionario_di_emissione,
											CUR_ITEM.tipo_liquidazione,
											CUR_ITEM.codice_frazionamento,
											CUR_ITEM.data_effetto_polizza,
											CUR_ITEM.data_scadenza,
											CUR_ITEM.data_valuta,
											CUR_ITEM.data_competenza,
											CUR_ITEM.codice_fiscale_contraente,
											CUR_ITEM.strumento_di_pagamento,
											CUR_ITEM.importo_pagato,
											CUR_ITEM.interesse_mora,
											CUR_ITEM.ritenuta_interesse_mora,
											CUR_ITEM.costo_liquidazione,
											CUR_ITEM.imposta_sostitutiva,
											CUR_ITEM.imposta_bollo,
											CUR_ITEM.importo_pagato_coass, 
											CUR_ITEM.costo_liquidazione_coass,
											CUR_ITEM.imposta_sostitutiva_coass,
											CUR_ITEM.imposta_bollo_coass,
											CUR_ITEM.interesse_mora_coass,
											CUR_ITEM.ritenuta_interesse_mora_coass,
											CUR_ITEM.data_calcolo_pagamento,
											CUR_ITEM.costo_etf, 
											CUR_ITEM.numero_pratica,
											CUR_ITEM.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
											'S'
											);
	
	SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_PAG_COASS DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
	
      INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (	ramo,
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
													codice_linea,
													tmstp,
													motivo_scarto,
													riproponibile) 
                       			VALUES (	CUR_ITEM.ramo,
											CUR_ITEM.codice_prodotto,
											CUR_ITEM.numero_polizza,
											CUR_ITEM.data_comunicazione_pagamento,
											CUR_ITEM.codice_fiscale_beneficiario,
											CUR_ITEM.modalita_pagamento,
											CUR_ITEM.frazionario_di_emissione,
											CUR_ITEM.tipo_liquidazione,
											CUR_ITEM.codice_frazionamento,
											CUR_ITEM.data_effetto_polizza,
											CUR_ITEM.data_scadenza,
											CUR_ITEM.data_valuta,
											CUR_ITEM.data_competenza,
											CUR_ITEM.codice_fiscale_contraente,
											CUR_ITEM.strumento_di_pagamento,
											CUR_ITEM.importo_pagato,
											CUR_ITEM.interesse_mora,
											CUR_ITEM.ritenuta_interesse_mora,
											CUR_ITEM.costo_liquidazione,
											CUR_ITEM.imposta_sostitutiva,
											CUR_ITEM.imposta_bollo,
											CUR_ITEM.importo_pagato_coass, 
											CUR_ITEM.costo_liquidazione_coass,
											CUR_ITEM.imposta_sostitutiva_coass,
											CUR_ITEM.imposta_bollo_coass,
											CUR_ITEM.interesse_mora_coass,
											CUR_ITEM.ritenuta_interesse_mora_coass,
											CUR_ITEM.data_calcolo_pagamento,
											CUR_ITEM.costo_etf, 
											CUR_ITEM.numero_pratica,
											CUR_ITEM.codice_linea,
											SYSDATE,
											'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
											'S'
											);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
  DELETE FROM TMP_PFMOV_PAG_COASS DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	END IF;
	
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
  
  
  
  
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
               	 r.tipo || '_' || t.tipo_liquidazione, --CODICECAUSALE
                 NULL,  --CAUCONTR
                 NULL, --DATAAGGIORNAMENTO
                 TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')), --DATAINSERIMENTO
                 t.tipo_liquidazione, --DESCRIZIONE
                 '1', --FLAGAGGSALDI
                 NULL, --SEGNO
                 '4', --TIPOCAUSALE
                 null, --SOTL
                 '07601', --CODICEBANCA
	         	 r.tipo, --CANALE
           		 'PREL',
                 t.tipo_liquidazione --CODICECAUSALE_ORI
               FROM TMP_PFMOV_PAG_COASS t
               	INNER JOIN TBL_BRIDGE CC
					ON t.codice_prodotto = CC.cod_universo
				INNER JOIN RAPPORTO R
					ON 0 || numero_polizza = R.codicerapporto
					AND R.tipo = '13'
               WHERE NOT EXISTS
		               (SELECT 1
		                FROM CAUSALE c
		                WHERE c.CODICECAUSALE =  r.tipo || '_' || t.tipo_liquidazione);
  
  COMMIT;
END;