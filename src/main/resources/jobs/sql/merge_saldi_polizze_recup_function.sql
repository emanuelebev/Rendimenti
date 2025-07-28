CREATE OR REPLACE FUNCTION PARALLEL_SALDI_POL_RECUP (
	SALDI_POL_RECUP IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION SALDI_POL_RECUP BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE SALDI_POL_RECUP_TYPE_CUR IS RECORD (
        							
IDPTF                      			NUMBER,        
CODICEBANCA                			VARCHAR2(256),
CODICEFILIALE              			VARCHAR2(256),
CODICERAPPORTO             			VARCHAR2(256), 
CODICETITOLO               			VARCHAR2(256), 
DATA                       			NUMBER,      
CTV                       			FLOAT(126),  
CTVVALUTA                  			FLOAT(126),  
DATAAGGIORNAMENTO          			NUMBER,    
DIVISA                     			VARCHAR2(256),
FLAG_CONSOLIDATO           			VARCHAR2(256),
ID_RAPPORTO                			VARCHAR2(256),
CTV_VERSATO                			FLOAT(126),    
CTV_PRELEVATO              			FLOAT(126),  
CTV_VERSATO_NETTO          			FLOAT(126), 
CODICE_UNIVERSO_PZ                  VARCHAR2(256), 
RAMO                                VARCHAR2(256), 
SOTTOSTANTE_PZ                      VARCHAR2(256), 
DATA_SALDO_NAV_PZ                   DATE,         
LINEA_PZ                            VARCHAR2(256), 
DESCR_LINEA_PZ                      VARCHAR2(256), 
DATA_COMPLEANNO_PZ                  DATE,          
IS_CALC_COSTI_IMP                   VARCHAR2(50),  
SALDO_POL                           FLOAT(126)  
);    
    
    
TYPE SALDI_POL_RECUP_TYPE IS TABLE OF SALDI_POL_RECUP_TYPE_cur;

RES_SALDI_POL_RECUP SALDI_POL_RECUP_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;


			
BEGIN
							
		LOOP
			FETCH saldi_pol_recup BULK COLLECT INTO RES_saldi_pol_recup LIMIT ROWS;
             	EXIT WHEN RES_saldi_pol_recup.COUNT = 0;  
			
			I:=0;
			I:= RES_saldi_pol_recup.COUNT;
				
			FORALL J IN RES_saldi_pol_recup.FIRST .. RES_saldi_pol_recup.LAST	
			
				MERGE INTO SALDO_REND sr
		  USING (SELECT RES_saldi_pol_recup(j).idptf 				AS idptf,
						RES_saldi_pol_recup(j).codicebanca		 	AS codicebanca,
						RES_saldi_pol_recup(j).codicefiliale		 	AS codicefiliale,
						RES_saldi_pol_recup(j).codicerapporto 	 	AS codicerapporto,
						RES_saldi_pol_recup(j).codicetitolo		 	AS codicetitolo,
						RES_saldi_pol_recup(j)."DATA"				AS "DATA",
						RES_saldi_pol_recup(j).ctv					AS ctv,		
						RES_saldi_pol_recup(j).ctvvaluta			 	AS ctvvaluta,
						RES_saldi_pol_recup(j).dataaggiornamento	 	AS dataaggiornamento,
						RES_saldi_pol_recup(j).divisa				AS divisa,
						RES_saldi_pol_recup(j).flag_consolidato	 	AS flag_consolidato,
						RES_saldi_pol_recup(j).id_rapporto		 	AS id_rapporto,
						RES_saldi_pol_recup(j).ctv_versato		 	AS ctv_versato,
						RES_saldi_pol_recup(j).ctv_prelevato		 	AS ctv_prelevato,
						RES_saldi_pol_recup(j).ctv_versato_netto	 	AS ctv_versato_netto,
						RES_saldi_pol_recup(j).codice_universo_pz  	AS codice_universo_pz,
						RES_saldi_pol_recup(j).ramo 				 	AS ramo,
						RES_saldi_pol_recup(j).sottostante_pz		AS sottostante_pz,
						RES_saldi_pol_recup(j).data_saldo_nav_pz   	AS data_saldo_nav_pz,
						RES_saldi_pol_recup(j).linea_pz			 	AS linea_pz,
						RES_saldi_pol_recup(j).descr_linea_pz		AS descr_linea_pz,
						RES_saldi_pol_recup(j).data_compleanno_pz 	AS data_compleanno_pz,
						RES_saldi_pol_recup(j).is_calc_costi_imp   	AS is_calc_costi_imp,
						RES_saldi_pol_recup(j).saldo_pol 			AS saldo_pol
				FROM dual
			) tomerge
			 ON (sr.idptf = tomerge.idptf
			  	 AND sr.codicetitolo = tomerge.codicetitolo
			  	 AND sr."DATA" = tomerge."DATA")

		WHEN MATCHED THEN UPDATE
				  SET sr.codicebanca = tomerge.codicebanca,
					sr.codicefiliale = tomerge.codicefiliale,
					sr.codicerapporto = tomerge.codicerapporto,
					sr.ctv = nvl(sr.saldo_pol_sp,0) + tomerge.ctv,
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
					sr.saldo_pol = tomerge.saldo_pol
					
		WHEN NOT MATCHED 
			THEN INSERT	(	idptf,
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
							saldo_pol
							)
			VALUES( tomerge.idptf ,
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
					tomerge.saldo_pol
					);
					
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND SALDI POLIZZE RECUPERO - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END;