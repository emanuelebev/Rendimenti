DECLARE 

    var_perc  NUMBER;
    rowcounts NUMBER;

BEGIN
	
    var_perc := 26/100;

    MERGE INTO
    costo_movimento cmov
    USING (SELECT   '07601'                     AS codice_banca,
                    'CGLib'                     AS codice_costo, 
                    rapp.ID                     AS idrapporto, 
                    tmp.codice                  AS numreg, 
                    (ctvregolato * var_perc)    AS importo,
                    NULL                        AS tipo_fonte,
                    NULL                        AS data_da,
                    NULL                        AS data_a,
                    NULL                        AS ssa, 
                    sysdate                     AS data_aggiornamento
			FROM tmp_pfmovimenti tmp
                INNER JOIN rapporto rapp 
						ON tmp.codicerapporto = rapp.codicerapporto
          				AND tmp.codicebanca = rapp.codicebanca
          				AND tmp.tiporapporto = rapp.tipo 
            WHERE tmp.tiporapporto = '02'
            AND causale = '500'
        ) tomerge
  ON
  (cmov.idrapporto = tomerge.idrapporto
   AND cmov.numreg = tomerge.numreg
   AND cmov.codice_banca = tomerge.codice_banca
   AND cmov.codice_costo = tomerge.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	cmov.importo = tomerge.importo,
  	cmov.tipo_fonte = tomerge.tipo_fonte,
  	cmov.data_da = tomerge.data_da,
  	cmov.data_a = tomerge.data_a,
  	cmov.data_aggiornamento = tomerge.data_aggiornamento
  	
  	WHEN NOT MATCHED THEN
  INSERT
    (	codice_banca,
	  	codice_costo,
	  	idrapporto,
	  	numreg,
	  	importo,
	  	tipo_fonte,
	  	data_da,
	  	data_a,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	tomerge.codice_banca,
	  	tomerge.codice_costo,
	  	tomerge.idrapporto,
	  	tomerge.numreg,
	  	tomerge.importo,
	  	tomerge.tipo_fonte,
	  	tomerge.data_da,
	  	tomerge.data_a,
	  	tomerge.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;

INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI CGLib IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;

END;