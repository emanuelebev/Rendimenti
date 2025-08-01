DECLARE

-- Scarti polizze monoramo
CURSOR SCARTI_SALDI_POL_MONO IS
SELECT /*+ parallel(8) */  TMP1.ROWID, TMP1.* 
	FROM TMP_PFSALDI_POLIZZE_SP TMP1	
		INNER JOIN (
			SELECT TMP.CODICERAPPORTO, TMP.CODICEINTERNO, TMP.DATAAGGIORNAMENTO, TMP.RAMO, TMP.FONDO
				  FROM TMP_PFSALDI_POLIZZE_SP TMP
				  LEFT JOIN TBL_BRIDGE B
			ON B.COD_UNIVERSO = TMP.CODICEINTERNO
				AND (B.COD_LINEA = TMP.CODICEINTERNOMACROPRODOTTO OR 
					(B.COD_LINEA IS NULL AND TMP.CODICEINTERNOMACROPRODOTTO IS NULL))
		LEFT JOIN STRUMENTOFINANZIARIO SF
			ON SF.CODICETITOLO = TMP.CODICEINTERNO
		WHERE B.CODICETITOLO IS NULL
		AND TMP.FLAGESCLUSIONE = '0'
		AND (SF.CODICETITOLO IS NULL OR SF.LIVELLO_2 = 'POLIZZE RAMO I')
				  GROUP BY TMP.CODICERAPPORTO, TMP.CODICEINTERNO, TMP.DATAAGGIORNAMENTO, TMP.RAMO, TMP.FONDO
				  HAVING COUNT(*) >1) A
	ON TMP1.CODICERAPPORTO = A.CODICERAPPORTO
		AND TMP1.CODICEINTERNO = A.CODICEINTERNO
		AND TMP1.DATAAGGIORNAMENTO = A.DATAAGGIORNAMENTO
		AND TMP1.RAMO = A.RAMO
		AND TMP1.FONDO = A.FONDO;


-- Scarti polizze multiramo		
CURSOR SCARTI_SALDI_POL_MULTI IS
SELECT /*+ parallel(8) */  TMP1.ROWID, TMP1.* 
	FROM TMP_PFSALDI_POLIZZE_SP TMP1	
		INNER JOIN (
			SELECT TMP.CODICERAPPORTO, TMP.CODICEINTERNO, TMP.RAMO, TMP.FONDO, TMP.DATAAGGIORNAMENTO 
		  	FROM TMP_PFSALDI_POLIZZE_SP TMP
				LEFT JOIN TBL_BRIDGE B
					ON B.COD_UNIVERSO = TMP.CODICEINTERNO
						AND (B.COD_LINEA = TMP.CODICEINTERNOMACROPRODOTTO OR 
							(B.COD_LINEA IS NULL AND TMP.CODICEINTERNOMACROPRODOTTO IS NULL))
				LEFT JOIN STRUMENTOFINANZIARIO SF
					ON SF.CODICETITOLO = TMP.CODICEINTERNO
			WHERE TMP.FLAGESCLUSIONE = '0'
			AND (B.CODICETITOLO IS NOT NULL OR SF.LIVELLO_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
			GROUP BY TMP.CODICERAPPORTO, TMP.CODICEINTERNO, TMP.RAMO, TMP.FONDO, TMP.DATAAGGIORNAMENTO
			HAVING COUNT(*) >1) A
	ON TMP1.CODICERAPPORTO = A.CODICERAPPORTO
		AND TMP1.CODICEINTERNO = A.CODICEINTERNO
		AND TMP1.DATAAGGIORNAMENTO = A.DATAAGGIORNAMENTO
		AND TMP1.RAMO = A.RAMO
		AND TMP1.FONDO = A.FONDO;

		
TYPE SCARTI_SALDI_POL_MONO_TYPE IS TABLE OF SCARTI_SALDI_POL_MONO%ROWTYPE INDEX BY PLS_INTEGER;
	
RES_SCARTI_SALDI_POL_MONO SCARTI_SALDI_POL_MONO_TYPE;

TYPE SCARTI_SALDI_POL_MULTI_TYPE IS TABLE OF SCARTI_SALDI_POL_MULTI%ROWTYPE INDEX BY PLS_INTEGER;
	
RES_SCARTI_SALDI_POL_MULTI SCARTI_SALDI_POL_MULTI_TYPE;
	
ROWS      PLS_INTEGER := 10000;
	        
I 			NUMBER(38,0);
TOTALE		NUMBER(38,0):=0;
	
BEGIN
		
	OPEN SCARTI_SALDI_POL_MONO;
	LOOP
			FETCH SCARTI_SALDI_POL_MONO BULK COLLECT INTO RES_SCARTI_SALDI_POL_MONO LIMIT ROWS;
				EXIT WHEN RES_SCARTI_SALDI_POL_MONO.COUNT = 0;  
				
	      I:=0;
	      I:= RES_SCARTI_SALDI_POL_MONO.COUNT;
	      TOTALE := TOTALE + I;
				
				FORALL J IN RES_SCARTI_SALDI_POL_MONO.FIRST .. RES_SCARTI_SALDI_POL_MONO.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFSALDI_POLI_SP (	CODICEBANCA,
																CODICEAGENZIA,
																CODICERAPPORTO,
																CODICEINTERNO,
																RAMO,
																FONDO,
																DATASALDO,
																TIPORAPPORTO,
																CONTROVALORE,
																DIVISA,
																FLAGCONSOLIDATO,
																CTVVERSATO,
																CTVPRELEVATO,
																CTVVERSATONETTO,
																DATAAGGIORNAMENTO,
																CODICEINTERNOMACROPRODOTTO,
																DESCRIZIONEMACROPRODOTTO,
																VALORENOMINALE,
																DATACOMPLEANNOPOLIZZA,
																IDTITOLO,
																FLAGESCLUSIONE,
																TMSTP,
																MOTIVO_SCARTO,
																RIPROPONIBILE   
														)
												VALUES (RES_SCARTI_SALDI_POL_MONO(J).CODICEBANCA,       
														RES_SCARTI_SALDI_POL_MONO(J).CODICEAGENZIA,     
														RES_SCARTI_SALDI_POL_MONO(J).CODICERAPPORTO,    
														RES_SCARTI_SALDI_POL_MONO(J).CODICEINTERNO,
														RES_SCARTI_SALDI_POL_MONO(J).RAMO,
														RES_SCARTI_SALDI_POL_MONO(J).FONDO,
														RES_SCARTI_SALDI_POL_MONO(J).DATASALDO,
														RES_SCARTI_SALDI_POL_MONO(J).TIPORAPPORTO,
														RES_SCARTI_SALDI_POL_MONO(J).CONTROVALORE,
														RES_SCARTI_SALDI_POL_MONO(J).DIVISA,
														RES_SCARTI_SALDI_POL_MONO(J).FLAGCONSOLIDATO,
														RES_SCARTI_SALDI_POL_MONO(J).CTVVERSATO,
														RES_SCARTI_SALDI_POL_MONO(J).CTVPRELEVATO,
														RES_SCARTI_SALDI_POL_MONO(J).CTVVERSATONETTO,
														RES_SCARTI_SALDI_POL_MONO(J).DATAAGGIORNAMENTO,
														RES_SCARTI_SALDI_POL_MONO(J).CODICEINTERNOMACROPRODOTTO,
														RES_SCARTI_SALDI_POL_MONO(J).DESCRIZIONEMACROPRODOTTO,
														RES_SCARTI_SALDI_POL_MONO(J).VALORENOMINALE,
														RES_SCARTI_SALDI_POL_MONO(J).DATACOMPLEANNOPOLIZZA,
														RES_SCARTI_SALDI_POL_MONO(J).IDTITOLO,
														RES_SCARTI_SALDI_POL_MONO(J).FLAGESCLUSIONE,
														SYSDATE,             
														'CHIAVE PRIMARIA MONORAMO "CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO" DUPLICATA',     
														'N'
														);
														
			COMMIT;
			
			FORALL J IN RES_SCARTI_SALDI_POL_MONO.FIRST .. RES_SCARTI_SALDI_POL_MONO.LAST
			
			DELETE FROM TMP_PFSALDI_POLIZZE_SP TMP_DEL
			WHERE TMP_DEL.ROWID = RES_SCARTI_SALDI_POL_MONO(J).ROWID;
			
			COMMIT;		        
	            
	         INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE_SP MONO PER CHIAVE CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE SCARTI_SALDI_POL_MONO;
	
	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE_SP MONO PER CHIAVE CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO) DUPLICATA: ' || TOTALE);
	COMMIT;
	
	
	OPEN SCARTI_SALDI_POL_MULTI;
	LOOP
			FETCH SCARTI_SALDI_POL_MULTI BULK COLLECT INTO RES_SCARTI_SALDI_POL_MULTI LIMIT ROWS;
				EXIT WHEN RES_SCARTI_SALDI_POL_MULTI.COUNT = 0;  
				
	      I:=0;
	      I:= RES_SCARTI_SALDI_POL_MULTI.COUNT;
	      TOTALE := TOTALE + I;
				
				FORALL J IN RES_SCARTI_SALDI_POL_MULTI.FIRST .. RES_SCARTI_SALDI_POL_MULTI.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFSALDI_POLI_SP (	CODICEBANCA,
																CODICEAGENZIA,
																CODICERAPPORTO,
																CODICEINTERNO,
																RAMO,
																FONDO,
																DATASALDO,
																TIPORAPPORTO,
																CONTROVALORE,
																DIVISA,
																FLAGCONSOLIDATO,
																CTVVERSATO,
																CTVPRELEVATO,
																CTVVERSATONETTO,
																DATAAGGIORNAMENTO,
																CODICEINTERNOMACROPRODOTTO,
																DESCRIZIONEMACROPRODOTTO,
																VALORENOMINALE,
																DATACOMPLEANNOPOLIZZA,
																IDTITOLO,
																FLAGESCLUSIONE,
																TMSTP,
																MOTIVO_SCARTO,
																RIPROPONIBILE   
														)
												VALUES (RES_SCARTI_SALDI_POL_MULTI(J).CODICEBANCA,       
														RES_SCARTI_SALDI_POL_MULTI(J).CODICEAGENZIA,     
														RES_SCARTI_SALDI_POL_MULTI(J).CODICERAPPORTO,    
														RES_SCARTI_SALDI_POL_MULTI(J).CODICEINTERNO,
														RES_SCARTI_SALDI_POL_MULTI(J).RAMO,
														RES_SCARTI_SALDI_POL_MULTI(J).FONDO,
														RES_SCARTI_SALDI_POL_MULTI(J).DATASALDO,
														RES_SCARTI_SALDI_POL_MULTI(J).TIPORAPPORTO,
														RES_SCARTI_SALDI_POL_MULTI(J).CONTROVALORE,
														RES_SCARTI_SALDI_POL_MULTI(J).DIVISA,
														RES_SCARTI_SALDI_POL_MULTI(J).FLAGCONSOLIDATO,
														RES_SCARTI_SALDI_POL_MULTI(J).CTVVERSATO,
														RES_SCARTI_SALDI_POL_MULTI(J).CTVPRELEVATO,
														RES_SCARTI_SALDI_POL_MULTI(J).CTVVERSATONETTO,
														RES_SCARTI_SALDI_POL_MULTI(J).DATAAGGIORNAMENTO,
														RES_SCARTI_SALDI_POL_MULTI(J).CODICEINTERNOMACROPRODOTTO,
														RES_SCARTI_SALDI_POL_MULTI(J).DESCRIZIONEMACROPRODOTTO,
														RES_SCARTI_SALDI_POL_MULTI(J).VALORENOMINALE,
														RES_SCARTI_SALDI_POL_MULTI(J).DATACOMPLEANNOPOLIZZA,
														RES_SCARTI_SALDI_POL_MULTI(J).IDTITOLO,
														RES_SCARTI_SALDI_POL_MULTI(J).FLAGESCLUSIONE,
														SYSDATE,             
														'CHIAVE PRIMARIA MULTIRAMO "CODICERAPPORTO, CODICEINTERNO, RAMO, FONDO, DATAAGGIORNAMENTO" DUPLICATA',     
														'N'
														);
														
			COMMIT;
			
			FORALL J IN RES_SCARTI_SALDI_POL_MULTI.FIRST .. RES_SCARTI_SALDI_POL_MULTI.LAST
			
			DELETE FROM TMP_PFSALDI_POLIZZE_SP TMP_DEL
			WHERE TMP_DEL.ROWID = RES_SCARTI_SALDI_POL_MULTI(J).ROWID;
			
			COMMIT;		        
	            
	         INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE_SP MULTI PER CHIAVE CODICERAPPORTO, CODICEINTERNO, RAMO, FONDO, DATAAGGIORNAMENTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE SCARTI_SALDI_POL_MULTI;
	
	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_POLIZZE_SP MULTI PER CHIAVE CODICERAPPORTO, CODICEINTERNO, RAMO, FONDO, DATAAGGIORNAMENTO) DUPLICATA: ' || TOTALE);
	COMMIT;
		
END;