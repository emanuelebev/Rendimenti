SELECT sum(column_value)
FROM   TABLE(PARALLEL_SQUAD_QTA(CURSOR(

-- Squadrature per posizioni in cui NON ci sono i movimenti ma ci sono i saldi

SELECT /*+ PARALLEL(8) */  DISTINCT sf.livello_2 		AS tipostrum,
					R.ndg 									AS codicecliente,
			        R.codicerapporto 						AS codicerapporto,
					R.tipo 									AS tipo, 
					R.sottorapporto 						AS sottorapporto,
					R.stato 								AS stato,
					R.ID 									AS idrapporto,
					R.idptf 								AS idptf,
					bri.codicetitolo 						AS codicetitolo,
					sf.descrizione 							AS descrizionetitolo,
					S.DATA 									AS datasaldo,
					S.numero_quote							AS valoresaldo,
					0 										AS sumqta, 
					(S.numero_quote - 0) 					AS diff,
					R.codiceagenzia 						AS codiceagenzia,
	                '07601'             					AS codicebanca,
	                sysdate 								AS datains,
	                sysdate 								AS dataagg,
	                0										AS counter
	FROM saldo_rend_sott_pol S
        INNER JOIN polizze_sottostanti ps
            ON ps.codicetitolo = s.codice_universo_pz
        INNER JOIN TBL_BRIDGE BRI
            ON (BRI.cod_universo = sottostante_pz)
        INNER JOIN max_saldo_rend_sott_pol maxs
        	ON S.idptf = maxs.idptf
       	 AND BRI.codicetitolo = maxs.codicetitolo
       	 AND S.DATA = maxs.DATA
	INNER JOIN rapporto R
		ON R.idptf = S.idptf
	LEFT JOIN movimento M
		ON M.idrapporto = R.ID  
			AND M.codice_prodotto_universo = S.codice_universo_pz
	INNER JOIN strumentofinanziario sf
		ON sf.codicetitolo = S.codicetitolo
	WHERE M.idrapporto IS NULL
	AND s.ramo = '03'
	AND sf.tipo_rend = 'QTA' 
	AND sf.perimetro_rend = '1'
	AND S.numero_quote > 0
	ORDER BY idrapporto, codicetitolo
)));
