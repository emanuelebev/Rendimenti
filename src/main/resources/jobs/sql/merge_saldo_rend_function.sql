CREATE OR REPLACE FUNCTION PARALLEL_SALDI_REND (
	saldi_rend IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION saldi_rend BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE saldi_rend_TYPE_cur IS RECORD (
        							
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
CODICERAPPORTO_ORI        	 		VARCHAR2(256),
COD_FASCIARENDIMENTO_BFP            VARCHAR2(256),
DESCR_FASCIARENDIMENTO_BFP          VARCHAR2(256),
SERIE_BFP                           VARCHAR2(256),
VALORE_SCADENZA_LORDO_BFP           FLOAT(126),
FLAG_LORDISTA_BFP                   VARCHAR2(256),
IMPORTO_NETTO_BFP                   FLOAT(126),
VALORE_SCADENZA_NETTO_BFP           FLOAT(126),
VALORE_NOMINALE_BFP                 FLOAT(126),
DATASOTTOSCRIZIONE                  DATE,
DATASCADENZA                        DATE          
);
    
    
    
TYPE saldi_rend_TYPE IS TABLE OF saldi_rend_TYPE_cur;

RES_saldi_rend saldi_rend_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;


			
BEGIN
							
		LOOP
			FETCH saldi_rend BULK COLLECT INTO RES_saldi_rend LIMIT ROWS;
             	EXIT WHEN RES_saldi_rend.COUNT = 0;  
			
			I:=0;
			I:= RES_saldi_rend.COUNT;
				
			FORALL J IN RES_saldi_rend.FIRST .. RES_saldi_rend.LAST	
			
				MERGE INTO
					saldo_rend sr
						USING (
								SELECT
									RES_saldi_rend(j).idptf								AS idptf,
									RES_saldi_rend(j).codicebanca						AS codicebanca,
									RES_saldi_rend(j).codicefiliale 					AS codicefiliale,
									RES_saldi_rend(j).codicerapporto					AS codicerapporto,
									RES_saldi_rend(j).codicetitolo 						AS codicetitolo,
									RES_saldi_rend(j)."DATA" 							AS "DATA",
									RES_saldi_rend(j).ctv 								AS ctv,
									RES_saldi_rend(j).ctvvaluta 						AS ctvvaluta,
									RES_saldi_rend(j).dataaggiornamento 				AS dataaggiornamento,
									RES_saldi_rend(j).divisa 							AS divisa,
									RES_saldi_rend(j).flag_consolidato 					AS flag_consolidato,
									RES_saldi_rend(j).id_rapporto 						AS id_rapporto,
									RES_saldi_rend(j).ctv_versato 						AS ctv_versato,
									RES_saldi_rend(j).ctv_prelevato 					AS ctv_prelevato,
									RES_saldi_rend(j).ctv_versato_netto 				AS ctv_versato_netto,
									RES_saldi_rend(j).codicerapporto_ori 				AS codicerapporto_ori,
									RES_saldi_rend(j).cod_fasciarendimento_bfp 			AS cod_fasciarendimento_bfp,
									RES_saldi_rend(j).descr_fasciarendimento_bfp 		AS descr_fasciarendimento_bfp,
									RES_saldi_rend(j).serie_bfp 						AS serie_bfp,
									RES_saldi_rend(j).valore_scadenza_lordo_bfp 		AS valore_scadenza_lordo_bfp,
									RES_saldi_rend(j).flag_lordista_bfp 				AS flag_lordista_bfp,
									RES_saldi_rend(j).importo_netto_bfp 				AS importo_netto_bfp,
									RES_saldi_rend(j).valore_scadenza_netto_bfp 		AS valore_scadenza_netto_bfp,
									RES_saldi_rend(j).valore_nominale_bfp 				AS valore_nominale_bfp,
									RES_saldi_rend(j).datasottoscrizione 				AS datasottoscrizione,
									RES_saldi_rend(j).datascadenza						AS datascadenza
								FROM dual
								)T
					 ON(sr.idptf = t.idptf
						AND sr.codicetitolo = t.codicetitolo
						AND sr."DATA" = t."DATA")
						
				WHEN MATCHED THEN UPDATE
						SET
							sr.codicebanca = t.codicebanca,
							sr.codicefiliale = t.codicefiliale,
							sr.codicerapporto = t.codicerapporto,
							sr.ctv = t.ctv,
							sr.ctvvaluta = t.ctvvaluta,
							sr.dataaggiornamento = t.dataaggiornamento,
							sr.divisa = t.divisa,
							sr.flag_consolidato = t.flag_consolidato,
							sr.id_rapporto = t.id_rapporto,
							sr.ctv_versato = t.ctv_versato ,
							sr.ctv_prelevato = t.ctv_prelevato,
							sr.ctv_versato_netto = t.ctv_versato_netto,
							sr.codicerapporto_ori = t.codicerapporto_ori,
							sr.cod_fasciarendimento_bfp = t.cod_fasciarendimento_bfp,
							sr.descr_fasciarendimento_bfp = t.descr_fasciarendimento_bfp,
							sr.serie_bfp = t.serie_bfp,
							sr.valore_scadenza_lordo_bfp = t.valore_scadenza_lordo_bfp,
							sr.flag_lordista_bfp = t.flag_lordista_bfp,
							sr.importo_netto_bfp = t.importo_netto_bfp,
							sr.valore_scadenza_netto_bfp = t.valore_scadenza_netto_bfp,
							sr.valore_nominale_bfp = t.valore_nominale_bfp,
							sr.datasottoscrizione = t.datasottoscrizione,
							sr.datascadenza = t.datascadenza
				
						WHEN NOT MATCHED 
							THEN INSERT
									( idptf,
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
									codicerapporto_ori,
									cod_fasciarendimento_bfp,	
									descr_fasciarendimento_bfp,	
									serie_bfp,					
									valore_scadenza_lordo_bfp,	
									flag_lordista_bfp,		
									importo_netto_bfp,			
									valore_scadenza_netto_bfp,
									valore_nominale_bfp,	
									datasottoscrizione,			
									datascadenza
									)
							VALUES( t.idptf ,
									t.codicebanca ,
									t.codicefiliale ,
									t.codicerapporto ,
									t.codicetitolo ,
									t."DATA",
									t.ctv ,
									t.ctvvaluta ,
									t.dataaggiornamento ,
									t.divisa ,
									t.flag_consolidato ,
									t.id_rapporto ,
									t.ctv_versato ,
									t.ctv_prelevato ,
									t.ctv_versato_netto ,
									t.codicerapporto_ori,
									t.cod_fasciarendimento_bfp,	
									t.descr_fasciarendimento_bfp,	
									t.serie_bfp,					
									t.valore_scadenza_lordo_bfp,	
									t.flag_lordista_bfp,		
									t.importo_netto_bfp,			
									t.valore_scadenza_netto_bfp,
									t.valore_nominale_bfp,	
									t.datasottoscrizione,			
									t.datascadenza
									);
					
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END;