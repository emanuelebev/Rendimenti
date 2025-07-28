DECLARE
	
CURSOR SCARTI_SALDI IS
	SELECT  R.CODICERAPPORTO AS R_CODICERAPPORTO,
			Rbfpd.id_buono_originario AS Rbfpd_id_buono_originario,
			SF.CODICETITOLO AS SF_CODICETITOLO, 
			TMP.ROWID, 
			TMP.* 
	FROM TMP_PFSALDISTORICI TMP
		LEFT JOIN RAPPORTO R
			   ON TMP.CODICERAPPORTO = R.CODICERAPPORTO
				   AND TMP.CODICEBANCA = R.CODICEBANCA
				   AND TMP.TIPORAPPORTO = R.TIPO 
		LEFT JOIN RAPPORTO Rbfpd
			   ON TMP.id_buono_originario= Rbfpd.id_buono_originario
				   AND TMP.CODICEBANCA = Rbfpd.CODICEBANCA
				   AND TMP.TIPORAPPORTO = Rbfpd.TIPO 
		LEFT JOIN STRUMENTOFINANZIARIO SF
			ON SF.CODICETITOLO = TMP.CODICEINTERNO
	  WHERE ((R.CODICERAPPORTO IS NULL AND Rbfpd.id_buono_originario IS NULL) OR SF.CODICETITOLO IS NULL);
	
I 							NUMBER(38,0) :=0;
SCARTI_CODICETITOLO 		NUMBER:=0;
SCARTI_CODICERAPPORTO 		NUMBER:=0;
	
	
BEGIN
	
FOR CUR_ITEM IN SCARTI_SALDI
		LOOP 
					
		I := I+1;
		
			IF (CUR_ITEM.SF_CODICETITOLO IS NULL) THEN
				
									INSERT INTO TBL_SCARTI_TMP_PFSALDISTORICI ( CODICEBANCA,       
																				CODICEAGENZIA,    
																				CODICERAPPORTO,    
																				CODICEINTERNO,     
																				DATASALDO,         
																				TIPORAPPORTO,     
																				CONTROVALORE,      
																				DIVISA,            
																				FLAGCONSOLIDATO,  
																				CTVVERSATO,        
																				CTVPRELEVATO,     
																				CTVVERSATONETTO,    
																				DATAAGGIORNAMENTO,
																				CODICEFASCIARENDIMENTO,
																				DECRIZIONEFASCIARENDIMENTO,
																				SERIEBUONO,
																				VALORESCADENZALORDO,
																				FLAGNETTISTALORDISTA,
																				IMPORTONETTO,
																				VALORESCADENZANETTO,
																				VALORENOMINALE,
																				DATASOTTOSCRIZIONE,
																				DATASCADENZA,
																				TMSTP,             
																				MOTIVO_SCARTO,     
																				RIPROPONIBILE )
																	VALUES (	CUR_ITEM.CODICEBANCA,       
																				CUR_ITEM.CODICEAGENZIA,    
																				CUR_ITEM.CODICERAPPORTO,    
																				CUR_ITEM.CODICEINTERNO,     
																				CUR_ITEM.DATASALDO,         
																				CUR_ITEM.TIPORAPPORTO,     
																				CUR_ITEM.CONTROVALORE,      
																				CUR_ITEM.DIVISA,            
																				CUR_ITEM.FLAGCONSOLIDATO,  
																				CUR_ITEM.CTVVERSATO,        
																				CUR_ITEM.CTVPRELEVATO,     
																				CUR_ITEM.CTVVERSATONETTO,    
																				CUR_ITEM.DATAAGGIORNAMENTO,
																				CUR_ITEM.CODICEFASCIARENDIMENTO,
																				CUR_ITEM.DECRIZIONEFASCIARENDIMENTO,
																				CUR_ITEM.SERIEBUONO,
																				CUR_ITEM.VALORESCADENZALORDO,
																				CUR_ITEM.FLAGNETTISTALORDISTA,
																				CUR_ITEM.IMPORTONETTO,
																				CUR_ITEM.VALORESCADENZANETTO,
																				CUR_ITEM.VALORENOMINALE,
																				CUR_ITEM.DATASOTTOSCRIZIONE,
																				CUR_ITEM.DATASCADENZA,
																				SYSDATE,       
																				'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',     
																				'S'  );
																				
										DELETE /*+ nologging */  FROM TMP_PFSALDISTORICI TMP_DEL
										WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
										
										SCARTI_CODICETITOLO := SCARTI_CODICETITOLO +1;
				
				ELSIF (CUR_ITEM.R_CODICERAPPORTO IS NULL AND CUR_ITEM.Rbfpd_id_buono_originario IS NULL) THEN
				
									INSERT INTO TBL_SCARTI_TMP_PFSALDISTORICI ( CODICEBANCA,       
																				CODICEAGENZIA,    
																				CODICERAPPORTO,    
																				CODICEINTERNO,     
																				DATASALDO,         
																				TIPORAPPORTO,     
																				CONTROVALORE,      
																				DIVISA,            
																				FLAGCONSOLIDATO,  
																				CTVVERSATO,        
																				CTVPRELEVATO,     
																				CTVVERSATONETTO,    
																				DATAAGGIORNAMENTO,
																				CODICEFASCIARENDIMENTO,
																				DECRIZIONEFASCIARENDIMENTO,
																				SERIEBUONO,
																				VALORESCADENZALORDO,
																				FLAGNETTISTALORDISTA,
																				IMPORTONETTO,
																				VALORESCADENZANETTO,
																				VALORENOMINALE,
																				DATASOTTOSCRIZIONE,
																				DATASCADENZA,
																				TMSTP,             
																				MOTIVO_SCARTO,     
																				RIPROPONIBILE 
																				)
																	VALUES (	CUR_ITEM.CODICEBANCA,       
																				CUR_ITEM.CODICEAGENZIA,    
																				CUR_ITEM.CODICERAPPORTO,    
																				CUR_ITEM.CODICEINTERNO,     
																				CUR_ITEM.DATASALDO,         
																				CUR_ITEM.TIPORAPPORTO,     
																				CUR_ITEM.CONTROVALORE,      
																				CUR_ITEM.DIVISA,            
																				CUR_ITEM.FLAGCONSOLIDATO,  
																				CUR_ITEM.CTVVERSATO,        
																				CUR_ITEM.CTVPRELEVATO,     
																				CUR_ITEM.CTVVERSATONETTO,    
																				CUR_ITEM.DATAAGGIORNAMENTO,
																				CUR_ITEM.CODICEFASCIARENDIMENTO,
																				CUR_ITEM.DECRIZIONEFASCIARENDIMENTO,
																				CUR_ITEM.SERIEBUONO,
																				CUR_ITEM.VALORESCADENZALORDO,
																				CUR_ITEM.FLAGNETTISTALORDISTA,
																				CUR_ITEM.IMPORTONETTO,
																				CUR_ITEM.VALORESCADENZANETTO,
																				CUR_ITEM.VALORENOMINALE,
																				CUR_ITEM.DATASOTTOSCRIZIONE,
																				CUR_ITEM.DATASCADENZA,
																				SYSDATE,       
																				'CHIAVE ESTERNA "CODICERAPPORTO" E "id_buono_originario" NON CENSITA',     
																				'S'
																			);
													
										DELETE /*+ nologging */  FROM TMP_PFSALDISTORICI TMP_DEL
										WHERE TMP_DEL.ROWID = CUR_ITEM.ROWID;
										
										SCARTI_CODICERAPPORTO := SCARTI_CODICERAPPORTO +1;
			
					END IF;
			
			IF MOD(I,10000) = 0 THEN
				INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDISTORICI PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: '|| I);
				COMMIT; 
		END IF;
					
END LOOP;

 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDISTORICI PER CHIAVE ESTERNA NON CENSITA. RECORD ELABORATI: '|| I);
 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDISTORICI PER CODICETITOLO NON CENSITO. RECORD SCARTATI: '|| SCARTI_CODICETITOLO);
 INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDISTORICI PER CODICERAPPORTO NON CENSITO. RECORD SCARTATI: '|| SCARTI_CODICERAPPORTO);
	
 COMMIT;
END;