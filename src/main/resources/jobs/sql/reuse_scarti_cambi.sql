DECLARE

CURSOR reuse_scarti_cambi_fk IS
SELECT /*+ parallel(8) */ scarto.ROWID, scarto.*, tmp.ROWID AS tmp_rowid
FROM tbl_scarti_tmp_pfcambi scarto
LEFT JOIN tmp_pfcambi tmp
	ON tmp.codicebanca = scarto.codicebanca
AND tmp.codicedivisacerto = scarto.codicedivisacerto
AND tmp.codicedivisaincerto=scarto.codicedivisaincerto
AND tmp.datacambio=scarto.datacambio
WHERE riproponibile='S';

I 					NUMBER(38,0):= 0;
count_reuse_cambi	NUMBER :=0;

BEGIN 
	
	 
	
	
	
	FOR cur_item IN reuse_scarti_cambi_fk 
	LOOP
	
		I := I+1;
		
		IF (cur_item.tmp_rowid IS NULL) THEN 
			
			INSERT /*+ append nologging parallel(8) */
				INTO tmp_pfcambi 	(	codicebanca,
								        codicedivisacerto,
								        codicedivisaincerto,
								        datacambio,
								        cambio,
								        dataaggiornamento       
										) 
								VALUES (
										cur_item.codicebanca,                
										cur_item.codicedivisacerto,               
										cur_item.codicedivisaincerto,                
										cur_item.datacambio,               
										to_number(cur_item.cambio, '999999999999999999999999999.999999999999999999999999999'),     
										cur_item.dataaggiornamento        
										);
		END IF;
				
			count_reuse_cambi := count_reuse_cambi +1;
	
			DELETE /*+ nologging */ FROM tbl_scarti_tmp_pfcambi del_scarto
			WHERE del_scarto.ROWID = cur_item.ROWID;	
		
		IF MOD(I,10000) = 0 THEN
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCAMBI - COMMIT ON ROW: '|| I);
			COMMIT; 
		END IF;
		
	END LOOP;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFCAMBI - RECORD ANALIZZATI: '|| I || '; RECORD RIUTILIZZATI: ' || count_reuse_cambi);
	COMMIT;
END; 