DECLARE

--Eliminare dalla tmp i record con rami diversi da 03
CURSOR DEL_MOV_PAGAMENTO_RAMO IS
	SELECT /*+ parallel(8) */ SP.ROWID, SP.* 
	FROM TMP_PFMOV_PAG_FONDO SP
	WHERE SP.RAMO not in ('03');

--Eliminare dalla tmp i record con codice_prodotto in PRODOTTI_DA_ESCLUDERE
CURSOR DEL_MOV_PAGAMENTO_COD IS
	SELECT /*+ parallel(8) */ SP.ROWID, SP.* 
	FROM TMP_PFMOV_PAG_FONDO SP
	WHERE codice_prodotto in (select codicetitolo
							  from PRODOTTI_DA_ESCLUDERE);
							  						  
--Eliminare dalla tmp i record con data antecedente al 20171231
CURSOR DEL_MOV_PAGAMENTO_ANTE IS
	SELECT /*+ parallel(8) */ SP.ROWID, SP.* 
	FROM TMP_PFMOV_PAG_FONDO SP
	WHERE TO_NUMBER(TO_CHAR(TO_DATE(DATA_COMUNICAZIONE_PAGAMENTO, 'YYYY-MM-DD'), 'YYYYMMDD')) < 20171231
	     AND DATA_COMUNICAZIONE_PAGAMENTO > 00000000;

--Eliminare dalla tmp i record con codice_prodotto non presente nella POLIZZE_SOTTOSTANTI
CURSOR DEL_MOV_PAGAMENTO_PROD IS
	SELECT /*+ parallel(8) */ SP.ROWID, SP.* 
	FROM TMP_PFMOV_PAG_FONDO SP
	WHERE CODICE_PRODOTTO not in (
					select CODICETITOLO
					from POLIZZE_SOTTOSTANTI);
							  
I 	NUMBER(38,0) :=0;


BEGIN
		
FOR CUR_ITEM IN DEL_MOV_PAGAMENTO_RAMO
	
	LOOP 
	
	  I := I+1;
	
      DELETE /*+ nologging */ FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	IF MOD(I,10000) = 0 THEN
		INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO CODICE RAMO ERRATO - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
			
	END LOOP;
	
INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO CODICE RAMO ERRATO. RECORD ELIMINATI: '|| I);
	
COMMIT;

I := 0;

FOR CUR_ITEM IN DEL_MOV_PAGAMENTO_COD
	
	LOOP 
	
	  I := I+1;
	
      DELETE /*+ nologging */ FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	IF MOD(I,10000) = 0 THEN
		INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO CODICE IN PRODOTTI_DA_ESCLUDERE - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
			
	END LOOP;
	
INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO CODICE IN PRODOTTI_DA_ESCLUDERE. RECORD ELIMINATI: '|| I);
	
COMMIT;

I := 0;

FOR CUR_ITEM IN DEL_MOV_PAGAMENTO_ANTE
	
	LOOP 
	
	  I := I+1;
	
      DELETE /*+ nologging */ FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	IF MOD(I,10000) = 0 THEN
		INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO DATA ANTECEDENTE AL 20171231 - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
			
	END LOOP;
	
INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO DATA ANTECEDENTE AL 20171231. RECORD ELIMINATI: '|| I);
	
COMMIT;

I := 0;

FOR CUR_ITEM IN DEL_MOV_PAGAMENTO_PROD
	
	LOOP 
	
	  I := I+1;
	
      DELETE /*+ nologging */ FROM TMP_PFMOV_PAG_FONDO DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	IF MOD(I,10000) = 0 THEN
		INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO CODICE_PRODOTTO NON PRESENTE IN POLIZZE_SOTTOSTANTI - COMMIT ON ROW: '|| I);
		COMMIT; 
	END IF;
			
	END LOOP;
	
INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_PAG_FONDO CODICE_PRODOTTO NON PRESENTE IN POLIZZE_SOTTOSTANTI. RECORD ELIMINATI: '|| I);
	
COMMIT;
		
END;