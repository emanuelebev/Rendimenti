SELECT sum(column_value)
FROM   TABLE(PARALLEL_SQUAD_QTA2018(CURSOR(

-- Squadrature per posizioni in cui NON ci sono i movimenti ma ci sono i saldi
SELECT /*+ PARALLEL(8) */ DISTINCT sf.livello_2 		AS tipostrum,
				R.ndg 				AS codicecliente,
		        R.codicerapporto 	AS codicerapporto,
				R.tipo 				AS tipo, 
				R.sottorapporto 	AS sottorapporto,
				R.stato 			AS stato,
				R.ID 				AS idrapporto,
				R.idptf 			AS idptf,
				S.codicetitolo 		AS codicetitolo,
				sf.descrizione 		AS descrizionetitolo,
				S.DATA				AS datasaldo,
				S.valore 			AS valoresaldo,
				0 					AS sumqta, 
				(S.valore - 0) 		AS diff,
				R.codiceagenzia 	AS codiceagenzia,
                 '07601'            AS codicebanca,
                sysdate 			AS datains,
                sysdate 			AS dataagg,
                0					AS counter
FROM saldo_2018 S
	INNER JOIN rapporto R
	ON R.idptf = S.idptf
	LEFT JOIN movimento M
	ON M.idrapporto = R.ID  AND M.codicetitolo = S.codicetitolo
	INNER JOIN strumentofinanziario sf
	ON sf.codicetitolo = S.codicetitolo
WHERE M.idrapporto IS NULL
AND sf.tipo_rend = 'QTA' 
AND sf.perimetro_rend = '1'
AND R.tipo = '02'
AND S.valore > 0
ORDER BY R.ID, S.codicetitolo
)));