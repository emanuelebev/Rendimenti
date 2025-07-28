SELECT sum(column_value)
FROM   TABLE(PARALLEL_SQUAD_QTA(CURSOR(

-- Squadrature per posizioni in cui ci sono i movimenti ma non ci sono i saldi

SELECT /*+ PARALLEL(8) */ DISTINCT sf.livello_2 				AS tipostrum,
				R.ndg 						AS codicecliente,
		        R.codicerapporto 			AS codicerapporto,
				R.tipo 						AS tipo, 
				R.sottorapporto 			AS sottorapporto,
				R.stato 					AS stato,
				R.ID 						AS idrapporto,
				R.idptf 					AS idptf,
				sf.codicetitolo 			AS codicetitolo,
				sf.descrizione 				AS descrizionetitolo,
				NULL 						AS datasaldo,
				0 							AS valoresaldo,
				squadrati.sumqta			AS sumqta, 
				(0 - squadrati.sumqta)		AS diff,
				R.codiceagenzia 			AS codiceagenzia,
                '07601'                     AS codicebanca,
                sysdate 					AS datains,
                sysdate 					AS dataagg,
                0							AS counter
FROM (
    SELECT SUM(M.qta) AS sumqta, M.codicetitolo, R.ID AS idrapporto, R.idptf
    FROM movimento M
	INNER JOIN rapporto R
	    ON R.ID = M.idrapporto
	LEFT JOIN saldo_rend_sott_pol S
	    ON S.idptf = R.idptf 
	   	AND M.codicetitolo = (select codicetitolo from TBL_BRIDGE where cod_universo = s.sottostante_pz and cod_universo != '70')
	INNER JOIN causale C
	    ON C.codicecausale = M.causale
	    INNER JOIN strumentofinanziario sf
	    ON sf.codicetitolo = M.codicetitolo
    WHERE S.idptf IS NULL
    AND C.flagaggsaldi = 1
    AND sf.tipo_rend = 'QTA' 
    AND sf.perimetro_rend = '1'
    AND M.DATA <= (SELECT MAX(DATA) FROM max_saldo_rend_sott_pol)
    AND (M.DATA > 20171231 OR (M.DATA = 20171231 AND M.causale = '13_MOVIMP')) 
    AND R.tipo = '13'
    AND C.codicecausale != '13_MF'
    GROUP BY M.codicetitolo, R.ID, R.idptf
) squadrati
	INNER JOIN strumentofinanziario sf
		ON sf.codicetitolo = squadrati.codicetitolo
	INNER JOIN rapporto R
		ON R.ID = squadrati.idrapporto
	WHERE sumqta != 0  --non esistono i saldi a 0
	AND r.tipo = '13'
ORDER BY R.ID, sf.codicetitolo
)));
