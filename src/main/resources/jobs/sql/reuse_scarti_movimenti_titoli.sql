DECLARE

CURSOR del_cur IS
SELECT /*+ parallel(4) */ scarto.ROWID AS scarto_rowid, scarto.*, tmp.ROWID AS tmp_rowid
FROM TBL_SCARTI_TMP_PFMOV_TITOLI scarto
LEFT JOIN TMP_PFMOV_TITOLI tmp
	ON tmp.codice = scarto.codice
	AND case when tmp.tiporapporto = '02'
				then nvl(tmp.codiceinterno,'LIQ_EUR_LIB')
					else tmp.codiceinterno end = case when scarto.tiporapporto = '02'
						      						then nvl(scarto.codiceinterno,'LIQ_EUR_LIB')
						          					 	else scarto.codiceinterno end
	AND tmp.codicerapporto = scarto.codicerapporto
WHERE scarto.riproponibile = 'S';

I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN
	
	FOR cur_item IN del_cur 

		LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
		INSERT /*+ append nologging parallel(4) */
				INTO TMP_PFMOV_TITOLI (	codicebanca,
										codice,
										codiceagenzia,
										codicerapporto,
										tiporapporto,
										codiceinterno,
										causale,
										ctvregolato,
										ctvmercato,
										ctvregolatodivisa,
										ctvmercatodivisa,
										divisa,
										quantita,
										prezzomercato,
										prezzo,
										rateolordo,
										rateonetto,
										cambio,
										dataordine,
										datacontabile,
										datavaluta,
										flagstorno,
										codicestorno,
										flagcancellato,
										imposte,
										commissioni,
										dataaggiornamento,
										imposta_rest,
										quantita_da_sistemare
									)
								VALUES (cur_item.codicebanca,
										cur_item.codice,
										cur_item.codiceagenzia,
										cur_item.codicerapporto,
										cur_item.tiporapporto,
										cur_item.codiceinterno,
										cur_item.causale,
										to_number(cur_item.ctvregolato, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.ctvmercato, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.ctvregolatodivisa, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.ctvmercatodivisa, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.divisa,
										to_number(cur_item.quantita, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.prezzomercato, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.prezzo, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.rateolordo, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.rateonetto, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.cambio, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.dataordine,
										cur_item.datacontabile,
										cur_item.datavaluta,
										cur_item.flagstorno,
										cur_item.codicestorno,
										cur_item.flagcancellato,
										to_number(cur_item.imposte, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.commissioni, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.dataaggiornamento,
										to_number(cur_item.imposta_rest, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.quantita_da_sistemare, '999999999999999999999999999.999999999999999999999999999')
										);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM TBL_SCARTI_TMP_PFMOV_TITOLI tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_TITOLI. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFMOV_TITOLI. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;