DECLARE

CURSOR scarti_movimenti_multi IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_PFMOV_PAG_FONDO tmp
	INNER JOIN (SELECT ramo, codice_prodotto, numero_polizza, data_comunicazione_pagamento, cf_beneficiario, modalita_pagamento, codice_fondo, NVL(codice_attivita,'-1')  as codice_attivita
		    FROM TMP_PFMOV_PAG_FONDO 
		    GROUP BY ramo, codice_prodotto, numero_polizza, data_comunicazione_pagamento, cf_beneficiario, modalita_pagamento, codice_fondo, NVL(codice_attivita,'-1')
		    HAVING COUNT(*) >1 ) A
	ON tmp.ramo = A.ramo
		AND tmp.codice_prodotto = A.codice_prodotto
		AND tmp.numero_polizza = A.numero_polizza
		AND tmp.data_comunicazione_pagamento = A.data_comunicazione_pagamento
		AND tmp.cf_beneficiario = A.cf_beneficiario
		AND tmp.modalita_pagamento = A.modalita_pagamento
		AND tmp.codice_fondo = A.codice_fondo
		AND NVL(tmp.codice_attivita,'-1') = NVL(A.codice_attivita,'-1');

TYPE scarti_movimenti_multi_type IS TABLE OF scarti_movimenti_multi%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_movimenti_multi scarti_movimenti_multi_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_movimenti_multi;
	LOOP
			FETCH scarti_movimenti_multi BULK COLLECT INTO res_scarti_movimenti_multi LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_multi.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_multi.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_PAG_FONDO (ramo,
															codice_prodotto,
															numero_polizza,
															data_comunicazione_pagamento,
															cf_beneficiario,
															modalita_pagamento,
															codice_fondo,
															tipologia_liquidazione,
															isin,
															quote,
															nav,
															importo,
															data_nav,
															codice_attivita,
															provvigioni_intermediario,
															costo_etf,
															commissioni_di_gestione,
															numero_pratica,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile
														)
												VALUES (	res_scarti_movimenti_multi(j).ramo,
															res_scarti_movimenti_multi(j).codice_prodotto,
															res_scarti_movimenti_multi(j).numero_polizza,
															res_scarti_movimenti_multi(j).data_comunicazione_pagamento,
															res_scarti_movimenti_multi(j).cf_beneficiario,
															res_scarti_movimenti_multi(j).modalita_pagamento,
															res_scarti_movimenti_multi(j).codice_fondo,
															res_scarti_movimenti_multi(j).tipologia_liquidazione,
															res_scarti_movimenti_multi(j).isin,
															res_scarti_movimenti_multi(j).quote,
															res_scarti_movimenti_multi(j).nav,
															res_scarti_movimenti_multi(j).importo,
															res_scarti_movimenti_multi(j).data_nav,
															res_scarti_movimenti_multi(j).codice_attivita,
															res_scarti_movimenti_multi(j).provvigioni_intermediario,
															res_scarti_movimenti_multi(j).costo_etf,
															res_scarti_movimenti_multi(j).commissioni_di_gestione,
															res_scarti_movimenti_multi(j).numero_pratica,
															SYSDATE,
															'CHIAVE PRIMARIA "RAMO, CODICE_PRODOTTO, NUMERO_POLIZZA, DATA_COMUNICAZIONE_PAGAMENTO, CF_BENEFICIARIO, MODALITA_PAGAMENTO, CODICE_FONDO" DUPLICATA',
															'N'
														);
				
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST
			        	
			        DELETE FROM TMP_PFMOV_PAG_FONDO tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_multi(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO PER CHIAVE (RAMO, CODICE_PRODOTTO, NUMERO_POLIZZA, DATA_COMUNICAZIONE_PAGAMENTO, CF_BENEFICIARIO, MODALITA_PAGAMENTO, CODICE_FONDO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_multi;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO PER CHIAVE (RAMO, CODICE_PRODOTTO, NUMERO_POLIZZA, DATA_COMUNICAZIONE_PAGAMENTO, CF_BENEFICIARIO, MODALITA_PAGAMENTO, CODICE_FONDO) DUPLICATA: ' || totale);
	COMMIT;
	
END;