DECLARE

I 				INTEGER;
X				INTEGER;
check_ix_sals 	INTEGER:=0;
check_ix_movs 	INTEGER:=0;


BEGIN

	SELECT COUNT(*) INTO I FROM all_tables WHERE UPPER(table_name)=UPPER('SQUADRATURE_CTV_MOVS') AND OWNER='RENDIMPC';
	SELECT COUNT(*) INTO X FROM all_tables WHERE UPPER(table_name)=UPPER('SQUADRATURE_CTV_SALS') AND OWNER='RENDIMPC';

	IF (I = 1) THEN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE RENDIMPC.SQUADRATURE_CTV_MOVS';
		COMMIT;
	END IF;
	
	IF (X = 1) THEN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE RENDIMPC.SQUADRATURE_CTV_SALS';
	   COMMIT;
	END IF;
	
	SELECT COUNT(*) INTO check_ix_sals FROM user_indexes WHERE index_name = 'IX_TMP_SALS_DATA' AND table_owner = 'RENDIMPC';
	IF check_ix_sals = 1 THEN
		EXECUTE IMMEDIATE 'DROP INDEX RENDIMPC.IX_TMP_SALS_DATA';
	END IF;
	
	SELECT COUNT(*) INTO check_ix_sals FROM user_indexes WHERE index_name = 'IX_SALS' AND table_owner = 'RENDIMPC';
	IF check_ix_sals = 1 THEN
		EXECUTE IMMEDIATE 'DROP INDEX RENDIMPC.IX_SALS';
	END IF;
		
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Tabelle SQUADRATURE_CTV_MOVS e SQUADRATURE_CTV_SALS troncate!');
	COMMIT;	
	
	SELECT COUNT(*) INTO X FROM USER_tables WHERE table_name='TMP_SRX';
	IF (X = 0) THEN
	     EXECUTE IMMEDIATE 'CREATE TABLE TMP_SRX ( 
						IDPTF NUMBER,
 						CODICETITOLO VARCHAR2(30),
 						MAXDATA NUMBER) NOLOGGING TABLESPACE TBS_RENDIMPC_DATA_TEMP';
 	END IF;
 
 	EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_SRX';
 	
	
	COMMIT;
	
END;       
