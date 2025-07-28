SELECT sum(column_value)
FROM   TABLE(PARALLEL_SQUAD_QTA2018(CURSOR(

-- Squadrature per posizioni in cui ci sono i movimenti ma non ci sono i saldi
SELECT /*+ PARALLEL(8) */ DISTINCT sf.livello_2 				AS tipostrum,
				R.ndg 						AS codicecliente,
		        R.codicerapporto 			AS codicerapporto,
				R.tipo 						AS tipo, 
				R.sottorapporto 			AS sottorapporto,
				R.stato 					AS stato,
				R.ID 						AS idrapporto,
				R.idptf 					AS idptf,
				sf.codicetitolo				AS codicetitolo,
				sf.descrizione 				AS descrizionetitolo,
				NULL 						AS datasaldo,
				0 							AS valoresaldo,
				squadrati.sumqta			AS sumqta, 
				(0 - squadrati.sumqta)		AS diff,
				R.codiceagenzia 			AS codiceagenzia, 
                 '07601' 					AS codicebanca,
				sysdate 					AS datains,
				sysdate 					AS dataagg,
				0							AS counter
FROM (
      SELECT SUM(M.qta) AS sumqta, M.codicetitolo, R.ID AS idrapporto, R.idptf
    FROM movimento M
	    INNER JOIN rapporto R
	    ON R.ID = M.idrapporto
	    LEFT JOIN saldo_2018 S
	    ON S.idptf = R.idptf  AND M.codicetitolo = S.codicetitolo
	    INNER JOIN causale C
	    ON C.codicecausale = M.causale
	    INNER JOIN strumentofinanziario sf
	    ON sf.codicetitolo = M.codicetitolo
    WHERE S.idptf IS NULL
    AND C.flagaggsaldi = 1
    AND ((M.DATA > 20171231 AND M.DATA <= 20181231) OR (M.DATA = 20171231 AND M.causale IN ('02_MOVIMP', '03_MOVIMP', '13_MOVIMP', '14_MOVIMP', '15_MOVIMP')))
    AND sf.tipo_rend = 'QTA' 
    AND sf.perimetro_rend = '1'
    AND M.DATA <= (SELECT MAX(DATA) FROM saldo_2018) 
    AND R.tipo != '02'
    GROUP BY M.codicetitolo, R.ID, R.idptf
) squadrati
	INNER JOIN strumentofinanziario sf
	ON sf.codicetitolo = squadrati.codicetitolo
	INNER JOIN rapporto R
	ON R.ID = squadrati.idrapporto
	WHERE sumqta != 0  --non esistono i saldi a 0
	AND R.tipo != '02'
ORDER BY R.ID, sf.codicetitolo	
)));