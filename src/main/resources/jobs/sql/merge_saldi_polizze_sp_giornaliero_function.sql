CREATE OR REPLACE FUNCTION PARALLEL_SALDI_POLSP_GIORN (
	SALDI_POLSP_GIORN IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION SALDI_POLSP_GIORN BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE SALDI_POLSP_GIORN_TYPE_CUR IS RECORD (
        							
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
SALDO_POL_SP                        FLOAT(126),
TIPO_POL                            VARCHAR2(50)  
);    
    
    
TYPE SALDI_POLSP_GIORN_TYPE IS TABLE OF SALDI_POLSP_GIORN_TYPE_cur;

RES_SALDI_POLSP_GIORN SALDI_POLSP_GIORN_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;


			
BEGIN
							
		LOOP
			FETCH SALDI_POLSP_GIORN BULK COLLECT INTO RES_SALDI_POLSP_GIORN LIMIT ROWS;
             	EXIT WHEN RES_SALDI_POLSP_GIORN.COUNT = 0;  
			
			I:=0;
			I:= RES_SALDI_POLSP_GIORN.COUNT;
				
			FORALL J IN RES_SALDI_POLSP_GIORN.FIRST .. RES_SALDI_POLSP_GIORN.LAST	
			
				MERGE INTO SALDO_REND_POLIZZE sr
		  USING (SELECT RES_SALDI_POLSP_GIORN(j).idptf 					AS idptf,
						RES_SALDI_POLSP_GIORN(j).codicebanca		 	AS codicebanca,
						RES_SALDI_POLSP_GIORN(j).codicefiliale		 	AS codicefiliale,
						RES_SALDI_POLSP_GIORN(j).codicerapporto 	 	AS codicerapporto,
						RES_SALDI_POLSP_GIORN(j).codicetitolo		 	AS codicetitolo,
						RES_SALDI_POLSP_GIORN(j)."DATA"					AS "DATA",
						RES_SALDI_POLSP_GIORN(j).ctv					AS ctv,		
						RES_SALDI_POLSP_GIORN(j).ctvvaluta			 	AS ctvvaluta,
						RES_SALDI_POLSP_GIORN(j).dataaggiornamento	 	AS dataaggiornamento,
						RES_SALDI_POLSP_GIORN(j).divisa					AS divisa,
						RES_SALDI_POLSP_GIORN(j).flag_consolidato	 	AS flag_consolidato,
						RES_SALDI_POLSP_GIORN(j).id_rapporto		 	AS id_rapporto,
						RES_SALDI_POLSP_GIORN(j).ctv_versato		 	AS ctv_versato,
						RES_SALDI_POLSP_GIORN(j).ctv_prelevato		 	AS ctv_prelevato,
						RES_SALDI_POLSP_GIORN(j).ctv_versato_netto	 	AS ctv_versato_netto,
						RES_SALDI_POLSP_GIORN(j).codice_universo_pz  	AS codice_universo_pz,
						RES_SALDI_POLSP_GIORN(j).ramo 				 	AS ramo,
						RES_SALDI_POLSP_GIORN(j).sottostante_pz			AS sottostante_pz,
						RES_SALDI_POLSP_GIORN(j).data_saldo_nav_pz   	AS data_saldo_nav_pz,
						RES_SALDI_POLSP_GIORN(j).linea_pz			 	AS linea_pz,
						RES_SALDI_POLSP_GIORN(j).descr_linea_pz			AS descr_linea_pz,
						RES_SALDI_POLSP_GIORN(j).data_compleanno_pz 	AS data_compleanno_pz,
						RES_SALDI_POLSP_GIORN(j).is_calc_costi_imp   	AS is_calc_costi_imp,
						RES_SALDI_POLSP_GIORN(j).saldo_pol_sp 			AS saldo_pol_sp,
						RES_SALDI_POLSP_GIORN(j).tipo_pol	 			AS tipo_pol
				FROM dual
			) tomerge
			 ON (sr.idptf = tomerge.idptf
			  	 AND sr.codicetitolo = tomerge.codicetitolo
			  	 AND sr."DATA" = tomerge."DATA")

		WHEN MATCHED THEN UPDATE
				  SET sr.codicebanca = tomerge.codicebanca,
					sr.codicefiliale = tomerge.codicefiliale,
					sr.codicerapporto = tomerge.codicerapporto,
					sr.ctv = nvl(sr.saldo_pol,0) + tomerge.ctv,
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
					sr.saldo_pol_sp = tomerge.saldo_pol_sp,
					sr.tipo_pol = tomerge.tipo_pol
					
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
							saldo_pol_sp,
							tipo_pol
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
					tomerge.saldo_pol_sp,
					tomerge.tipo_pol
					);
					
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND SALDI POLIZZE SP GIORNALIERO - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END;