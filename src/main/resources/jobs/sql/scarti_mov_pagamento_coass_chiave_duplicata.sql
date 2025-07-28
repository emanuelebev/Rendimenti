DECLARE

--Movimenti polizze monoramo
CURSOR scarti_movimenti_mono IS
	SELECT /*+ parallel(8) */  tmp.ROWID, tmp.*, rapp.id
	FROM TMP_PFMOV_PAG_COASS tmp
		INNER JOIN RAPPORTO rapp
      		ON LPAD(trim(tmp.numero_polizza),12,'0') = rapp.codicerapporto
      			AND rapp.tipo = '13'
		INNER JOIN (SELECT  numero_polizza||codice_prodotto||ramo||tipo_liquidazione||data_valuta||codice_fiscale_beneficiario||
									data_comunicazione_pagamento||modalita_pagamento||codice_frazionamento 						AS numreg,
							R.id 																							  	AS idrapporto	
					FROM TMP_PFMOV_PAG_COASS P
						LEFT JOIN tbl_bridge b
							ON b.cod_universo = P.codice_prodotto
						INNER JOIN strumentofinanziario sf
							ON sf.codicetitolo = P.codice_prodotto
						INNER JOIN rapporto R
							ON R.codicerapporto = LPAD(trim(p.numero_polizza),12,'0')
							AND R.tipo = '13'
					WHERE b.codicetitolo IS NULL
					and sf.livello_2 = 'POLIZZE RAMO I'
					GROUP BY numero_polizza||codice_prodotto||ramo||tipo_liquidazione||data_valuta||codice_fiscale_beneficiario||
									data_comunicazione_pagamento||modalita_pagamento||codice_frazionamento,
				 			 R.id
					HAVING COUNT(*) >1) A
		ON tmp.numero_polizza||tmp.codice_prodotto||tmp.ramo||tmp.tipo_liquidazione||tmp.data_valuta||tmp.codice_fiscale_beneficiario||
									tmp.data_comunicazione_pagamento||tmp.modalita_pagamento||tmp.codice_frazionamento = A.numreg
			AND rapp.id = A.idrapporto;

			
--Movimenti polizze multiramo
CURSOR scarti_movimenti_multi IS			
		SELECT  /*+ parallel(8) */ tmp.ROWID, tmp.*, rapp.id
		FROM TMP_PFMOV_PAG_COASS tmp
			INNER JOIN RAPPORTO rapp
	      		ON LPAD(trim(tmp.numero_polizza),12,'0') = rapp.codicerapporto
	      			AND rapp.tipo = '13'
			INNER JOIN (SELECT   numero_polizza||codice_prodotto||ramo||tipo_liquidazione||data_valuta||codice_fiscale_beneficiario||
									data_comunicazione_pagamento||modalita_pagamento||codice_frazionamento 							AS numreg,
								 R.id 																							    AS idrapporto
						FROM TMP_PFMOV_PAG_COASS P
							inner join rapporto r
									on r.codicerapporto = LPAD(trim(p.numero_polizza),12,'0')
									and r.tipo = '13'
						where r.codicetitolo_multiramo is not null
						GROUP BY numero_polizza||codice_prodotto||ramo||tipo_liquidazione||data_valuta||codice_fiscale_beneficiario||
									data_comunicazione_pagamento||modalita_pagamento||codice_frazionamento,
				 				R.id
						HAVING COUNT(*) >1) A
			ON tmp.numero_polizza||tmp.codice_prodotto||tmp.ramo||tmp.tipo_liquidazione||tmp.data_valuta||tmp.codice_fiscale_beneficiario||
									tmp.data_comunicazione_pagamento||tmp.modalita_pagamento||tmp.codice_frazionamento = A.numreg
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
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (ramo,
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
															riproponibile
														)
												VALUES (	res_scarti_movimenti_mono(j).ramo,
															res_scarti_movimenti_mono(j).codice_prodotto,
															res_scarti_movimenti_mono(j).numero_polizza,
															res_scarti_movimenti_mono(j).data_comunicazione_pagamento,
															res_scarti_movimenti_mono(j).codice_fiscale_beneficiario,
															res_scarti_movimenti_mono(j).modalita_pagamento,
															res_scarti_movimenti_mono(j).frazionario_di_emissione,
															res_scarti_movimenti_mono(j).tipo_liquidazione,
															res_scarti_movimenti_mono(j).codice_frazionamento,
															res_scarti_movimenti_mono(j).data_effetto_polizza,
															res_scarti_movimenti_mono(j).data_scadenza,
															res_scarti_movimenti_mono(j).data_valuta,
															res_scarti_movimenti_mono(j).data_competenza,
															res_scarti_movimenti_mono(j).codice_fiscale_contraente,
															res_scarti_movimenti_mono(j).strumento_di_pagamento,
															res_scarti_movimenti_mono(j).importo_pagato,
															res_scarti_movimenti_mono(j).interesse_mora,
															res_scarti_movimenti_mono(j).ritenuta_interesse_mora,
															res_scarti_movimenti_mono(j).costo_liquidazione,
															res_scarti_movimenti_mono(j).imposta_sostitutiva,
															res_scarti_movimenti_mono(j).imposta_bollo,
															res_scarti_movimenti_mono(j).importo_pagato_coass, 
															res_scarti_movimenti_mono(j).costo_liquidazione_coass,
															res_scarti_movimenti_mono(j).imposta_sostitutiva_coass,
															res_scarti_movimenti_mono(j).imposta_bollo_coass,
															res_scarti_movimenti_mono(j).interesse_mora_coass,
															res_scarti_movimenti_mono(j).ritenuta_interesse_mora_coass,
															res_scarti_movimenti_mono(j).data_calcolo_pagamento,
															res_scarti_movimenti_mono(j).costo_etf, 
															res_scarti_movimenti_mono(j).numero_pratica,
															res_scarti_movimenti_mono(j).codice_linea,
															sysdate,
															'CHIAVE PRIMARIA "NUMREG, IDRAPPORTO" DUPLICATA',
															'N'
															);
					
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_mono.FIRST .. res_scarti_movimenti_mono.LAST
			        	
			        DELETE FROM TMP_PFMOV_PAG_COASS tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_mono(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE (NUMREG, IDRAPPORTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_mono;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE (NUMREG, IDRAPPORTO) DUPLICATA: ' || totale);
	COMMIT;
	
	
	
	OPEN scarti_movimenti_multi;
	LOOP
			FETCH scarti_movimenti_multi BULK COLLECT INTO res_scarti_movimenti_multi LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_multi.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_multi.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_COASS (ramo,
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
															riproponibile
														)
												VALUES (	res_scarti_movimenti_multi(j).ramo,
															res_scarti_movimenti_multi(j).codice_prodotto,
															res_scarti_movimenti_multi(j).numero_polizza,
															res_scarti_movimenti_multi(j).data_comunicazione_pagamento,
															res_scarti_movimenti_multi(j).codice_fiscale_beneficiario,
															res_scarti_movimenti_multi(j).modalita_pagamento,
															res_scarti_movimenti_multi(j).frazionario_di_emissione,
															res_scarti_movimenti_multi(j).tipo_liquidazione,
															res_scarti_movimenti_multi(j).codice_frazionamento,
															res_scarti_movimenti_multi(j).data_effetto_polizza,
															res_scarti_movimenti_multi(j).data_scadenza,
															res_scarti_movimenti_multi(j).data_valuta,
															res_scarti_movimenti_multi(j).data_competenza,
															res_scarti_movimenti_multi(j).codice_fiscale_contraente,
															res_scarti_movimenti_multi(j).strumento_di_pagamento,
															res_scarti_movimenti_multi(j).importo_pagato,
															res_scarti_movimenti_multi(j).interesse_mora,
															res_scarti_movimenti_multi(j).ritenuta_interesse_mora,
															res_scarti_movimenti_multi(j).costo_liquidazione,
															res_scarti_movimenti_multi(j).imposta_sostitutiva,
															res_scarti_movimenti_multi(j).imposta_bollo,
															res_scarti_movimenti_multi(j).importo_pagato_coass, 
															res_scarti_movimenti_multi(j).costo_liquidazione_coass,
															res_scarti_movimenti_multi(j).imposta_sostitutiva_coass,
															res_scarti_movimenti_multi(j).imposta_bollo_coass,
															res_scarti_movimenti_multi(j).interesse_mora_coass,
															res_scarti_movimenti_multi(j).ritenuta_interesse_mora_coass,
															res_scarti_movimenti_multi(j).data_calcolo_pagamento,
															res_scarti_movimenti_multi(j).costo_etf, 
															res_scarti_movimenti_multi(j).numero_pratica,
															res_scarti_movimenti_multi(j).codice_linea,
															sysdate,
															'CHIAVE PRIMARIA "NUMREG, IDRAPPORTO" DUPLICATA',
															'N'
															);
					
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST
			        	
			        DELETE FROM TMP_PFMOV_PAG_COASS tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_multi(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE (NUMREG, IDRAPPORTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_multi;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_COASS MONO PER CHIAVE (NUMREG, IDRAPPORTO) DUPLICATA: ' || totale);
	COMMIT;
END;