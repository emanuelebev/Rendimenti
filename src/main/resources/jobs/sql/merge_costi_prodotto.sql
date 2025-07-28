DECLARE 

	rowcounts NUMBER;
	

BEGIN
   
 MERGE INTO
    movimento mov
  USING (
          SELECT
            rapp.ID                                        															AS idrapporto,
            substr(tcost.codiceinterno,2)																			AS codicetitolo,
          	'CCR_'||tcost.codicerapporto||'_'||tcost.codiceinterno||'_'||tcost.dataa||'_'||tcost.flag_storno		AS numreg,
          	tcost.tiporapporto																						AS c_procedura,
          	tcost.importo																							AS ctv,
          	TO_NUMBER(TO_CHAR(TO_DATE(tcost.dataa, 'YYYY-MM-DD'), 'YYYYMMDD'))	   									AS data,
          	TO_NUMBER(TO_CHAR(TO_DATE(tcost.dataa, 'YYYY-MM-DD'), 'YYYYMMDD'))	   									AS valuta,
		    NULL																		    						AS datacont,
          	'S' 																									AS flag_fittiziocosti,
          	'CST_SRV'																								AS causale
          FROM TMP_COSTI_PRODOTTO tcost
          INNER JOIN rapporto rapp 
            ON rapp.codicebanca = tcost.codicebanca 
	           --AND rapp.codiceagenzia = tcost.codiceagenzia
	            AND rapp.codicerapporto = tcost.codicerapporto
	            AND rapp.tipo = tcost.tiporapporto
       ) tomerge
  ON
  (mov.idrapporto = tomerge.idrapporto
   AND mov.numreg = tomerge.numreg)
   
  WHEN MATCHED THEN UPDATE
  SET
    mov.causale = tomerge.causale,
    mov.c_procedura = tomerge.c_procedura,
    mov.ctv = tomerge.ctv,
    mov.data = tomerge.data,
    mov.valuta = tomerge.valuta,
    mov.datacont = tomerge.datacont,
    mov.codicetitolo = tomerge.codicetitolo,
    mov.flag_fittiziocosti = tomerge.flag_fittiziocosti
    
  WHEN NOT MATCHED THEN 
  INSERT
	    (idrapporto,
	     numreg,
	     c_procedura,
	     ctv,
	     data,
	     valuta,
	     datacont,
	     codicetitolo,
	     flag_fittiziocosti,
	     causale)
  VALUES (	tomerge.idrapporto,
		    tomerge.numreg,
		    tomerge.c_procedura,
		   	tomerge.ctv,
		   	tomerge.data,
		   	tomerge.valuta,
		    tomerge.datacont,
			tomerge.codicetitolo,
			tomerge.flag_fittiziocosti,
			tomerge.causale);
			
  	COMMIT;
  	
  	rowcounts := SQL%ROWCOUNT;

INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' MERGE MOVIMENTO TMP_COSTI_PRODOTTO RIGHE: ' || rowcounts);
COMMIT;


MERGE INTO
    costo_movimento cmov
  USING (
          SELECT 	tcost.codicebanca  																					AS codice_banca,
		            tcost.codicecosto     																				AS codice_costo,
		            rapp.ID               																				AS idrapporto,
		            'CCR_'||tcost.codicerapporto||'_'||tcost.codiceinterno||'_'||tcost.dataa||'_'||tcost.flag_storno 	AS numreg,
		            tcost.importo         																				AS importo,
		            'CCR'                  																				AS tipo_fonte,
		            TO_NUMBER(TO_CHAR(TO_DATE(tcost.datada, 'YYYY-MM-DD'), 'YYYYMMDD'))	   								AS data_da,
		            TO_NUMBER(TO_CHAR(TO_DATE(tcost.dataa , 'YYYY-MM-DD'), 'YYYYMMDD'))	    							AS data_a,
		            TO_DATE(tcost.dataaggiornamento, 'YYYY-MM-DD HH24:MI:SS')											AS data_aggiornamento
          FROM TMP_COSTI_PRODOTTO tcost
          INNER JOIN rapporto rapp 
            ON rapp.codicebanca = tcost.codicebanca 
           -- AND rapp.codiceagenzia = tcost.codiceagenzia
            AND rapp.codicerapporto = tcost.codicerapporto
            AND rapp.tipo = tcost.tiporapporto
        ) tomerge
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
    tomerge.data_aggiornamento
  );
  
  COMMIT;
  
  rowcounts := SQL%ROWCOUNT;
  
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' MERGE COSTO_MOVIMENTO TMP_COSTI_PRODOTTO RIGHE: ' || rowcounts);
  COMMIT;
  
END;