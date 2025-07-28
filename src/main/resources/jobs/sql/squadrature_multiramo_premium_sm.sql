SELECT sum(column_value)
FROM   TABLE(PARALLEL_SQUAD_QTA(CURSOR(

-- Squadrature per posizioni in cui ci sono sia i saldi che i movimenti

SELECT /*+ PARALLEL(8) */ DISTINCT sf.livello_2 		        AS tipostrum,
				R.ndg 									        AS codicecliente,
		        R.codicerapporto 						        AS codicerapporto,
				R.tipo 									        AS tipo, 
				R.sottorapporto							        AS sottorapporto,
				R.stato 								        AS stato,
				R.ID 									        AS idrapporto,
				R.idptf 								        AS idptf,
				squadrati.codicetitolo 						    AS codicetitolo,
				sf.descrizione 							        AS descrizionetitolo,
				case when maxs.MAXDATA_FONDO > sq.DATA then maxs.MAXDATA_FONDO
                	else sq.DATA end       						AS datasaldo,
				case when maxs.MAXDATA_FONDO > sq.DATA then 0 
					else NVL(sq.numero_quote, 0) end			AS valoresaldo,
				squadrati.sumqta 						        AS sumqta, 
				case when maxs.MAXDATA_FONDO > sq.DATA then squadrati.sumqta 
					else (NVL(sq.numero_quote, 0) - squadrati.sumqta) end AS diff,
				R.codiceagenzia 						        AS codiceagenzia,
				 '07601'            					        AS codicebanca,
                sysdate 							    	    AS datains,
                sysdate 							        	AS dataagg,
                0										        AS counter
FROM (
        SELECT SUM(M.qta) AS sumqta, BRI.codicetitolo, R.ID AS idrapporto, R.idptf, S.DATA
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
        INNER JOIN movimento M           
		    ON M.idrapporto = R.ID
		   AND M.codicetitolo = BRI.codicetitolo
           AND M.DATA <= maxs.DATA
		    INNER JOIN causale C
		    ON C.codicecausale = M.causale
        INNER JOIN strumentofinanziario sf
		  ON sf.codicetitolo = M.codicetitolo
	    WHERE C.flagaggsaldi = 1
	    AND sf.tipo_rend = 'QTA' 
        AND sf.perimetro_rend = '1'
	    AND  R.tipo = '13'
	    AND C.codicecausale != '13_PM'
	    AND (M.DATA > 20171231 OR (M.DATA = 20171231 AND M.causale = '13_MOVIMP'))
	    AND S.numero_quote > 0 
        GROUP BY BRI.codicetitolo, R.ID, R.idptf, S.DATA 
) squadrati
    INNER JOIN saldo_rend_sott_pol sq 
		ON squadrati.idptf = sq.idptf
			AND squadrati.codicetitolo = (select codicetitolo from TBL_BRIDGE where cod_universo = sq.sottostante_pz and cod_universo != '70')
			AND squadrati.DATA = sq.DATA
    INNER JOIN strumentofinanziario sf
		ON sf.codicetitolo = squadrati.codicetitolo
	INNER JOIN rapporto R
		ON R.ID = squadrati.idrapporto  
	INNER JOIN max_saldo_rend_sott_pol maxs
        ON Sq.idptf = maxs.idptf
WHERE sq.numero_quote != sumqta
AND R.tipo = '13'
AND sq.numero_quote > 0
ORDER BY R.ID, squadrati.codicetitolo
)));
        
