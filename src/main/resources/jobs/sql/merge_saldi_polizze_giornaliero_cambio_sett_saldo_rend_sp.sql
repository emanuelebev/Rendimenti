-- Dalla parcheggio SALDO_REND_POLIZZE vengono travasati nella SALDO_REND 
-- se la massima data dell'ultima polizza SP arrivata  è maggiore della massima data delle polizze SP in essere
-- maxyearweeksp > t1sp
-- a questo punto vengono travasate tutte le polizze presenti nella parcheggio con data <= t1sp  
DECLARE 

maxyearweeksp 	NUMBER;
t1sp 				NUMBER;

CURSOR merge_saldi_parc IS
	SELECT /*+ PARALLEL(8) */ 
			sp.idptf 					AS idptf,
	        sp.codicebanca				AS codicebanca,
	        sp.codicefiliale 			AS codicefiliale,
	        sp.codicerapporto			AS codicerapporto,
	        sp.codicetitolo			    AS codicetitolo,
	        sp."DATA"					AS "DATA",
	        sp.ctv 					    AS ctv,
	        sp.ctvvaluta				AS ctvvaluta,
	        sp.dataaggiornamento		AS dataaggiornamento,
	        sp.divisa					AS divisa,
	        sp.flag_consolidato		    AS flag_consolidato,
	        sp.id_rapporto				AS id_rapporto,
	        sp.ctv_versato				AS ctv_versato,
	        sp.ctv_prelevato			AS ctv_prelevato,
	        sp.ctv_versato_netto		AS ctv_versato_netto,
	        sp.codice_universo_pz		AS codice_universo_pz,
	        sp.ramo					    AS ramo,
	        sp.sottostante_pz			AS sottostante_pz,
	        sp.data_saldo_nav_pz		AS data_saldo_nav_pz,
	        sp.linea_pz				    AS linea_pz,
	        sp.descr_linea_pz			AS descr_linea_pz,
	        sp.data_compleanno_pz		AS data_compleanno_pz,
	        sp.is_calc_costi_imp		AS is_calc_costi_imp,
	        sp.saldo_pol				AS saldo_pol,
	        sp.saldo_pol_sp			    AS saldo_pol_sp
	        FROM saldo_rend_polizze sp
	        WHERE (idptf, codicetitolo, DATA) IN ( SELECT	idptf,
												        	codicetitolo,
												        	MAX(DATA) 		AS DATA
													FROM saldo_rend_polizze 
													WHERE yearweek <= t1sp
												    AND tipo_pol = 'SP'
												    GROUP BY idptf, codicetitolo, yearweek)
	        ORDER BY idptf, codicetitolo, DATA;
		
TYPE merge_saldi_parc_type IS TABLE OF merge_saldi_parc%rowtype INDEX BY PLS_INTEGER;
	
res_merge_saldi_parc merge_saldi_parc_type;
	
ROWS    PLS_INTEGER := 10000;

I 		NUMBER(38,0):=0;
totale	NUMBER(38,0):=0;
	        
		
BEGIN
	
	SELECT /*+ PARALLEL(8) */ valore 
    INTO maxyearweeksp
    FROM maxdata_polizze 
    WHERE chiave = 'maxyearweeksp';
    
	SELECT /*+ PARALLEL(8) */ valore
	INTO t1sp
	FROM maxdata_polizze 
    WHERE chiave = 't1sp';
    

IF (maxyearweeksp > t1sp) THEN

    OPEN merge_saldi_parc; 
		LOOP
			FETCH merge_saldi_parc BULK COLLECT INTO res_merge_saldi_parc LIMIT ROWS;
				EXIT WHEN res_merge_saldi_parc.COUNT = 0;  
			
			I:=0;
			I:= res_merge_saldi_parc.COUNT;
			totale := totale + I;
				
		FORALL j IN res_merge_saldi_parc.FIRST .. res_merge_saldi_parc.LAST		

    MERGE /*+ NOLOGGING PARALLEL(8) */ 
    	INTO saldo_rend sr
	    USING (SELECT   res_merge_saldi_parc(j).idptf 				AS idptf,
				        res_merge_saldi_parc(j).codicebanca			AS codicebanca,
				        res_merge_saldi_parc(j).codicefiliale 		AS codicefiliale,
				        res_merge_saldi_parc(j).codicerapporto		AS codicerapporto,
				        res_merge_saldi_parc(j).codicetitolo		AS codicetitolo,
				        res_merge_saldi_parc(j).DATA				AS DATA,
				        res_merge_saldi_parc(j).ctv  				AS ctv,
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
				        res_merge_saldi_parc(j).is_calc_costi_imp	AS is_calc_costi_imp,
				        res_merge_saldi_parc(j).saldo_pol			AS saldo_pol,
				        res_merge_saldi_parc(j).saldo_pol_sp		AS saldo_pol_sp
				FROM dual
            ) tomerge
	ON (sr.idptf = tomerge.idptf
		AND sr.codicetitolo = tomerge.codicetitolo
		AND sr."DATA" = tomerge."DATA")
        
WHEN MATCHED THEN
 UPDATE SET sr.codicebanca = tomerge.codicebanca,
            sr.codicefiliale = tomerge.codicefiliale,
            sr.codicerapporto = tomerge.codicerapporto,
            sr.ctv = tomerge.ctv,
            sr.ctvvaluta = tomerge.ctvvaluta,
            sr.dataaggiornamento = tomerge.dataaggiornamento,
            sr.divisa = tomerge.divisa,
            sr.flag_consolidato = tomerge.flag_consolidato,
            sr.id_rapporto = tomerge.id_rapporto,
            sr.ctv_versato = tomerge.ctv_versato,
            sr.ctv_prelevato = tomerge.ctv_prelevato,
            sr.ctv_versato_netto = tomerge.ctv_versato_netto,
            sr.codice_universo_pz = tomerge.codice_universo_pz,
            sr.ramo = tomerge.ramo,
            sr.sottostante_pz = tomerge.sottostante_pz,
            sr.data_saldo_nav_pz = tomerge.data_saldo_nav_pz,
            sr.linea_pz = tomerge.linea_pz,
            sr.descr_linea_pz = tomerge.descr_linea_pz,
            sr.data_compleanno_pz = tomerge.data_compleanno_pz,
            sr.is_calc_costi_imp = tomerge.is_calc_costi_imp,
            sr.saldo_pol = tomerge.saldo_pol,
            sr.saldo_pol_sp = tomerge.saldo_pol_sp
        
WHEN NOT MATCHED THEN
INSERT (idptf,
        codicebanca,
        codicefiliale,
        codicerapporto,
        codicetitolo,
        "DATA",
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
        is_calc_costi_imp,
        saldo_pol,
        saldo_pol_sp
    )
    VALUES( tomerge.idptf,
            tomerge.codicebanca,
            tomerge.codicefiliale,
            tomerge.codicerapporto,
            tomerge.codicetitolo,
            tomerge."DATA",
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
            tomerge.is_calc_costi_imp,
            tomerge.saldo_pol,
            tomerge.saldo_pol_sp
            );

	IF MOD(I,10000) = 0 THEN
			    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP POLIZZE WEEK - COMMIT ON ROW: '|| I);
			COMMIT;
		END IF;
		
		END LOOP;
		
		CLOSE merge_saldi_parc;
		
			INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_POLIZZE SP POLIZZE WEEK - COMMIT ON ROW: ' || totale);
		COMMIT;     
	
END IF;

END;  