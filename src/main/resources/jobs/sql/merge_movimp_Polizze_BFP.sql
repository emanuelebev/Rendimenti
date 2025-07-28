DECLARE

CURSOR CERCA_MOV IS 
SELECT  		R.ID		 														AS IDRAPPORTO, 
		        'MOVIMP-'||SR.CODICETITOLO||'-'||SR.CODICERAPPORTO||'-20171231' 	AS NUMREG,
                SR.CODICETITOLO 													AS CODICETITOLO,
                R.TIPO || '_MOVIMP' 												AS CAUSALE,
                '20171231' 															AS DATA,
		        '20171231' 															AS VALUTA,
		        NULL 																AS DATACONT,
		        NULL 																AS CAMBIO,
              	SR.CTV 																AS CTV,		      
                NULL 																AS CTVDIVISA,                   
		        NULL 																AS QTA,
		        'EUR' 																AS DIVISA,
		        TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')) 								AS D_AGGIORNAMENTO,
		        'PDR' 																AS C_PROCEDURA,
		        NULL 																AS CAUSALE_ORI
		FROM SALDO_REND SR
			INNER JOIN RAPPORTO R
			    ON R.IDPTF = SR.IDPTF
		WHERE R.TIPO IN ('03','13') AND SR.DATA = '20171231';
		
I NUMBER(38,0):=0;

check_ix 	integer;

BEGIN

execute immediate 'alter table MOVIMENTO nologging';
execute immediate 'alter table MOVIMENTO parallel 8';

select count(*) into check_ix from user_indexes where index_name = 'IX_RAPPORTO_IDTIPO' and table_owner = 'RENDIMPC';                        
if (check_ix = 0) then
	execute immediate 'CREATE INDEX RENDIMPC.IX_RAPPORTO_IDTIPO ON RENDIMPC.RAPPORTO (ID,TIPO) TABLESPACE RENDIMPC_INDEX';
end if;

	FOR CUR_ITEM IN CERCA_MOV
    LOOP
        I := I+1;

		MERGE INTO MOVIMENTO MOV
			USING (SELECT	CUR_ITEM.IDRAPPORTO AS IDRAPPORTO,
						 	CUR_ITEM.NUMREG AS NUMREG,
							CUR_ITEM.CODICETITOLO AS CODICETITOLO,
							CUR_ITEM.CAUSALE AS CAUSALE,
			 				CUR_ITEM.DATA AS DATA,
			 				CUR_ITEM.DATACONT AS DATACONT,
			 				CUR_ITEM.CAMBIO AS CAMBIO,
							CUR_ITEM.CTV AS CTV,
			 				CUR_ITEM.CTVDIVISA AS CTVDIVISA,
			 				CUR_ITEM.QTA AS QTA,
			 				CUR_ITEM.DIVISA AS DIVISA,
							CUR_ITEM.D_AGGIORNAMENTO AS D_AGGIORNAMENTO,
			 				CUR_ITEM.VALUTA AS VALUTA,
	        				CUR_ITEM. CAUSALE_ORI AS CAUSALE_ORI, 
	         				CUR_ITEM.C_PROCEDURA AS C_PROCEDURA
		FROM DUAL
		) TOMERGE
	ON (MOV.IDRAPPORTO = TOMERGE.IDRAPPORTO
	   AND MOV.NUMREG = TOMERGE.NUMREG)

WHEN MATCHED THEN
 UPDATE SET 
		MOV.CODICETITOLO 	= TOMERGE.CODICETITOLO,
   		MOV.CAUSALE 		= TOMERGE.CAUSALE, 
   		MOV.DATA	 		= TOMERGE.DATA,
   		MOV.DATACONT 		= TOMERGE.DATACONT,
   		MOV.CAMBIO 			= TOMERGE.CAMBIO,
   		MOV.CTV 			= TOMERGE.CTV,
   		MOV.CTVDIVISA 		= TOMERGE.CTVDIVISA,
        MOV.QTA				= TOMERGE.QTA,
        MOV.DIVISA			= TOMERGE.DIVISA,
        MOV.D_AGGIORNAMENTO	= TOMERGE.D_AGGIORNAMENTO,
        MOV.VALUTA			= TOMERGE.VALUTA,
        MOV.CAUSALE_ORI		= TOMERGE.CAUSALE_ORI,
        MOV.C_PROCEDURA		= TOMERGE.C_PROCEDURA

WHEN NOT MATCHED THEN
					INSERT (IDRAPPORTO,
							NUMREG,
							CODICETITOLO,
							CAUSALE,
							DATA,
							DATACONT,
							CAMBIO,
							CTV,
							CTVDIVISA,
							QTA,
							DIVISA,
							D_AGGIORNAMENTO,
							VALUTA,
					        CAUSALE_ORI, 
					        C_PROCEDURA
					        ) 
					VALUES (TOMERGE.IDRAPPORTO,
							TOMERGE.NUMREG,
							TOMERGE.CODICETITOLO,
							TOMERGE.CAUSALE,
							TOMERGE.DATA,
							TOMERGE.DATACONT,
							TOMERGE.CAMBIO,
							TOMERGE.CTV,
							TOMERGE.CTVDIVISA,
							TOMERGE.QTA,
							TOMERGE.DIVISA,
							TOMERGE.D_AGGIORNAMENTO,
							TOMERGE.VALUTA,
							TOMERGE.CAUSALE_ORI, 
							TOMERGE.C_PROCEDURA
					        );
		
		IF MOD(I,10000) = 0 THEN
		    INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' MERGE MOVIMENTI IMPIANTO CTV - COMMIT ON ROW: '|| I);
		COMMIT;
END IF;
	
END LOOP;

execute immediate 'alter table MOVIMENTO logging';
execute immediate 'alter table MOVIMENTO parallel 1';

select count(*) into check_ix from user_indexes where index_name = 'IX_RAPPORTO_IDTIPO' and table_owner = 'RENDIMPC';                        
if (check_ix != 0) then
	execute immediate 'DROP INDEX RENDIMPC.IX_RAPPORTO_IDTIPO';
end if;

INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' MERGE MOVIMENTI IMPIANTO CTV - COMMIT ON ROW: ' || I);
COMMIT;

END;