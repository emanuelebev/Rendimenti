-- Dalla parcheggio SALDO_REND_SOTT_POL vengono travasati nella SALDO_REND_SOTT 
-- se la massima data dell'ultima polizza arrivata  è maggiore della massima data delle polizze in essere
-- maxyearweek > t1pz
-- a questo punto vengono travasate tutte le polizze presenti nella parcheggio con data <= t1pz 
DECLARE 

maxyearweek 	NUMBER;
t1pz			NUMBER;

CURSOR merge_saldi_parc IS
	SELECT  idptf                         AS idptf,
			codicebanca                   AS codicebanca,
			codicefiliale                 AS codicefiliale,
			codicerapporto                AS codicerapporto,
			codicetitolo                  AS codicetitolo,
			DATA                          AS DATA,
			ctv                           AS ctv,
			ctvvaluta                     AS ctvvaluta,
			dataaggiornamento             AS dataaggiornamento,
			divisa                        AS divisa,
			flag_consolidato              AS flag_consolidato,
			id_rapporto                   AS id_rapporto,
			ctv_versato                   AS ctv_versato,
			ctv_prelevato                 AS ctv_prelevato,
			ctv_versato_netto             AS ctv_versato_netto,
			codice_universo_pz            AS codice_universo_pz,
			ramo                          AS ramo,
			sottostante_pz                AS sottostante_pz,
			data_saldo_nav_pz             AS data_saldo_nav_pz,
			linea_pz                      AS linea_pz,
			descr_linea_pz                AS descr_linea_pz,
			data_compleanno_pz            AS data_compleanno_pz,
			is_calc_costi_imp             AS is_calc_costi_imp
		FROM saldo_rend_sott_pol
		WHERE (idptf, codicetitolo, DATA) IN (	SELECT	idptf,
														codicetitolo,
														MAX(DATA) 		AS DATA
												FROM saldo_rend_sott_pol 
												WHERE yearweek <= t1pz
											    GROUP BY idptf, codicetitolo, yearweek)
		ORDER BY idptf, codicetitolo, DATA;

TYPE merge_saldi_parc_type IS TABLE OF merge_saldi_parc%rowtype INDEX BY PLS_INTEGER;
	
res_merge_saldi_parc merge_saldi_parc_type;
	
ROWS    PLS_INTEGER := 10000;

I 		NUMBER(38,0):=0;
totale	NUMBER(38,0):=0;

		
BEGIN
	
	SELECT /*+ PARALLEL(8) */ valore 
    INTO maxyearweek
    FROM maxdata_polizze 
    WHERE chiave = 'maxyearweek';
    
	SELECT /*+ PARALLEL(8) */ valore
	INTO t1pz
	FROM maxdata_polizze 
    WHERE chiave = 't1pz';
  

IF (maxyearweek > t1pz) THEN

	OPEN merge_saldi_parc; 
		LOOP
			FETCH merge_saldi_parc BULK COLLECT INTO res_merge_saldi_parc LIMIT ROWS;
				EXIT WHEN res_merge_saldi_parc.COUNT = 0;  
			
			I:=0;
			I:= res_merge_saldi_parc.COUNT;
			totale := totale + I;
				
		FORALL j IN res_merge_saldi_parc.FIRST .. res_merge_saldi_parc.LAST		

    MERGE /*+ NOLOGGING PARALLEL(8) */ 
	INTO saldo_rend_sott sott
	USING (SELECT  	res_merge_saldi_parc(j).idptf				AS idptf,
			    	res_merge_saldi_parc(j).codicebanca			AS codicebanca,
				    res_merge_saldi_parc(j).codicefiliale		AS codicefiliale,
				    res_merge_saldi_parc(j).codicerapporto		AS codicerapporto,
				    res_merge_saldi_parc(j).codicetitolo		AS codicetitolo,
				    res_merge_saldi_parc(j).DATA				AS DATA,
				    res_merge_saldi_parc(j).ctv					AS ctv,
				    res_merge_saldi_parc(j).ctvvaluta			AS ctvvaluta,
				    res_merge_saldi_parc(j).dataaggiornamento	AS dataaggiornamento,
				    res_merge_saldi_parc(j).divisa				AS divisa,
				    res_merge_saldi_parc(j).flag_consolidato	AS flag_consolidato,
				    res_merge_saldi_parc(j).id_rapporto			AS id_rapporto,
				    res_merge_saldi_parc(j).ctv_versato			AS ctv_versato,
				    res_merge_saldi_parc(j).ctv_prelevato		AS ctv_prelevato,
				    res_merge_saldi_parc(j).ctv_versato_netto	AS ctv_versato_netto,
				    res_merge_saldi_parc(j).codice_universo_pz	AS codice_universo_pz,
				    res_merge_saldi_parc(j).ramo				AS ramo,
				    res_merge_saldi_parc(j).sottostante_pz		AS sottostante_pz,
				    res_merge_saldi_parc(j).data_saldo_nav_pz	AS data_saldo_nav_pz,
				    res_merge_saldi_parc(j).linea_pz			AS linea_pz,
				    res_merge_saldi_parc(j).descr_linea_pz		AS descr_linea_pz,
				    res_merge_saldi_parc(j).data_compleanno_pz	AS data_compleanno_pz,
				    res_merge_saldi_parc(j).is_calc_costi_imp	AS is_calc_costi_imp
			FROM dual
       )tomerge
       ON (sott.codicetitolo = tomerge.codicetitolo
		  	 AND sott.idptf = tomerge.idptf
		  	 AND sott.DATA = tomerge.DATA
		  	 AND sott.ramo = tomerge.ramo
		  	 AND sott.sottostante_pz = tomerge.sottostante_pz)
		   
	WHEN MATCHED THEN UPDATE
		  SET
		    sott.codicebanca = tomerge.codicebanca,
		    sott.codicefiliale = tomerge.codicefiliale,
		    sott.codicerapporto = tomerge.codicerapporto,
		    sott.ctv = tomerge.ctv,
		    sott.ctvvaluta = tomerge.ctvvaluta,
		    sott.dataaggiornamento = tomerge.dataaggiornamento,
		    sott.flag_consolidato = tomerge.flag_consolidato,
		    sott.id_rapporto = tomerge.id_rapporto,
		    sott.ctv_versato = tomerge.ctv_versato,
		    sott.ctv_prelevato = tomerge.ctv_prelevato,
		    sott.ctv_versato_netto = tomerge.ctv_versato_netto,
		    sott.codice_universo_pz = tomerge.codice_universo_pz,
		    sott.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
		    sott.linea_pz = tomerge.linea_pz,
		    sott.descr_linea_pz = tomerge.descr_linea_pz,
		    sott.data_compleanno_pz = tomerge.data_compleanno_pz,
		    sott.is_calc_costi_imp = tomerge.is_calc_costi_imp  
  	
	WHEN NOT MATCHED THEN 
			INSERT (idptf,
				    codicebanca,
				    codicefiliale,
				    codicerapporto,
				    codicetitolo,
				    DATA,
				    ctv,
				    ctvvaluta,
				    dataaggiornamento,
				    divisa,
				    flag_consolidato,
				    id_rapporto,
				    ctv_versato,
				    ctv_prelevato,
				    ctv_versato_netto,
				    codice_universo_pz,
				    ramo,
				    sottostante_pz,
				    data_saldo_nav_pz,
				    linea_pz,
				    descr_linea_pz,
				    data_compleanno_pz,
				    is_calc_costi_imp
					)
  			VALUES (tomerge.idptf,
				    tomerge.codicebanca,
				    tomerge.codicefiliale,
				    tomerge.codicerapporto,
				    tomerge.codicetitolo,
				    tomerge.DATA,
				    tomerge.ctv,
				    tomerge.ctvvaluta,
				    tomerge.dataaggiornamento,
				    tomerge.divisa,
				    tomerge.flag_consolidato,
				    tomerge.id_rapporto,
				    tomerge.ctv_versato,
				    tomerge.ctv_prelevato,
				    tomerge.ctv_versato_netto,
				    tomerge.codice_universo_pz,
				    tomerge.ramo,
				    tomerge.sottostante_pz,
				    tomerge.data_saldo_nav_pz,
				    tomerge.linea_pz,
				    tomerge.descr_linea_pz,
				    tomerge.data_compleanno_pz,
				    tomerge.is_calc_costi_imp
					);
				
	IF MOD(I,10000) = 0 THEN
			    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT POLIZZE WEEK - COMMIT ON ROW: '|| I);
			COMMIT;
		END IF;
		
		END LOOP;
		
		CLOSE merge_saldi_parc;
		
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT POLIZZE WEEK - COMMIT ON ROW: ' || totale);
		COMMIT;     
	
END IF;

END;