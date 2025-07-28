DECLARE

CURSOR del_cur IS
	SELECT /*+ parallel(4) */ scarto.ROWID AS scarto_rowid, 
			scarto.*, 
			tmp.ROWID AS tmp_rowid
	FROM tbl_scarti_tmp_pfsaldistorici scarto
	LEFT JOIN tmp_pfsaldistorici tmp
		ON( tmp.codiceinterno = scarto.codiceinterno
			AND tmp.codicerapporto = scarto.codicerapporto
			AND tmp.datasaldo = scarto.datasaldo )
	WHERE scarto.riproponibile = 'S';

I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN

	FOR cur_item IN del_cur 

		LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
		INSERT /*+ append nologging parallel(4) */
				INTO tmp_pfsaldistorici (codicebanca,
										codiceagenzia,
										codicerapporto,
										codiceinterno,
										datasaldo,
										tiporapporto,
										controvalore,
										divisa,
										flagconsolidato,
										ctvversato,
										ctvprelevato,
										ctvversatonetto,
										dataaggiornamento,
										codicefasciarendimento,
										decrizionefasciarendimento,
										seriebuono,
										valorescadenzalordo,
										flagnettistalordista,
										importonetto,
										valorescadenzanetto,
										valorenominale,
										datasottoscrizione,			
										datascadenza
										)
								VALUES (cur_item.codicebanca,
										cur_item.codiceagenzia,
										cur_item.codicerapporto,
										cur_item.codiceinterno,
										cur_item.datasaldo,
										cur_item.tiporapporto,
										to_number(cur_item.controvalore, '999999999999999999999999999.999999999999999999999999999'),    
										cur_item.divisa,
										cur_item.flagconsolidato, 
										to_number(cur_item.ctvversato, '999999999999999999999999999.999999999999999999999999999'),    
										to_number(cur_item.ctvprelevato, '999999999999999999999999999.999999999999999999999999999'),    
										to_number(cur_item.ctvversatonetto, '999999999999999999999999999.999999999999999999999999999'),    
										cur_item.dataaggiornamento,
										cur_item.codicefasciarendimento,
										cur_item.decrizionefasciarendimento,
										cur_item.seriebuono,
										to_number(cur_item.valorescadenzalordo, '999999999999999999999999999.999999999999999999999999999'),    
										cur_item.flagnettistalordista,
										to_number(cur_item.importonetto, '999999999999999999999999999.999999999999999999999999999'),    
										to_number(cur_item.valorescadenzanetto, '999999999999999999999999999.999999999999999999999999999'),    
										to_number(cur_item.valorenominale, '999999999999999999999999999.999999999999999999999999999'),    
										cur_item.datasottoscrizione,			
										cur_item.datascadenza
								);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM tbl_scarti_tmp_pfsaldistorici tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDISTORICI. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDISTORICI. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;