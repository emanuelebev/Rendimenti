CREATE OR REPLACE FUNCTION PARALLEL_SALDI_REND_SOTT_GIORN (
	SALDI_REND_SOTT_GIORN IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION saldi_rend_sott_giorn BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE SALDI_REND_SOTT_GIORN_TYPE_CUR IS RECORD (
        							
IDPTF              	NUMBER,        
CODICEBANCA        	VARCHAR2(256), 
CODICEFILIALE      	VARCHAR2(256), 
CODICERAPPORTO     	VARCHAR2(256), 
CODICETITOLO       	VARCHAR2(256), 
DATA               	NUMBER,        
CTV                	FLOAT(126),    
CTVVALUTA          	FLOAT(126),    
DATAAGGIORNAMENTO  	NUMBER,        
DIVISA             	VARCHAR2(256), 
FLAG_CONSOLIDATO   	VARCHAR2(256), 
ID_RAPPORTO        	VARCHAR2(256), 
CTV_VERSATO        	FLOAT(126),    
CTV_PRELEVATO      	FLOAT(126),    
CTV_VERSATO_NETTO  	FLOAT(126),    
CODICE_UNIVERSO_PZ 	VARCHAR2(256), 
RAMO               	VARCHAR2(256), 
SOTTOSTANTE_PZ     	VARCHAR2(256), 
DATA_SALDO_NAV_PZ  	DATE,          
LINEA_PZ           	VARCHAR2(256), 
DESCR_LINEA_PZ     	VARCHAR2(256), 
DATA_COMPLEANNO_PZ 	DATE,          
IS_CALC_COSTI_IMP  	VARCHAR2(50),
NUMERO_QUOTE		FLOAT(126),
NAV 				FLOAT(126),
COD_TIPO_ATTIVITA 	VARCHAR2(255)
);
    
    
TYPE saldi_rend_sott_giorn_TYPE IS TABLE OF saldi_rend_sott_giorn_TYPE_cur;

res_saldi_rend_sott_giorn saldi_rend_sott_giorn_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;


			
BEGIN
							
		LOOP
			FETCH saldi_rend_sott_giorn BULK COLLECT INTO res_saldi_rend_sott_giorn LIMIT ROWS;
             	EXIT WHEN res_saldi_rend_sott_giorn.COUNT = 0;  
			
			I:=0;
			I:= res_saldi_rend_sott_giorn.COUNT;
				
			FORALL J IN res_saldi_rend_sott_giorn.FIRST .. res_saldi_rend_sott_giorn.LAST	
			
			MERGE 
			INTO SALDO_REND_SOTT_POL sott
			 	 USING (SELECT 	res_saldi_rend_sott_giorn(j).idptf         					AS idptf,
			 	 				res_saldi_rend_sott_giorn(j).codicebanca         			AS codicebanca,
				  				res_saldi_rend_sott_giorn(j).codicefiliale 					AS codicefiliale,
							    res_saldi_rend_sott_giorn(j).codicerapporto 				AS codicerapporto,
							    res_saldi_rend_sott_giorn(j).codicetitolo					AS codicetitolo,
							    res_saldi_rend_sott_giorn(j).DATA							AS DATA,
							    res_saldi_rend_sott_giorn(j).ctv 							AS ctv,
							    res_saldi_rend_sott_giorn(j).ctvvaluta 						AS ctvvaluta,
							    res_saldi_rend_sott_giorn(j).dataaggiornamento 				AS dataaggiornamento,
							    res_saldi_rend_sott_giorn(j).divisa 						AS divisa,
							    res_saldi_rend_sott_giorn(j).flag_consolidato 				AS flag_consolidato,
							    res_saldi_rend_sott_giorn(j).id_rapporto 					AS id_rapporto,
							    res_saldi_rend_sott_giorn(j).ctv_versato 					AS ctv_versato,
							    res_saldi_rend_sott_giorn(j).ctv_prelevato 					AS ctv_prelevato,
							    res_saldi_rend_sott_giorn(j).ctv_versato_netto 				AS ctv_versato_netto,
							    res_saldi_rend_sott_giorn(j).codice_universo_pz 			AS codice_universo_pz,
							    res_saldi_rend_sott_giorn(j).ramo 							AS ramo,
							    res_saldi_rend_sott_giorn(j).sottostante_pz 				AS sottostante_pz,
							    res_saldi_rend_sott_giorn(j).data_saldo_nav_pz 				AS data_saldo_nav_pz,
							    res_saldi_rend_sott_giorn(j).linea_pz 						AS linea_pz,
							    res_saldi_rend_sott_giorn(j).descr_linea_pz 				AS descr_linea_pz,
							    res_saldi_rend_sott_giorn(j).data_compleanno_pz				AS data_compleanno_pz,
							    res_saldi_rend_sott_giorn(j).is_calc_costi_imp				AS is_calc_costi_imp,
							    res_saldi_rend_sott_giorn(j).numero_quote					AS numero_quote,
							    res_saldi_rend_sott_giorn(j).nav							AS nav,
							    res_saldi_rend_sott_giorn(j).cod_tipo_attivita				AS cod_tipo_attivita
					FROM dual
					) tomerge
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
				    sott.is_calc_costi_imp = tomerge.is_calc_costi_imp, 
				    sott.numero_quote = tomerge.numero_quote, 
				    sott.nav = tomerge.nav, 
				    sott.cod_tipo_attivita = tomerge.cod_tipo_attivita
		  	
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
						    is_calc_costi_imp,
						    numero_quote,
						    nav,
						    cod_tipo_attivita
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
						    tomerge.is_calc_costi_imp,
						    tomerge.numero_quote,
						    tomerge.nav,
						    tomerge.cod_tipo_attivita
							);
					
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT GIORNALIERO - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END;