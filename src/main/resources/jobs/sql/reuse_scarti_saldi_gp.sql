DECLARE

CURSOR del_cur IS
	SELECT /*+ parallel(8) */ scarto.ROWID AS scarto_rowid, 
			scarto.*, 
			tmp.ROWID AS tmp_rowid
	FROM tbl_scarti_tmp_pfsaldi_gp scarto
	LEFT JOIN tmp_pfsaldi_gp tmp
		ON( tmp.numero_deposito = scarto.numero_deposito
			AND tmp.numero_sottodeposito = scarto.numero_sottodeposito
			AND tmp.codicetitolo_interno = scarto.codicetitolo_interno
			AND tmp.data_saldo = scarto.data_saldo)
	WHERE scarto.riproponibile = 'S';

I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN

	FOR cur_item IN del_cur 

		LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
		INSERT /*+ append nologging parallel(8) */
				INTO tmp_pfsaldi_gp (	numero_deposito,
										numero_sottodeposito,
										codicetitolo_interno,
										importo_concordato,
										data_saldo,
										quantita,
										ctv_carico,
										ctv_mercato,
										portafoglio_id
									)
								VALUES (cur_item.numero_deposito,
										cur_item.numero_sottodeposito,
										cur_item.codicetitolo_interno,
										to_number(cur_item.importo_concordato, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.data_saldo,
										to_number(cur_item.quantita, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.ctv_carico, '999999999999999999999999999.999999999999999999999999999'),
										to_number(cur_item.ctv_mercato, '999999999999999999999999999.999999999999999999999999999'),
										cur_item.portafoglio_id
								);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM tbl_scarti_tmp_pfsaldi_gp tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDI_GP. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFSALDI_GP. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;