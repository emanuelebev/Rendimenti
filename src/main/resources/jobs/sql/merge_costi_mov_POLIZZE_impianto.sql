-- Deve essere generato un movimento di costo nei casi in cui sono valorizzati i campi della movimento

DECLARE 

    rowcounts 	NUMBER;
	check_ix 	integer;


BEGIN
	
execute immediate 'alter table COSTO_MOVIMENTO nologging';
execute immediate 'alter table COSTO_MOVIMENTO parallel 8';

select count(*) into check_ix from user_indexes where index_name = 'IX_RAPPORTO_IDTIPO' and table_owner = 'RENDIMPC';                        
if (check_ix = 0) then
	execute immediate 'CREATE INDEX RENDIMPC.IX_RAPPORTO_IDTIPO ON RENDIMPC.RAPPORTO (ID,TIPO) TABLESPACE RENDIMPC_INDEX';
end if;

MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 			as codice_banca,
          		'PZ_DIRFISSO' 		as codice_costo,
          		MOV.idrapporto		as idrapporto,
          		MOV.numreg 			as numreg,
          		MOV.diritto_fisso 	as importo,
          		'CM' 				as tipo_fonte,
          		null 				as data_da,
          		null 				as data_a,
          		sysdate 			as data_aggiornamento,
          		null 			    as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.diritto_fisso != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
	
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_DIRFISSO IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
	
MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 			as codice_banca,
          		'PZ_PROVV_ACQ' 		as codice_costo,
          		MOV.idrapporto		as idrapporto,
          		MOV.numreg 			as numreg,
          		MOV.provv_acquisto 	as importo,
          		'CM' 				as tipo_fonte,
          		null 				as data_da,
          		null 				as data_a,
          		sysdate 			as data_aggiornamento,
          		null 			    as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.provv_acquisto != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;

INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_PROVV_ACQ IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
   
MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 			as codice_banca,
          		'PZ_PROVV_INCASSO' 	as codice_costo,
          		MOV.idrapporto		as idrapporto,
          		MOV.numreg 			as numreg,
          		MOV.provv_incasso	as importo,
          		'CM' 				as tipo_fonte,
          		null 				as data_da,
          		null 				as data_a,
          		sysdate 			as data_aggiornamento,
          		null 				as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.provv_incasso != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
          
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_PROVV_INCASSO IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
	
MERGE INTO COSTO_MOVIMENTO CMOV
	USING (
          SELECT   
          		'07601' 				as codice_banca,
          		'PZ_INTERESSE_MORA' 	as codice_costo,
          		MOV.idrapporto			as idrapporto,
          		MOV.numreg 				as numreg,
          		MOV.interesse_mora		as importo,
          		'CM' 					as tipo_fonte,
          		null 					as data_da,
          		null 					as data_a,
          		sysdate 				as data_aggiornamento,
          		null 					as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.interesse_mora != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
	
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_INTERESSE_MORA IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
	
MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 				as codice_banca,
          		'PZ_RITINTERESSE_MORA'	as codice_costo,
          		MOV.idrapporto			as idrapporto,
          		MOV.numreg 				as numreg,
          		MOV.rit_interesse_mora	as importo,
          		'CM' 					as tipo_fonte,
          		null 					as data_da,
          		null 					as data_a,
          		sysdate 				as data_aggiornamento,
          		null 					as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.rit_interesse_mora != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;

INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_RITINTERESSE_MORA IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;   
	
	rowcounts :=0;
   
MERGE INTO COSTO_MOVIMENTO CMOV
	USING (
          SELECT   
          		'07601' 				as codice_banca,
          		'PZ_LIQUIDAZIONE'		as codice_costo,
          		MOV.idrapporto			as idrapporto,
          		MOV.numreg 				as numreg,
          		MOV.costo_liquidazione 	as importo,
          		'CM' 					as tipo_fonte,
          		null 					as data_da,
          		null 					as data_a,
          		sysdate 				as data_aggiornamento,
          		null 					as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.costo_liquidazione != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
	
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_LIQUIDAZIONE IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
	
MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 				as codice_banca,
          		'PZ_IMPSOSTITUTIVA'		as codice_costo,
          		MOV.idrapporto			as idrapporto,
          		MOV.numreg 				as numreg,
          		MOV.imposta_sostitutiva	as importo,
          		'CM' 					as tipo_fonte,
          		null 					as data_da,
          		null 					as data_a,
          		sysdate 				as data_aggiornamento,
          		null 					as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.imposta_sostitutiva != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;

INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_IMPSOSTITUTIVA IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
      
MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 			as codice_banca,
          		'PZ_IMPBOLLO'		as codice_costo,
          		MOV.idrapporto		as idrapporto,
          		MOV.numreg 			as numreg,
          		MOV.imposta_bollo 	as importo,
          		'CM' 				as tipo_fonte,
          		null 				as data_da,
          		null 				as data_a,
          		sysdate 			as data_aggiornamento,
          		null 				as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.imposta_bollo != 0 AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
          		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_IMPBOLLO IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
	
MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 				as codice_banca,
          		'PZ_CARICO'				as codice_costo,
          		MOV.idrapporto			as idrapporto,
          		MOV.numreg 				as numreg,
          		nvl(MOV.caricamento,0) 	as importo,
          		'CM' 					as tipo_fonte,
          		null 					as data_da,
          		null 					as data_a,
          		sysdate 				as data_aggiornamento,
          		null 					as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE (mov.caricamento != 0 AND mov.caricamento is not null) 
          	AND RAPP.tipo = '13'
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
          		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_CARICO IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
	rowcounts :=0;
	
MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 			as codice_banca,
          		'PZ_IMPOSTE_CAR'	as codice_costo,
          		MOV.idrapporto		as idrapporto,
          		MOV.numreg 			as numreg,
          		MOV.tassazione 		as importo,
          		'CM' 				as tipo_fonte,
          		null 				as data_da,
          		null 				as data_a,
          		sysdate 			as data_aggiornamento,
          		null 				as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          WHERE mov.tassazione != 0  AND RAPP.tipo = '13' --il campo imposte viene mappato nella colonna tassazione
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
          		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_IMPOSTE_CAR IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
	
/*	rowcounts :=0;
	
	MERGE INTO COSTO_MOVIMENTO CMOV
 	USING (
          SELECT   
          		'07601' 		as codice_banca,
          		'PZ_ALTRO'		as codice_costo,
          		MOV.idrapporto	as idrapporto,
          		MOV.numreg 		as numreg,
          		MOV.tassazione 	as importo,
          		'CM' 			as tipo_fonte,
          		null 			as data_da,
          		null 			as data_a,
          		sysdate 		as data_aggiornamento,
          		null 		as ssa
          FROM MOVIMENTO MOV
         	 INNER JOIN RAPPORTO RAPP 
         	 	ON MOV.idrapporto = RAPP.id
          		AND RAPP.tipo = '13'
          WHERE mov.altri_costi != 0
        ) TOMERGE
  ON
  (CMOV.idrapporto = TOMERGE.idrapporto
   AND CMOV.numreg = TOMERGE.numreg
   AND CMOV.codice_banca = TOMERGE.codice_banca
   AND CMOV.codice_costo = TOMERGE.codice_costo) 
    
   WHEN MATCHED THEN UPDATE
  SET  	
  	CMOV.importo = TOMERGE.importo,
  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
  	CMOV.data_da = TOMERGE.data_da,
  	CMOV.data_a = TOMERGE.data_a,
  	CMOV.ssa = TOMERGE.ssa,
  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
  	
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
	  	ssa,
	  	data_aggiornamento
	 )
  VALUES 
  (	  	TOMERGE.codice_banca,
	  	TOMERGE.codice_costo,
	  	TOMERGE.idrapporto,
	  	TOMERGE.numreg,
	  	TOMERGE.importo,
	  	TOMERGE.tipo_fonte,
	  	TOMERGE.data_da,
	  	TOMERGE.data_a,
	  	TOMERGE.ssa,
	  	TOMERGE.data_aggiornamento
	);
	
	rowcounts := SQL%ROWCOUNT;
	
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTI PZ_ALTRO IN COSTO_MOVIMENTO: ' || rowcounts);
	COMMIT;
*/

execute immediate 'alter table COSTO_MOVIMENTO logging';
execute immediate 'alter table COSTO_MOVIMENTO parallel 1';

select count(*) into check_ix from user_indexes where index_name = 'IX_RAPPORTO_IDTIPO' and table_owner = 'RENDIMPC';                        
if (check_ix != 0) then
	execute immediate 'DROP INDEX RENDIMPC.IX_RAPPORTO_IDTIPO';
end if;

END;