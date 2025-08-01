BEGIN
   
	
	
END;

DECLARE
CURSOR SCARTI_MOVIMENTI_BFP IS
SELECT   TMP.ROWID, TMP.* 
FROM TMP_PFMOVIMENTI TMP
INNER JOIN (SELECT CODICE, CODICEINTERNO, CODICERAPPORTO
	  FROM TMP_PFMOVIMENTI TMP
	  GROUP BY CODICE, CODICEINTERNO, CODICERAPPORTO
	  HAVING COUNT(*) >1) A
ON TMP.CODICE = A.CODICE
AND TMP.CODICEINTERNO=A.CODICEINTERNO
AND TMP.CODICERAPPORTO = A.CODICERAPPORTO;


	TYPE SCARTI_MOVIMENTI_BFP_TYPE IS TABLE OF SCARTI_MOVIMENTI_BFP%ROWTYPE INDEX BY PLS_INTEGER;
	
	RES_SCARTI_MOVIMENTI_BFP SCARTI_MOVIMENTI_BFP_TYPE;
	
	ROWS      PLS_INTEGER := 10000;
	        
	I 			NUMBER(38,0);
	TOTALE			NUMBER(38,0):=0;
	
	BEGIN
	
		
	OPEN SCARTI_MOVIMENTI_BFP;
	LOOP
			FETCH SCARTI_MOVIMENTI_BFP BULK COLLECT INTO RES_SCARTI_MOVIMENTI_BFP LIMIT ROWS;
				EXIT WHEN RES_SCARTI_MOVIMENTI_BFP.COUNT = 0;  
				
	      I:=0;
	      I:= RES_SCARTI_MOVIMENTI_BFP.COUNT;
	      TOTALE := TOTALE + I;
				
				FORALL J IN RES_SCARTI_MOVIMENTI_BFP.FIRST .. RES_SCARTI_MOVIMENTI_BFP.LAST		
	
				INSERT   INTO TBL_SCARTI_TMP_PFMOVIMENTI (	CODICEBANCA,       
															CODICE,            
															CODICEAGENZIA,    
															CODICERAPPORTO,    
															TIPORAPPORTO,      
															CODICEINTERNO,     
															CAUSALE,           
															CTVREGOLATO,       
															CTVMERCATO,        
															CTVREGOLATODIVISA, 
															CTVMERCATODIVISA,  
															DIVISA,            
															QUANTITA,          
															PREZZOMERCATO,    
															PREZZO,            
															RATEOLORDO,       
															RATEONETTO,        
															CAMBIO,            
															DATAORDINE,        
															DATACONTABILE,     
															DATAVALUTA,     
															FLAGSTORNO,        
															CODICESTORNO,      
															FLAGCANCELLATO,    
															IMPOSTE,           
															COMMISSIONI,       
															DATAAGGIORNAMENTO, 
															TMSTP,             
															MOTIVO_SCARTO,     
															RIPROPONIBILE
														)
												VALUES (RES_SCARTI_MOVIMENTI_BFP(J).CODICEBANCA,       
														RES_SCARTI_MOVIMENTI_BFP(J).CODICE,            
														RES_SCARTI_MOVIMENTI_BFP(J).CODICEAGENZIA,    
														RES_SCARTI_MOVIMENTI_BFP(J).CODICERAPPORTO,    
														RES_SCARTI_MOVIMENTI_BFP(J).TIPORAPPORTO,      
														RES_SCARTI_MOVIMENTI_BFP(J).CODICEINTERNO,     
														RES_SCARTI_MOVIMENTI_BFP(J).CAUSALE,           
														RES_SCARTI_MOVIMENTI_BFP(J).CTVREGOLATO,       
														RES_SCARTI_MOVIMENTI_BFP(J).CTVMERCATO,        
														RES_SCARTI_MOVIMENTI_BFP(J).CTVREGOLATODIVISA, 
														RES_SCARTI_MOVIMENTI_BFP(J).CTVMERCATODIVISA,  
														RES_SCARTI_MOVIMENTI_BFP(J).DIVISA,            
														RES_SCARTI_MOVIMENTI_BFP(J).QUANTITA,          
														RES_SCARTI_MOVIMENTI_BFP(J).PREZZOMERCATO,    
														RES_SCARTI_MOVIMENTI_BFP(J).PREZZO,            
														RES_SCARTI_MOVIMENTI_BFP(J).RATEOLORDO,       
														RES_SCARTI_MOVIMENTI_BFP(J).RATEONETTO,        
														RES_SCARTI_MOVIMENTI_BFP(J).CAMBIO,            
														RES_SCARTI_MOVIMENTI_BFP(J).DATAORDINE,        
														RES_SCARTI_MOVIMENTI_BFP(J).DATACONTABILE,     
														RES_SCARTI_MOVIMENTI_BFP(J).DATAVALUTA,     
														RES_SCARTI_MOVIMENTI_BFP(J).FLAGSTORNO,        
														RES_SCARTI_MOVIMENTI_BFP(J).CODICESTORNO,      
														RES_SCARTI_MOVIMENTI_BFP(J).FLAGCANCELLATO,    
														RES_SCARTI_MOVIMENTI_BFP(J).IMPOSTE,           
														RES_SCARTI_MOVIMENTI_BFP(J).COMMISSIONI,       
														RES_SCARTI_MOVIMENTI_BFP(J).DATAAGGIORNAMENTO,
														SYSDATE,
														'CHIAVE PRIMARIA "CODICE, CODICEINTERNO, CODICERAPPORTO" DUPLICATA',
														'N'
														);
				
			        COMMIT;		
			        
			        FORALL J IN RES_SCARTI_MOVIMENTI_BFP.FIRST .. RES_SCARTI_MOVIMENTI_BFP.LAST
			        	
			        DELETE   FROM TMP_PFMOVIMENTI TMP_DEL
					WHERE TMP_DEL.ROWID = RES_SCARTI_MOVIMENTI_BFP(J).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI  TMP_PFMOVIMENTI PER CHIAVE (CODICE, CODICEINTERNO, CODICERAPPORTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE SCARTI_MOVIMENTI_BFP;
	
	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI  TMP_PFMOVIMENTI PER CHIAVE (CODICE, CODICEINTERNO, CODICERAPPORTO) DUPLICATA: ' || TOTALE);
	COMMIT;
END;