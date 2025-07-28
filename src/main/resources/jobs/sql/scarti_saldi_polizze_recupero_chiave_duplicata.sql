DECLARE

-- Scarti polizze monoramo
CURSOR scarti_saldi_pol_mono IS
SELECT  /*+ parallel(8) */ tmp1.ROWID, tmp1.* 
	FROM TMP_PFSALPOL_RECUP tmp1	
		INNER JOIN (
			SELECT tmp.codicerapporto, tmp.codiceinterno, tmp.dataaggiornamento, tmp.ramo, tmp.fondo
				  FROM TMP_PFSALPOL_RECUP tmp
				  LEFT JOIN tbl_bridge b
			ON b.cod_universo = tmp.codiceinterno
				AND (b.cod_linea = tmp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND tmp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = tmp.codiceinterno
		WHERE b.codicetitolo IS NULL
		AND tmp.flagesclusione = '0'
		AND (sf.codicetitolo IS NULL OR sf.livello_2 = 'POLIZZE RAMO I')
				  GROUP BY tmp.codicerapporto, tmp.codiceinterno, tmp.dataaggiornamento, tmp.ramo, tmp.fondo
				  HAVING COUNT(*) >1) A
	ON tmp1.codicerapporto = A.codicerapporto
		AND tmp1.codiceinterno = A.codiceinterno
		AND tmp1.dataaggiornamento = A.dataaggiornamento
		AND tmp1.ramo = A.ramo
		AND tmp1.fondo = A.fondo;


-- Scarti polizze multiramo		
CURSOR scarti_saldi_pol_multi IS
SELECT /*+ parallel(8) */  tmp1.ROWID, tmp1.* 
	FROM TMP_PFSALPOL_RECUP tmp1	
		INNER JOIN (
			SELECT tmp.codicerapporto, tmp.codiceinterno, tmp.ramo, tmp.fondo, tmp.dataaggiornamento 
		  	FROM TMP_PFSALPOL_RECUP tmp
				LEFT JOIN tbl_bridge b
					ON b.cod_universo = tmp.codiceinterno
						AND (b.cod_linea = tmp.codiceinternomacroprodotto OR 
							(b.cod_linea IS NULL AND tmp.codiceinternomacroprodotto IS NULL))
				LEFT JOIN strumentofinanziario sf
					ON sf.codicetitolo = tmp.codiceinterno
			WHERE tmp.flagesclusione = '0'
			AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
			GROUP BY tmp.codicerapporto, tmp.codiceinterno, tmp.ramo, tmp.fondo, tmp.dataaggiornamento
			HAVING COUNT(*) >1) A
	ON tmp1.codicerapporto = A.codicerapporto
		AND tmp1.codiceinterno = A.codiceinterno
		AND tmp1.dataaggiornamento = A.dataaggiornamento
		AND tmp1.ramo = A.ramo
		AND tmp1.fondo = A.fondo;

		
TYPE scarti_saldi_pol_mono_type IS TABLE OF scarti_saldi_pol_mono%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_saldi_pol_mono scarti_saldi_pol_mono_type;

TYPE scarti_saldi_pol_multi_type IS TABLE OF scarti_saldi_pol_multi%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_saldi_pol_multi scarti_saldi_pol_multi_type;
	
ROWS      PLS_INTEGER := 10000;
	        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;
	
BEGIN
		
	OPEN scarti_saldi_pol_mono;
	LOOP
			FETCH scarti_saldi_pol_mono BULK COLLECT INTO res_scarti_saldi_pol_mono LIMIT ROWS;
				EXIT WHEN res_scarti_saldi_pol_mono.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_saldi_pol_mono.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_saldi_pol_mono.FIRST .. res_scarti_saldi_pol_mono.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFSALPOL_RECUP (	codicebanca,
																codiceagenzia,
																codicerapporto,
																codiceinterno,
																ramo,
																fondo,
																datasaldo,
																tiporapporto,
																controvalore,
																divisa,
																flagconsolidato,
																ctvversato,
																ctvprelevato,
																ctvversatonetto,
																dataaggiornamento,
																codiceinternomacroprodotto,
																descrizionemacroprodotto,
																valorenominale,
																datacompleannopolizza,
																idtitolo,
																flagesclusione,
																tmstp,
																motivo_scarto,
																riproponibile   
														)
												VALUES (res_scarti_saldi_pol_mono(j).codicebanca,       
														res_scarti_saldi_pol_mono(j).codiceagenzia,     
														res_scarti_saldi_pol_mono(j).codicerapporto,    
														res_scarti_saldi_pol_mono(j).codiceinterno,
														res_scarti_saldi_pol_mono(j).ramo,
														res_scarti_saldi_pol_mono(j).fondo,
														res_scarti_saldi_pol_mono(j).datasaldo,
														res_scarti_saldi_pol_mono(j).tiporapporto,
														res_scarti_saldi_pol_mono(j).controvalore,
														res_scarti_saldi_pol_mono(j).divisa,
														res_scarti_saldi_pol_mono(j).flagconsolidato,
														res_scarti_saldi_pol_mono(j).ctvversato,
														res_scarti_saldi_pol_mono(j).ctvprelevato,
														res_scarti_saldi_pol_mono(j).ctvversatonetto,
														res_scarti_saldi_pol_mono(j).dataaggiornamento,
														res_scarti_saldi_pol_mono(j).codiceinternomacroprodotto,
														res_scarti_saldi_pol_mono(j).descrizionemacroprodotto,
														res_scarti_saldi_pol_mono(j).valorenominale,
														res_scarti_saldi_pol_mono(j).datacompleannopolizza,
														res_scarti_saldi_pol_mono(j).idtitolo,
														res_scarti_saldi_pol_mono(j).flagesclusione,
														sysdate,             
														'CHIAVE PRIMARIA MONORAMO "CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO" DUPLICATA',     
														'N'
														);
														
			COMMIT;
			
			FORALL j IN res_scarti_saldi_pol_mono.FIRST .. res_scarti_saldi_pol_mono.LAST
			
			DELETE FROM TMP_PFSALPOL_RECUP tmp_del
			WHERE tmp_del.ROWID = res_scarti_saldi_pol_mono(j).ROWID;
			
			COMMIT;		        
	            
	         INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MONO PER CHIAVE CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_saldi_pol_mono;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MONO PER CHIAVE CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO) DUPLICATA: ' || totale);
	COMMIT;
	
	
	OPEN scarti_saldi_pol_multi;
	LOOP
			FETCH scarti_saldi_pol_multi BULK COLLECT INTO res_scarti_saldi_pol_multi LIMIT ROWS;
				EXIT WHEN res_scarti_saldi_pol_multi.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_saldi_pol_multi.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_saldi_pol_multi.FIRST .. res_scarti_saldi_pol_multi.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFSALPOL_RECUP (	codicebanca,
																codiceagenzia,
																codicerapporto,
																codiceinterno,
																ramo,
																fondo,
																datasaldo,
																tiporapporto,
																controvalore,
																divisa,
																flagconsolidato,
																ctvversato,
																ctvprelevato,
																ctvversatonetto,
																dataaggiornamento,
																codiceinternomacroprodotto,
																descrizionemacroprodotto,
																valorenominale,
																datacompleannopolizza,
																idtitolo,
																flagesclusione,
																tmstp,
																motivo_scarto,
																riproponibile   
														)
												VALUES (res_scarti_saldi_pol_multi(j).codicebanca,       
														res_scarti_saldi_pol_multi(j).codiceagenzia,     
														res_scarti_saldi_pol_multi(j).codicerapporto,    
														res_scarti_saldi_pol_multi(j).codiceinterno,
														res_scarti_saldi_pol_multi(j).ramo,
														res_scarti_saldi_pol_multi(j).fondo,
														res_scarti_saldi_pol_multi(j).datasaldo,
														res_scarti_saldi_pol_multi(j).tiporapporto,
														res_scarti_saldi_pol_multi(j).controvalore,
														res_scarti_saldi_pol_multi(j).divisa,
														res_scarti_saldi_pol_multi(j).flagconsolidato,
														res_scarti_saldi_pol_multi(j).ctvversato,
														res_scarti_saldi_pol_multi(j).ctvprelevato,
														res_scarti_saldi_pol_multi(j).ctvversatonetto,
														res_scarti_saldi_pol_multi(j).dataaggiornamento,
														res_scarti_saldi_pol_multi(j).codiceinternomacroprodotto,
														res_scarti_saldi_pol_multi(j).descrizionemacroprodotto,
														res_scarti_saldi_pol_multi(j).valorenominale,
														res_scarti_saldi_pol_multi(j).datacompleannopolizza,
														res_scarti_saldi_pol_multi(j).idtitolo,
														res_scarti_saldi_pol_multi(j).flagesclusione,
														sysdate,             
														'CHIAVE PRIMARIA MULTIRAMO "CODICERAPPORTO, CODICEINTERNO, RAMO, FONDO, DATAAGGIORNAMENTO" DUPLICATA',     
														'N'
														);
														
			COMMIT;
			
			FORALL j IN res_scarti_saldi_pol_multi.FIRST .. res_scarti_saldi_pol_multi.LAST
			
			DELETE FROM TMP_PFSALPOL_RECUP tmp_del
			WHERE tmp_del.ROWID = res_scarti_saldi_pol_multi(j).ROWID;
			
			COMMIT;		        
	            
	         INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MULTI PER CHIAVE CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_saldi_pol_multi;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALPOL_RECUP MULTI PER CHIAVE CODICERAPPORTO, CODICEINTERNO, DATAAGGIORNAMENTO) DUPLICATA: ' || totale);
	COMMIT;
		
END;