SELECT sum(column_value)
FROM   TABLE(PARALLEL_SQUAD_QTA(CURSOR(

-- Squadrature per posizioni in cui ci sono sia i saldi che i movimenti
SELECT /*+ PARALLEL(8) */ DISTINCT sf.livello_2 							AS tipostrum,
				R.ndg 									AS codicecliente,
		        R.codicerapporto 						AS codicerapporto,
				R.tipo 									AS tipo, 
				R.sottorapporto							AS sottorapporto,
				R.stato 								AS stato,
				R.ID 									AS idrapporto,
				R.idptf 								AS idptf,
				sq.codicetitolo 						AS codicetitolo,
				sf.descrizione 							AS descrizionetitolo,
				sq.DATA   							    AS datasaldo,
				nvl(sq.valore, 0) 						AS valoresaldo,
				squadrati.sumqta 						AS sumqta, 
				(nvl(sq.valore, 0) - squadrati.sumqta) 	AS diff,
				R.codiceagenzia 						AS codiceagenzia, 
                '07601'                                 AS codicebanca,
                sysdate 								AS datains,
                sysdate 								AS dataagg,
                0										AS counter
FROM (
	    SELECT SUM(M.qta) AS sumqta, M.codicetitolo, R.ID AS idrapporto, R.idptf, S.DATA
	    FROM saldo S
		    INNER JOIN rapporto R
		    ON R.idptf = S.idptf
		    INNER JOIN movimento M
		    ON M.idrapporto = R.ID
		    AND M.codicetitolo = S.codicetitolo
		    AND M.DATA<= S.DATA
		    INNER JOIN causale C
		    ON C.codicecausale = M.causale
		    INNER JOIN strumentofinanziario sf
		    ON sf.codicetitolo = S.codicetitolo
	    WHERE C.flagaggsaldi = 1
	    AND (M.DATA> 20171231 OR (M.DATA= 20171231 AND M.causale IN ('02_MOVIMP', '03_MOVIMP', '13_MOVIMP', '14_MOVIMP', '15_MOVIMP')))
	    AND sf.tipo_rend = 'QTA' AND sf.perimetro_rend = '1'
	    AND r.tipo NOT IN ('02', '13')
	    GROUP BY M.codicetitolo, R.ID, R.idptf, S.DATA
) squadrati
		INNER JOIN saldo sq
		ON squadrati.idptf = sq.idptf
		AND squadrati.codicetitolo = sq.codicetitolo
		AND squadrati.DATA= sq.DATA
		INNER JOIN strumentofinanziario sf
		ON sf.codicetitolo = squadrati.codicetitolo
		INNER JOIN rapporto R
		ON R.ID = squadrati.idrapporto
WHERE sq.valore != sumqta
AND r.tipo NOT IN ('02', '13')
ORDER BY R.ID, sq.codicetitolo
)));