DECLARE

CURSOR DEL_CUR IS
	SELECT /*+ parallel(8) */ SCARTO.ROWID AS SCARTO_ROWID, 
			SCARTO.*, 
			TMP.ROWID AS TMP_ROWID
	FROM TBL_SCARTI_TMP_PFMOV_GP SCARTO
	LEFT JOIN TMP_PFMOV_GP TMP
		ON( TMP.CODICE_TRANSAZIONE = SCARTO.CODICE_TRANSAZIONE)
	WHERE SCARTO.RIPROPONIBILE = 'S';

I 				NUMBER(38,0):=0;
REUSE_COUNT		NUMBER(38,0):=0;	


BEGIN

	FOR CUR_ITEM IN DEL_CUR 

		LOOP
			
		I := I+1;
		
		IF(CUR_ITEM.TMP_ROWID IS NULL) THEN
		
		INSERT /*+ append nologging parallel(8) */
				INTO TMP_PFMOV_GP (	codice_transazione,
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
									id_prodotto,
									upfront_fee_lorda, 
									upfront_fee_netta, 	
									upfront_fee_retrocessioni
								)
						VALUES (cur_item.codice_transazione,
								cur_item.data_settlement,
								cur_item.data_transazione,
								cur_item.numero_deposito,
								cur_item.numero_sottodeposito,
								cur_item.codicetitolo_interno,
								TO_NUMBER(cur_item.importo_transato, '999999999999999999999999999.999999999999999999999999999'),
								cur_item.causale_movimento,
								TO_NUMBER(cur_item.quantita_ordinata, '999999999999999999999999999.999999999999999999999999999'),
								TO_NUMBER(cur_item.quantita_effettiva, '999999999999999999999999999.999999999999999999999999999'),
								cur_item.segno,
								TO_NUMBER(cur_item.commissioni, '999999999999999999999999999.999999999999999999999999999'),
								cur_item.divisa_trattazione,
								TO_NUMBER(cur_item.cambio, '999999999999999999999999999.999999999999999999999999999'),
								cur_item.canale_ordine,
								cur_item.ndg,
								cur_item.codicefiscale,
								cur_item.id_prodotto,
								cur_item.upfront_fee_lorda, 
								cur_item.upfront_fee_netta, 	
								cur_item.upfront_fee_retrocessioni
								);
										
				REUSE_COUNT := REUSE_COUNT + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM TBL_SCARTI_TMP_PFMOV_GP TBL
			WHERE TBL.ROWID = CUR_ITEM.SCARTO_ROWID;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_GP. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_GP. RECORD RECUPERATI: ' || REUSE_COUNT);
		COMMIT;

END;