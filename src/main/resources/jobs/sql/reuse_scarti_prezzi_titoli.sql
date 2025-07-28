DECLARE

CURSOR reuse_scarti_prezzi_fk IS
	SELECT /*+ parallel(8) */ scarto.ROWID, scarto.*, tmp.ROWID AS tmp_rowid
	FROM tbl_scarti_tmp_pfprezzi_titoli scarto
	LEFT JOIN tmp_pfprezzi_titoli tmp
		ON tmp.codicebanca = scarto.codicebanca
		AND tmp.codicetitolo = scarto.codicetitolo
	AND tmp.dataprezzo=scarto.dataprezzo
	WHERE riproponibile='S';

I 					NUMBER(38,0):= 0;
count_reuse_prezzi	NUMBER :=0;

BEGIN 
	
	 
	
	
	
	FOR cur_item IN reuse_scarti_prezzi_fk 
	LOOP
	
	I := I+1;
	
	IF (cur_item.tmp_rowid IS NULL) THEN 
		
		INSERT /*+ append nologging parallel(8) */
				INTO tmp_pfprezzi_titoli (	codicebanca,                
											codicetitolo,               
											dataprezzo,                
											codicedivisa,               
											prezzocontrovalore,        
											prezzomercato,              
											rateolordo,                 
											rateonetto,                 
											rateodisaggio,              
											ritenutadisaggio,           
											datarateo,                  
											codicefonte,                
											coefficientecorrezione,     
											poolfactor,                 
											coefficienteindicizzazione, 
											descrcoeffindicizzazione,   
											moltiplicatore,             
											prezzocontrovalorelordista, 
											dataaggiornamento          
											) 
							VALUES (cur_item.codicebanca,                
									cur_item.codicetitolo,               
									cur_item.dataprezzo,                
									cur_item.codicedivisa,               
									to_number(cur_item.prezzocontrovalore, '999999999999999999999999999.999999999999999999999999999'),       
									to_number(cur_item.prezzomercato, '999999999999999999999999999.999999999999999999999999999'),             
									to_number(cur_item.rateolordo, '999999999999999999999999999.999999999999999999999999999'),               
									to_number(cur_item.rateonetto, '999999999999999999999999999.999999999999999999999999999'),               
									to_number(cur_item.rateodisaggio, '999999999999999999999999999.999999999999999999999999999'),              
									to_number(cur_item.ritenutadisaggio, '999999999999999999999999999.999999999999999999999999999'),           
									cur_item.datarateo,                  
									cur_item.codicefonte,                
									to_number(cur_item.coefficientecorrezione, '999999999999999999999999999.999999999999999999999999999'),     
									to_number(cur_item.poolfactor, '999999999999999999999999999.999999999999999999999999999'),                 
									to_number(cur_item.coefficienteindicizzazione, '999999999999999999999999999.999999999999999999999999999'), 
									cur_item.descrcoeffindicizzazione,   
									to_number(cur_item.moltiplicatore, '999999999999999999999999999.999999999999999999999999999'),            
									to_number(cur_item.prezzocontrovalorelordista, '999999999999999999999999999.999999999999999999999999999'),
									cur_item.dataaggiornamento          
									);
		END IF;
			
		count_reuse_prezzi := count_reuse_prezzi +1;

		DELETE /*+ nologging */ FROM tbl_scarti_tmp_pfprezzi_titoli del_scarto
		WHERE del_scarto.ROWID = cur_item.ROWID;	
	
	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFPREZZI_TITOLI - COMMIT ON ROW: '|| I);
		COMMIT; 
		END IF;
		
	END LOOP;
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' REUSE SCARTI TMP_PFPREZZI_TITOLI - RECORD ANALIZZATI: '|| I || '; RECORD RIUTILIZZATI: ' || count_reuse_prezzi);
	COMMIT;
END; 