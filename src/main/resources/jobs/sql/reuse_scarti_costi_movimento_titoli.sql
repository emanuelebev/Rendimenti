DECLARE

CURSOR del_cur IS
SELECT /*+ parallel(8) */  scarto.ROWID AS scarto_rowid, scarto.*, tmp.ROWID AS tmp_rowid
FROM TBL_SCARTI_TMP_PFCOSTI_TITOLI scarto
LEFT JOIN TMP_PFCOSTI_TITOLI tmp
	ON tmp.codicebanca = scarto.codicebanca
	AND tmp.codicemovimento = scarto.codicemovimento
	AND tmp.codicecosto = scarto.codicecosto
	AND tmp.tiporapporto = scarto.tiporapporto
WHERE scarto.riproponibile='S';

I 				NUMBER(38,0):=0;
reuse_count		NUMBER(38,0):=0;	


BEGIN
	
	 
	
	
	
	FOR cur_item IN del_cur 

		LOOP
			
		I := I+1;
		
		IF(cur_item.tmp_rowid IS NULL) THEN
		
			INSERT /*+ append nologging parallel(8) */
			INTO TMP_PFCOSTI_TITOLI (	codicebanca, 
										codicemovimento, 
										codicecosto, 
										importo,   
										fonte, 
										tiporapporto,  
										dataaggiornamento 
										)
								VALUES (cur_item.codicebanca,
										cur_item.codicemovimento,
										cur_item.codicecosto,
										to_number(cur_item.importo,'999999999999999999999999999.999999999999999999999999999'),
										cur_item.fonte,
										cur_item.tiporapporto,
										cur_item.dataaggiornamento
										);
										
				reuse_count := reuse_count + 1;			
				
			END IF;		
			
			DELETE /*+ nologging */ FROM TBL_SCARTI_TMP_PFCOSTI_TITOLI tbl
			WHERE tbl.ROWID = cur_item.scarto_rowid;
						
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCOSTI_TITOLI. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCOSTI_TITOLI. RECORD RECUPERATI: ' || reuse_count);
		COMMIT;

END;