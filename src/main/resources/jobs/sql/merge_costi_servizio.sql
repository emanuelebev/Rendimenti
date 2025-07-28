DECLARE

CURSOR costi_serv IS
	SELECT  /*+ parallel(8) */ 	costi_serv.*, 
			R.ID AS idrapporto
		FROM (SELECT  tcost.codicebanca,
		        tcost.codicecliente,
		        tcost.codicemovimento,
		        tcost.codicecosto,
		        tcost.codiceagenzia,
		        tcost.tiporapporto,
		        tcost.datacontabile,
		        tcost.datavaluta,
		        tcost.datada,
		        tcost.dataa,
		        tcost.importo,
		        tcost.dataaggiornamento,
		        MIN(rapp.codicerapporto) AS min_codicerapporto
			FROM tmp_pfcosti_serv tcost
		          INNER JOIN rapporto rapp 
		            ON rapp.codicebanca = tcost.codicebanca 
			            AND substr(rapp.codicerapporto,1,12) = substr(tcost.codicerapporto,1,12)
			            AND rapp.tipo = tcost.tiporapporto
			            AND rapp.ndg = tcost.codicecliente --inseriamo ndg per evitare di prendere il codicerapporto fittizio
			WHERE rapp.tipo in ('15', '97')
		                GROUP BY    tcost.codicebanca,
		                            tcost.codicecliente,
		                            tcost.codicemovimento,
		                            tcost.codicecosto,
		                            tcost.codiceagenzia,
		                            tcost.tiporapporto,
		                            tcost.datacontabile,
		                            tcost.datavaluta,
		                            tcost.datada,
		                            tcost.dataa,
		                            tcost.importo,
		                            tcost.dataaggiornamento
		    ) costi_serv 
		        INNER JOIN rapporto R 
		            ON R.codicebanca = costi_serv.codicebanca 
		            AND R.codicerapporto = costi_serv.min_codicerapporto
		            AND R.tipo = costi_serv.tiporapporto
		            AND R.NDG = costi_serv.codicecliente --inseriamo ndg per evitare di prendere il codicerapporto fittizio
			WHERE R.tipo in ('15', '97')
			ORDER BY R.ID, codicemovimento, codicecosto;
			
	
I 		 NUMBER(38,0):=0;
totale	 NUMBER(38,0):=0;


BEGIN
		
 FOR cur_item IN costi_serv
    LOOP
        I := I+1;

		MERGE INTO 
			MOVIMENTO mov
		  USING (SELECT cur_item.idrapporto          														AS idrapporto,	
						cur_item.codicemovimento||'_'||cur_item.datavaluta									AS numreg,
			          	cur_item.min_codicerapporto															AS codicerapporto_ori,
			          	cur_item.tiporapporto																AS c_procedura,
			          	cur_item.importo																	AS ctv,
			          	TO_NUMBER(TO_CHAR(TO_DATE(cur_item.datavaluta, 'YYYY-MM-DD'), 'YYYYMMDD'))	   		AS data,
					    TO_NUMBER(TO_CHAR(TO_DATE(cur_item.datacontabile , 'YYYY-MM-DD'), 'YYYYMMDD'))	    AS datacont,
			          	'FITT_SERVIZIO'																		AS codicetitolo,
			          	'S' 																				AS flag_fittiziocosti,
			          	'CST_SRV'																			AS causale
			       FROM dual
			    ) tomerge
		  ON (mov.idrapporto = tomerge.idrapporto
		  	 AND mov.numreg = tomerge.numreg)
   
	  WHEN MATCHED THEN UPDATE
	  SET
	    mov.causale = tomerge.causale,
	    mov.codicerapporto_ori = tomerge.codicerapporto_ori,
	    mov.c_procedura = tomerge.c_procedura,
	    mov.ctv = tomerge.ctv,
	    mov.data = tomerge.data,
	    mov.datacont = tomerge.datacont,
	    mov.codicetitolo = tomerge.codicetitolo,
	    mov.flag_fittiziocosti = tomerge.flag_fittiziocosti

  WHEN NOT MATCHED THEN 
		  INSERT
			    (idrapporto,
			     numreg,
			     codicerapporto_ori,
			     c_procedura,
			     ctv,
			     data,
			     datacont,
			     codicetitolo,
			     flag_fittiziocosti,
			     causale)
		  VALUES (	tomerge.idrapporto,
				    tomerge.numreg,
				   	tomerge.codicerapporto_ori,
				    tomerge.c_procedura,
				   	tomerge.ctv,
					tomerge.data,
				    tomerge.datacont,
					tomerge.codicetitolo,
					tomerge.flag_fittiziocosti,
					tomerge.causale);
					
			totale := totale + 1;
					
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE MOVIMENTO TMP_PFCOSTI_SERV: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || '  MERGE MOVIMENTO TMP_PFCOSTI_SERV: ' || totale);
	COMMIT;
 	
	I:= 0;
	totale:= 0;

 FOR cur_item IN costi_serv
    LOOP
        I := I+1;
        
        MERGE INTO
    COSTO_MOVIMENTO cmov
  USING (
          SELECT 	
          			cur_item.codicebanca  															AS codice_banca,
		            cur_item.codicecosto     														AS codice_costo,
		            cur_item.idrapporto         													AS idrapporto, 
		            cur_item.codicemovimento||'_'||cur_item.datavaluta								AS numreg,
		            cur_item.importo         														AS importo,
		            'CCR'                  															AS tipo_fonte,
		            TO_NUMBER(TO_CHAR(TO_DATE(cur_item.datada, 'YYYY-MM-DD'), 'YYYYMMDD'))	   		AS data_da,
		            TO_NUMBER(TO_CHAR(TO_DATE(cur_item.dataa , 'YYYY-MM-DD'), 'YYYYMMDD'))	    	AS data_a,
		            NULL                  															AS ssa,
		            TO_DATE(cur_item.dataaggiornamento, 'YYYY-MM-DD HH24:MI:SS')                    AS data_aggiornamento,
		            NULL                  															AS tipo_rapporto
          FROM dual
        ) TOMERGE
  ON
  (cmov.idrapporto = tomerge.idrapporto
   AND cmov.numreg = tomerge.numreg
   AND cmov.codice_costo = tomerge.codice_costo
  )
  
  WHEN MATCHED THEN
  UPDATE
	  SET
	    cmov.importo = tomerge.importo,
	    cmov.tipo_fonte =  tomerge.tipo_fonte,
	    cmov.data_da = tomerge.data_da,
	    cmov.data_a = tomerge.data_a,
	    cmov.ssa =  tomerge.ssa,
	    cmov.data_aggiornamento = tomerge.data_aggiornamento
    
  WHEN NOT MATCHED THEN
	  INSERT
	    (codice_banca,
	     codice_costo,
	     idrapporto,
	     numreg,
	     importo,
	     tipo_fonte,
	     data_da,
	     data_a,
	     ssa,
	     data_aggiornamento)
	  VALUES (
	    tomerge.codice_banca,
	    tomerge.codice_costo,
	    tomerge.idrapporto,
	    tomerge.numreg,
	    tomerge.importo,
	    tomerge.tipo_fonte,
	    tomerge.data_da,
	    tomerge.data_a,
	    tomerge.ssa,
	    tomerge.data_aggiornamento
	  );
	  
	  totale := totale + 1;
  
  IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_MOVIMENTO TMP_PFCOSTI_SERV: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || '  MERGE COSTO_MOVIMENTO TMP_PFCOSTI_SERV: ' || totale);
	COMMIT;
	
  END;