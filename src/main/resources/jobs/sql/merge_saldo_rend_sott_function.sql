CREATE OR REPLACE FUNCTION PARALLEL_SALDI_REND_SOTT (
	saldi_rend_sott IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION saldi_rend_sott BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE saldi_rend_sott_TYPE_cur IS RECORD (
        							
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
IS_CALC_COSTI_IMP  	VARCHAR2(50)  
);
    
    
TYPE saldi_rend_sott_TYPE IS TABLE OF saldi_rend_sott_TYPE_cur;

RES_saldi_rend_sott saldi_rend_sott_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;


			
BEGIN
							
		LOOP
			FETCH saldi_rend_sott BULK COLLECT INTO RES_saldi_rend_sott LIMIT ROWS;
             	EXIT WHEN RES_saldi_rend_sott.COUNT = 0;  
			
			I:=0;
			I:= RES_saldi_rend_sott.COUNT;
				
			FORALL J IN RES_saldi_rend_sott.FIRST .. RES_saldi_rend_sott.LAST	
			
			MERGE 
			INTO saldo_rend_sott sott
			 	 USING (SELECT 	RES_saldi_rend_sott(j).idptf         					AS idptf,
			 	 				RES_saldi_rend_sott(j).codicebanca         				AS codicebanca,
				  				RES_saldi_rend_sott(j).codicefiliale 					AS codicefiliale,
							    RES_saldi_rend_sott(j).codicerapporto 					AS codicerapporto,
							    RES_saldi_rend_sott(j).codicetitolo						AS codicetitolo,
							    RES_saldi_rend_sott(j).DATA								AS DATA,
							    RES_saldi_rend_sott(j).ctv 								AS ctv,
							    RES_saldi_rend_sott(j).ctvvaluta 						AS ctvvaluta,
							    RES_saldi_rend_sott(j).dataaggiornamento 				AS dataaggiornamento,
							    RES_saldi_rend_sott(j).divisa 							AS divisa,
							    RES_saldi_rend_sott(j).flag_consolidato 				AS flag_consolidato,
							    RES_saldi_rend_sott(j).id_rapporto 						AS id_rapporto,
							    RES_saldi_rend_sott(j).ctv_versato 						AS ctv_versato,
							    RES_saldi_rend_sott(j).ctv_prelevato 					AS ctv_prelevato,
							    RES_saldi_rend_sott(j).ctv_versato_netto 				AS ctv_versato_netto,
							    RES_saldi_rend_sott(j).codice_universo_pz 				AS codice_universo_pz,
							    RES_saldi_rend_sott(j).ramo 							AS ramo,
							    RES_saldi_rend_sott(j).sottostante_pz 					AS sottostante_pz,
							    RES_saldi_rend_sott(j).data_saldo_nav_pz 				AS data_saldo_nav_pz,
							    RES_saldi_rend_sott(j).linea_pz 						AS linea_pz,
							    RES_saldi_rend_sott(j).descr_linea_pz 					AS descr_linea_pz,
							    RES_saldi_rend_sott(j).data_compleanno_pz				AS data_compleanno_pz,
							    RES_saldi_rend_sott(j).is_calc_costi_imp				AS is_calc_costi_imp
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
					
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND_SOTT RECUPERO - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END;