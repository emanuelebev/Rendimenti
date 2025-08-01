SELECT sum(column_value)
FROM   TABLE(PARALLEL_SQUAD_CTV(CURSOR(

-- Squadrature per posizioni in cui NON ci sono i movimenti ma ci sono i saldi
SELECT /*+ INDEX(R RAP_PTF_IDX_2) PARALLEL(8) */ DISTINCT SF.LIVELLO_2 					AS TIPOSTRUM,
				R.NDG 							AS CODICECLIENTE,
				R.CODICERAPPORTO 				AS CODICERAPPORTO,
				R.TIPO 							AS TIPO, 
				R.SOTTORAPPORTO 				AS SOTTO_RAPPORTO,
				'07601' 						AS CODICEBANCA,
				R.CODICEAGENZIA 				AS CODICEAGENZIA,
				R.STATO 						AS STATO,
				R.ID 							AS IDRAPPORTO,
				R.IDPTF 						AS IDPTF,
				SF.CODICETITOLO 				AS CODICETITOLO,
				SF.DESCRIZIONE 					AS DESCRIZIONETITOLO,
				SALS.DATA						AS DATASALDO,
				NVL(SALS.CTV, 0) 				AS CTV,
				999 							AS VARIAZIONE,
				999								AS SOGLIA_PONDERATA,
				SS.SOGLIA 						AS SOGLIA,
				SYSDATE 						AS DATAINS,
				COALESCE(TO_DATE((SELECT MIN(DATA) 
					 	 FROM SALDO_REND 
						 WHERE IDPTF = SALS.IDPTF 
						 AND CODICETITOLO = SALS.CODICETITOLO
										), 'YYYYMMDD'), TO_DATE('99999999', 'YYYYMMDD')) 	AS DATAINIZIO,
				0 										AS SOMMAMOV,
				0 										AS SOMMAMOVPOS,
				0 										AS SOMMAMOVNEG,
				null									AS MINDATA,
				null									AS MAXDATA,
				SYSDATE 								AS DATAAGG,
				ABS(NVL(SALS.CTV, 0) - 0)               AS DIFF_EURO	
FROM SQUADRATURE_CTV_SALS SALS
INNER JOIN RAPPORTO R
ON R.IDPTF = SALS.IDPTF
LEFT JOIN MOVIMENTO M
ON M.IDRAPPORTO = R.ID AND M.CODICETITOLO = SALS.CODICETITOLO
        LEFT JOIN CAUSALE C 
          ON M.CAUSALE = C.CODICECAUSALE AND C.FLAGAGGSALDI = 1
INNER JOIN STRUMENTOFINANZIARIO SF 
	ON SALS.CODICETITOLO = SF.CODICETITOLO
INNER JOIN SOGLIESQUAD_CTV SS 
    ON SF.LIVELLO_2 = SS.TIPOLOGIA 
WHERE SF.PERIMETRO_REND = '1'
AND M.IDRAPPORTO IS NULL
ORDER BY R.ID, SF.CODICETITOLO, SALS.DATA
)));