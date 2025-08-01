/**
*	INSERT NELLA TEMP_DELTA DEI RAPPORTI DA INSERIRE
*/
DECLARE
i INTEGER;
BEGIN
	
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'TEMP_RAP_IDX_DELTA';
	IF i = 0 THEN
	    EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX RENDIMPC.TEMP_RAP_IDX_DELTA ON RAPPORTO(NDG,CODICERAPPORTO,TIPO,ID_BUONO_ORIGINARIO) TABLESPACE RENDIMPC_INDEX PARALLEL 8';
			EXECUTE IMMEDIATE 'ALTER INDEX TEMP_RAP_IDX_DELTA NOPARALLEL';
	END IF;
	
	dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'RAPPORTO', degree => 4, estimate_percent=>1);

	INSERT /*+APPEND NOLOGGING PARALLEL(8)*/  INTO TEMP_DELTARAPPORTO (CODICEBANCA,CODICERAPPORTO,NDG,CODICEAGENZIA,TIPORAPPORTO,PERIMETRO,C_SOTTORAPPORTO,NDG_SECONDARIO,DT_APERTURA,DT_CHIUSURA,STATO,ID,IDPTF)
 		SELECT CODICEBANCA,CODICERAPPORTO,NDG,CODICEAGENZIA,TIPORAPPORTO,PERIMETRO,C_SOTTORAPPORTO,NDG_SECONDARIO,DT_APERTURA,DT_CHIUSURA,STATO,ID_RAPPORTO_SEQ.nextval,ID_PTF_SEQ.nextval FROM TEMP_RAPPORTO T
		WHERE NOT EXISTS (SELECT 1 FROM RAPPORTO R WHERE  R.NDG=T.NDG
											          AND R.CODICERAPPORTO=T.CODICERAPPORTO
											          AND R.TIPO=T.TIPORAPPORTO 
											          AND R.ID_BUONO_ORIGINARIO IS NULL);

	COMMIT;
	
END;
