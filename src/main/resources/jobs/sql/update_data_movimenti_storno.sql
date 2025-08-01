DECLARE

CURSOR UPDATE_DATA_STORNI IS
SELECT   M.ROWID AS ROWID_MOV_STORNO, M1.DATA AS DATA_MOV_ORIGINALE
FROM MOVIMENTO M
INNER JOIN (
            SELECT TMP.CODICE, R.ID AS IDRAPPORTO
            FROM TMP_PFMOVIMENTI TMP
			INNER JOIN RAPPORTO R
				ON TMP.CODICERAPPORTO = R.CODICERAPPORTO
			    AND TMP.TIPORAPPORTO = R.TIPO
			    AND TMP.CODICEBANCA = R.CODICEBANCA
			WHERE TMP.FLAGSTORNO = '1'
			AND R.TIPO = '15'
            ) MOV_STORNO
	ON M.NUMREG = MOV_STORNO.CODICE
	AND M.IDRAPPORTO = MOV_STORNO.IDRAPPORTO
INNER JOIN MOVIMENTO M1
	ON M1.NUMREG = M.N_OPERAZIONE_STORNO
	AND M1.IDRAPPORTO = M.IDRAPPORTO
	AND M1.CODICETITOLO = M.CODICETITOLO
INNER JOIN RAPPORTO RAPP
	ON M1.IDRAPPORTO = RAPP.ID
WHERE M.DATA != M1.DATA
AND RAPP.TIPO = '15';




I 				NUMBER(38,0):=0;


BEGIN
	
	 
	
	
	
	FOR CUR_ITEM IN UPDATE_DATA_STORNI 

		LOOP
			
		I := I+1;
		
		UPDATE   MOVIMENTO
		SET DATA = CUR_ITEM.DATA_MOV_ORIGINALE
		WHERE ROWID = CUR_ITEM.ROWID_MOV_STORNO;

								
		IF MOD(I,10000) = 0 THEN
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' UPDATE DATA MOVIMENTI STORNO. COMMIT ON ROW: ' || I);
			COMMIT;
		END IF;

		END LOOP;
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' UPDATE DATA MOVIMENTI STORNO. RECORD ELABORATI: ' || I);
		COMMIT;

END;