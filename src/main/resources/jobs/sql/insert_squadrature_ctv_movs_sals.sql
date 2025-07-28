DECLARE

I 				INTEGER;
X				INTEGER;
check_ix_sals 	INTEGER:=0;
check_ix_movs 	INTEGER:=0;
BEGIN

	INSERT /*+ APPEND NOLOGGING PARALLEL(8) */ INTO TMP_SRX 
	SELECT /*+ PARALLEL(8) */ A.IDPTF, A.CODICETITOLO, MAX(A.DATA) AS MAXDATA 
	FROM SALDO_REND A
	GROUP BY A.IDPTF, A.CODICETITOLO;
	COMMIT;
	
	SELECT COUNT(*) INTO check_ix_sals FROM user_indexes WHERE index_name = 'IX_TMP_SALS_DATA' AND table_owner = 'RENDIMPC';
	IF check_ix_sals = 0 THEN
		EXECUTE IMMEDIATE 'CREATE INDEX RENDIMPC.IX_TMP_SALS_DATA ON RENDIMPC.TMP_SRX (IDPTF, CODICETITOLO, MAXDATA) parallel 8 nologging INITRANS 8 TABLESPACE TBS_RENDIMPC_IDX_TEMP';
	END IF;
	
	dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'TMP_SRX', degree => 4, estimate_percent=>10, cascade=>true);

	INSERT /*+ APPEND NOLOGGING PARALLEL(8) */ INTO SQUADRATURE_CTV_SALS ( IDPTF, CODICETITOLO, DATA, CTV) 
	SELECT /*+ PARALLEL(8) */ SR.IDPTF, SR.CODICETITOLO, SR.DATA, SR.CTV 
	FROM SALDO_REND SR INNER JOIN TMP_SRX SRX 
	ON SR.IDPTF = SRX.IDPTF AND SR.CODICETITOLO = SRX.CODICETITOLO AND SR.DATA = SRX.MAXDATA;
	COMMIT;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Tabella squadrature_ctv_sals riempita');
	COMMIT;

	SELECT COUNT(*) INTO check_ix_sals FROM user_indexes WHERE index_name = 'IX_SALS' AND table_owner = 'RENDIMPC';
	IF check_ix_sals = 0 THEN
		EXECUTE IMMEDIATE 'CREATE INDEX RENDIMPC.IX_SALS ON RENDIMPC.SQUADRATURE_CTV_SALS (IDPTF, CODICETITOLO, DATA) parallel 8 nologging INITRANS 8 TABLESPACE TBS_RENDIMPC_IDX_TEMP';
	END IF;

	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Indice squadrature_ctv_sals creato');
	COMMIT;

	dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'SQUADRATURE_CTV_SALS', degree => 4, estimate_percent=>10, cascade=>true);
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Statistiche SQUADRATURE_CTV_SALS eseguite');
	COMMIT;	
 
	SELECT COUNT(*) INTO check_ix_movs FROM user_indexes WHERE index_name = 'IX_MOVS' AND table_owner = 'RENDIMPC';
	IF check_ix_movs = 1 THEN
		EXECUTE IMMEDIATE 'DROP INDEX IX_MOVS';
	END IF;   
		    
	INSERT /*+ APPEND NOLOGGING PARALLEL(8)*/ INTO squadrature_ctv_movs ( 	sommamov,
										sommamovpos,
										sommamovneg,
										maxdata, 
										mindata,
										codicetitolo, 
										idrapporto )
		SELECT /*+ INDEX(R RAPPORTO_PK) PARALLEL(8) */ SUM(M.ctv),
			   SUM(CASE WHEN M.ctv >= 0 THEN M.ctv END),
			   SUM(CASE WHEN M.ctv < 0 THEN M.ctv END),
			   MAX(M.DATA),
			   MIN(M.DATA), 
			   M.codicetitolo, 
			   M.idrapporto
	    FROM movimento M
	    INNER JOIN causale C 
	      ON M.causale = C.codicecausale
	    INNER JOIN rapporto R
	    	ON R.ID = M.idrapporto
	    LEFT JOIN squadrature_ctv_sals S
	    	ON S.idptf = R.idptf
	    	AND S.codicetitolo = M.codicetitolo   
	    WHERE C.flagaggsaldi = 1
	    AND (M.DATA <= S.DATA OR S.DATA is null)
	    GROUP BY M.codicetitolo, M.idrapporto;

    
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Tabella squadrature_ctv_movs riempita');
	COMMIT;	
    
	SELECT COUNT(*) INTO check_ix_movs FROM user_indexes WHERE index_name = 'IX_MOVS' AND table_owner = 'RENDIMPC';
	IF check_ix_movs = 0 THEN
		EXECUTE IMMEDIATE 'CREATE INDEX RENDIMPC.IX_MOVS ON RENDIMPC.SQUADRATURE_CTV_MOVS (IDRAPPORTO, CODICETITOLO) parallel 8 nologging INITRANS 8 TABLESPACE TBS_RENDIMPC_IDX_TEMP';
	END IF;   

	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Indice squadrature_ctv_movs creato');
	COMMIT;	
	
	dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'SQUADRATURE_CTV_MOVS',degree => 4, estimate_percent=>10, cascade=>true);
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Statistiche eseguite');
	COMMIT;	
 
END;       
