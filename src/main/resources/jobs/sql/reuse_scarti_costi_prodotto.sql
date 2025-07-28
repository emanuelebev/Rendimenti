DECLARE

CURSOR del_cur IS
	SELECT  /*+ parallel(8) */ scarto.ROWID AS scarto_rowid, scarto.*, tmp.ROWID AS tmp_rowid
	FROM TBL_SCARTI_TMP_COSTI_PRODOTTO scarto
	LEFT JOIN TMP_COSTI_PRODOTTO tmp
		ON tmp.codicebanca = scarto.codicebanca
			AND tmp.codicerapporto = scarto.codicerapporto
			AND tmp.tiporapporto = scarto.tiporapporto
			AND tmp.codiceinterno = scarto.codiceinterno
			AND tmp.codicecosto = scarto.codicecosto
			AND tmp.dataa = scarto.dataa
			AND tmp.datada = scarto.datada
			AND tmp.flag_storno = scarto.flag_storno
	WHERE scarto.riproponibile = 'S';
	
I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN

FOR cur_item IN del_cur 
	LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
				INSERT /*+ append nologging parallel(8) */
						INTO TMP_COSTI_PRODOTTO (	codicebanca,
													codiceagenzia,
													codicerapporto,
													tiporapporto,
													codiceinterno,
													codicecosto,
													datada,
													dataa,
													importo,
													fonte,
													dataaggiornamento
												)
								VALUES (cur_item.codicebanca,
										cur_item.codiceagenzia,
										cur_item.codicerapporto,
										cur_item.tiporapporto,
										cur_item.codiceinterno,
										cur_item.codicecosto,
										cur_item.datada,
										cur_item.dataa,
										to_number(cur_item.importo,'999999999999999999999999999.999999999999999999999999999'),
										cur_item.fonte,
										cur_item.dataaggiornamento
									);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM TBL_SCARTI_TMP_COSTI_PRODOTTO tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_COSTI_PRODOTTO. COMMIT ON ROW: ' || I);
		COMMIT;
	END IF;

	END LOOP;
	
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_COSTI_PRODOTTO. RECORD RECUPERATI: ' || reuse_count);
	COMMIT;

END;