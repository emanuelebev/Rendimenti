DECLARE

CURSOR squadrature_qta IS

-- Squadrature per posizioni in cui ci sono sia i saldi che i movimenti
SELECT DISTINCT sf.livello_2 							AS tipostrum,
				R.ndg 									AS codicecliente,
		        R.codicerapporto 						AS codicerapporto,
				R.tipo 									AS tipo, 
				R.sottorapporto							AS sottorapporto,
				R.stato 								AS stato,
				R.ID 									AS idrapporto,
				R.idptf 								AS idptf,
				sq.codicetitolo 						AS codicetitolo,
				sf.descrizione 							AS descrizionetitolo,
				sq.DATA 								AS DATA,
				nvl(sq.valore, 0) 						AS valoresaldo,
				squadrati.sumqta 						AS sommamov, 
				(nvl(sq.valore, 0) - squadrati.sumqta) 	AS differenza,
			R.codiceagenzia 							AS codiceagenzia
FROM (
	    SELECT SUM(M.qta) AS sumqta, M.codicetitolo, R.ID AS idrapporto, R.idptf, S.DATA 
	    FROM saldo_2018 S
		    INNER JOIN rapporto R
		    ON R.idptf = S.idptf
		    INNER JOIN movimento M
		    ON M.idrapporto = R.ID
		    AND M.codicetitolo = S.codicetitolo
		    AND M.DATA <= S.DATA
		    INNER JOIN causale C
		    ON C.codicecausale = M.causale
		    INNER JOIN strumentofinanziario sf
		    ON sf.codicetitolo = S.codicetitolo
	    WHERE C.flagaggsaldi = 1
	    AND ((M.DATA > 20171231 AND M.DATA <= 20181231) OR (M.DATA = 20171231 AND M.causale IN ('02_MOVIMP', '03_MOVIMP', '13_MOVIMP', '14_MOVIMP', '15_MOVIMP')))
	    AND sf.tipo_rend = 'QTA' AND sf.perimetro_rend = '1'
	    AND R.tipo != '02'
	    GROUP BY M.codicetitolo, R.ID, R.idptf, S.DATA
) squadrati
		INNER JOIN saldo_2018 sq
		ON squadrati.idptf = sq.idptf
		AND squadrati.codicetitolo = sq.codicetitolo
		AND squadrati.DATA = sq.DATA
		INNER JOIN strumentofinanziario sf
		ON sf.codicetitolo = squadrati.codicetitolo
		INNER JOIN rapporto R
		ON R.ID = squadrati.idrapporto
		INNER JOIN ndg N
		ON N.codice = R.ndg
WHERE sq.valore != sumqta
AND R.tipo != '02'

	UNION

-- Squadrature per posizioni in cui ci sono i movimenti ma non ci sono i saldi
SELECT DISTINCT sf.livello_2 				AS tipostrum,
				R.ndg 						AS codicecliente,
		        R.codicerapporto 			AS codicerapporto,
				R.tipo 						AS tipo, 
				R.sottorapporto 			AS sottorapporto,
				R.stato 					AS stato,
				R.ID 						AS idrapporto,
				R.idptf 					AS idptf,
				sf.codicetitolo				AS codicetitolo,
				sf.descrizione 				AS descrizionetitolo,
				NULL 						AS DATA,
				0 							AS valoresaldo,
				squadrati.sumqta			AS sommamov, 
				(0 - squadrati.sumqta)		AS differenza,
				R.codiceagenzia 			AS codiceagenzia
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
	INNER JOIN ndg N
	ON N.codice = R.ndg
	WHERE sumqta != 0  --non esistono i saldi a 0
	AND R.tipo != '02'

	UNION

-- Squadrature per posizioni in cui NON ci sono i movimenti ma ci sono i saldi
SELECT DISTINCT sf.livello_2 		AS tipostrum,
				R.ndg 				AS codicecliente,
		        R.codicerapporto 	AS codicerapporto,
				R.tipo 				AS tipo, 
				R.sottorapporto 	AS sottorapporto,
				R.stato 			AS stato,
				R.ID 				AS idrapporto,
				R.idptf 			AS idptf,
				S.codicetitolo 		AS codicetitolo,
				sf.descrizione 		AS descrizionetitolo,
				S.DATA 				AS DATA,
				S.valore 			AS valoresaldo,
				0 					AS sommamov, 
				(S.valore - 0) 		AS differenza,
				R.codiceagenzia 	AS codiceagenzia
FROM saldo_2018 S
	INNER JOIN rapporto R
	ON R.idptf = S.idptf
	LEFT JOIN movimento M
	ON M.idrapporto = R.ID  AND M.codicetitolo = S.codicetitolo
	INNER JOIN strumentofinanziario sf
	ON sf.codicetitolo = S.codicetitolo
	INNER JOIN ndg N
	ON N.codice = R.ndg
WHERE M.idrapporto IS NULL
AND sf.tipo_rend = 'QTA' 
AND sf.perimetro_rend = '1'
AND R.tipo != '02'
;


CURSOR squadrature_qta_lib IS

-- Squadrature per posizioni in cui ci sono sia i saldi che i movimenti
SELECT DISTINCT sf.livello_2 							AS tipostrum,
				R.ndg 									AS codicecliente,
		        R.codicerapporto 						AS codicerapporto,
				R.tipo 									AS tipo, 
				R.sottorapporto							AS sottorapporto,
				R.stato 								AS stato,
				R.ID 									AS idrapporto,
				R.idptf 								AS idptf,
				sq.codicetitolo 						AS codicetitolo,
				sf.descrizione 							AS descrizionetitolo,
				sq.DATA 								AS DATA,
				nvl(sq.valore, 0) 						AS valoresaldo,
				squadrati.sumqta 						AS sommamov, 
				(nvl(sq.valore, 0) - squadrati.sumqta)	AS differenza,
				R.codiceagenzia 						AS codiceagenzia
FROM (
	    SELECT SUM(M.qta) AS sumqta, M.codicetitolo, R.ID AS idrapporto, R.idptf, S.DATA 
	    FROM saldo_2018 S
		    INNER JOIN rapporto R
		    ON R.idptf = S.idptf
		    INNER JOIN movimento M
		    ON M.idrapporto = R.ID
		    AND M.codicetitolo = S.codicetitolo
		    AND M.DATA <= S.DATA
		    INNER JOIN causale C
		    ON C.codicecausale = M.causale
		    INNER JOIN strumentofinanziario sf
		    ON sf.codicetitolo = S.codicetitolo
	    WHERE C.flagaggsaldi = 1
	    AND ((M.DATA > 20171231 AND M.DATA <= 20181231) OR (M.DATA = 20171231 AND M.causale IN ('02_MOVIMP', '03_MOVIMP', '13_MOVIMP', '14_MOVIMP', '15_MOVIMP')))
	    AND sf.tipo_rend = 'QTA' AND sf.perimetro_rend = '1'
	    AND R.tipo = '02'
	    AND S.valore > 0
	    GROUP BY M.codicetitolo, R.ID, R.idptf, S.DATA
) squadrati
		INNER JOIN saldo_2018 sq
		ON squadrati.idptf = sq.idptf
		AND squadrati.codicetitolo = sq.codicetitolo
		AND squadrati.DATA = sq.DATA
		INNER JOIN strumentofinanziario sf
		ON sf.codicetitolo = squadrati.codicetitolo
		INNER JOIN rapporto R
		ON R.ID = squadrati.idrapporto
		INNER JOIN ndg N
		ON N.codice = R.ndg
WHERE sq.valore != sumqta
AND R.tipo = '02'
AND sq.valore > 0

	UNION

-- Squadrature per posizioni in cui ci sono i movimenti ma non ci sono i saldi
SELECT DISTINCT sf.livello_2 				AS tipostrum,
				R.ndg 						AS codicecliente,
		        R.codicerapporto 			AS codicerapporto,
				R.tipo 						AS tipo, 
				R.sottorapporto 			AS sottorapporto,
				R.stato 					AS stato,
				R.ID 						AS idrapporto,
				R.idptf 					AS idptf,
				sf.codicetitolo 			AS codicetitolo,
				sf.descrizione 				AS descrizionetitolo,
				NULL 						AS DATA,
				0 							AS valoresaldo,
				squadrati.sumqta			AS sommamov, 
				(0 - squadrati.sumqta)		AS differenza,
				R.codiceagenzia 			AS codiceagenzia
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
    AND R.tipo = '02'
    GROUP BY M.codicetitolo, R.ID, R.idptf
) squadrati
	INNER JOIN strumentofinanziario sf
	ON sf.codicetitolo = squadrati.codicetitolo
	INNER JOIN rapporto R
	ON R.ID = squadrati.idrapporto
	INNER JOIN ndg N
	ON N.codice = R.ndg
	WHERE sumqta != 0  --non esistono i saldi a 0
	AND R.tipo = '02'

	UNION

-- Squadrature per posizioni in cui NON ci sono i movimenti ma ci sono i saldi
SELECT DISTINCT sf.livello_2 		AS tipostrum,
				R.ndg 				AS codicecliente,
		        R.codicerapporto 	AS codicerapporto,
				R.tipo 				AS tipo, 
				R.sottorapporto 	AS sottorapporto,
				R.stato 			AS stato,
				R.ID 				AS idrapporto,
				R.idptf 			AS idptf,
				S.codicetitolo 		AS codicetitolo,
				sf.descrizione 		AS descrizionetitolo,
				S.DATA 				AS DATA,
				S.valore 			AS valoresaldo,
				0 					AS sommamov, 
				(S.valore - 0) 		AS differenza,
				R.codiceagenzia 	AS codiceagenzia
FROM saldo_2018 S
	INNER JOIN rapporto R
	ON R.idptf = S.idptf
	LEFT JOIN movimento M
	ON M.idrapporto = R.ID  AND M.codicetitolo = S.codicetitolo
	INNER JOIN strumentofinanziario sf
	ON sf.codicetitolo = S.codicetitolo
	INNER JOIN ndg N
	ON N.codice = R.ndg
WHERE M.idrapporto IS NULL
AND sf.tipo_rend = 'QTA' 
AND sf.perimetro_rend = '1'
AND R.tipo = '02'
AND S.valore > 0
;

TYPE squadrature_qta_type IS TABLE OF squadrature_qta%rowtype INDEX BY PLS_INTEGER;
TYPE squadrature_qta_lib_type IS TABLE OF squadrature_qta_lib%rowtype INDEX BY PLS_INTEGER;

res_squadrature_qta squadrature_qta_type;
res_squadrature_qta_lib squadrature_qta_lib_type;

ROWS      		PLS_INTEGER := 10000;
        
I 				NUMBER(38,0);
totale			NUMBER(38,0):=0;
count_deleted 	NUMBER(38,0):=0;
check_idx		INTEGER:=0;


BEGIN	

	OPEN squadrature_qta;
	LOOP
			FETCH squadrature_qta BULK COLLECT INTO res_squadrature_qta LIMIT ROWS;
				EXIT WHEN res_squadrature_qta.COUNT = 0;  
				
	      I:=0;
	      I:= res_squadrature_qta.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_squadrature_qta.FIRST .. res_squadrature_qta.LAST		
	
				MERGE INTO squadrature_2018 S
						USING
								(SELECT res_squadrature_qta(j).tipostrum 						AS tipostrum,
										res_squadrature_qta(j).codicecliente  					AS codicecliente,
									    res_squadrature_qta(j).codicerapporto  					AS codicerapporto,
										res_squadrature_qta(j).tipo 							AS tipo,
										res_squadrature_qta(j).sottorapporto 					AS sottorapporto,
										'07601' 												AS codicebanca,
										res_squadrature_qta(j).codiceagenzia 					AS codiceagenzia,
										res_squadrature_qta(j).stato 							AS stato, 
										res_squadrature_qta(j).idrapporto 						AS idrapporto, 
										res_squadrature_qta(j).idptf	 						AS idptf, 
										res_squadrature_qta(j).codicetitolo 					AS codicetitolo, 
										res_squadrature_qta(j).descrizionetitolo				AS descrizionetitolo, 
										res_squadrature_qta(j).DATA 							AS DATA,
										res_squadrature_qta(j).valoresaldo  					AS valoresaldo,
										res_squadrature_qta(j).sommamov 						AS sumqta,
										res_squadrature_qta(j).differenza 						AS differenza, 
										sysdate 												AS datains,
										sysdate 												AS dataagg,
										0														AS counter
								 FROM dual
								) A
							ON (S.idrapporto = A.idrapporto
								AND S.codicetitolo = A.codicetitolo)					
		WHEN MATCHED THEN UPDATE 
								SET S.tipostrum = A.tipostrum,
									S.codicecliente = A.codicecliente,
									S.codicerapporto = A.codicerapporto,
									S.tipo = A.tipo,
									S.sottorapporto = A.sottorapporto,
									S.codiceagenzia = A.codiceagenzia,
									S.codicebanca = A.codicebanca,
									S.stato = A.stato,
									S.idptf = A.idptf,
									S.descrizionetitolo = A.descrizionetitolo,
									S.valoresaldo = A.valoresaldo,
									S.datasaldo = A.DATA,
									S.sumqta = A.sumqta,
									S.diff = A.differenza,
									S.dataagg = A.dataagg,
									S.counter = EXTRACT(DAY FROM (A.dataagg - S.datains))
		WHEN NOT MATCHED THEN 
							INSERT (tipostrum,
									codicecliente,
									codicerapporto,
									tipo,
									sottorapporto,
									codicebanca,
									codiceagenzia,
									stato,
									idrapporto,
									idptf,
									descrizionetitolo,
									codicetitolo,
									datasaldo,
									valoresaldo,
									sumqta,
									diff,
									datains,
									dataagg,
									counter)
							VALUES (A.tipostrum,
									A.codicecliente,
									A.codicerapporto,
									A.tipo,
									A.sottorapporto,
									A.codicebanca,
									A.codiceagenzia,
									A.stato,
									A.idrapporto,
									A.idptf,
									A.descrizionetitolo,
									A.codicetitolo,
									A.DATA,
									A.valoresaldo,
									A.sumqta,
									A.differenza,
									A.datains,
									A.dataagg,
									A.counter
							);	
				
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Squadrature QTA 2018 no libretti: ' || I || ' record'); 
		COMMIT;		        
	            
	END LOOP;
	
	CLOSE squadrature_qta;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Squadrature QTA 2018 no libretti: ' || totale);
	COMMIT;
	
		
	OPEN squadrature_qta_lib;
	LOOP
			FETCH squadrature_qta_lib BULK COLLECT INTO res_squadrature_qta_lib LIMIT ROWS;
				EXIT WHEN res_squadrature_qta_lib.COUNT = 0;  
				
	      I:=0;
	      I:= res_squadrature_qta_lib.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_squadrature_qta_lib.FIRST .. res_squadrature_qta_lib.LAST		
	
				MERGE INTO squadrature_2018 S
						USING
								(SELECT res_squadrature_qta_lib(j).tipostrum 						AS tipostrum,
										res_squadrature_qta_lib(j).codicecliente  					AS codicecliente,
									    res_squadrature_qta_lib(j).codicerapporto  					AS codicerapporto,
										res_squadrature_qta_lib(j).tipo 							AS tipo,
										res_squadrature_qta_lib(j).sottorapporto 					AS sottorapporto,
										'07601' 													AS codicebanca,
										res_squadrature_qta_lib(j).codiceagenzia 					AS codiceagenzia,
										res_squadrature_qta_lib(j).stato 							AS stato, 
										res_squadrature_qta_lib(j).idrapporto 						AS idrapporto, 
										res_squadrature_qta_lib(j).idptf	 						AS idptf, 
										res_squadrature_qta_lib(j).codicetitolo 					AS codicetitolo, 
										res_squadrature_qta_lib(j).descrizionetitolo				AS descrizionetitolo, 
										res_squadrature_qta_lib(j).DATA 							AS DATA,
										res_squadrature_qta_lib(j).valoresaldo  					AS valoresaldo,
										res_squadrature_qta_lib(j).sommamov 						AS sumqta,
										res_squadrature_qta_lib(j).differenza 						AS differenza, 
										sysdate 													AS datains,
										sysdate 													AS dataagg,
										0															AS counter
								 FROM dual
								) A
							ON (S.idrapporto = A.idrapporto
								AND S.codicetitolo = A.codicetitolo)					
		WHEN MATCHED THEN UPDATE 
								SET S.tipostrum = A.tipostrum,
									S.codicecliente = A.codicecliente,
									S.codicerapporto = A.codicerapporto,
									S.tipo = A.tipo,
									S.sottorapporto = A.sottorapporto,
									S.codiceagenzia = A.codiceagenzia,
									S.codicebanca = A.codicebanca,
									S.stato = A.stato,
									S.idptf = A.idptf,
									S.descrizionetitolo = A.descrizionetitolo,
									S.valoresaldo = A.valoresaldo,
									S.datasaldo = A.DATA,
									S.sumqta = A.sumqta,
									S.diff = A.differenza,
									S.dataagg = A.dataagg,
									S.counter = EXTRACT(DAY FROM (A.dataagg - S.datains))
		WHEN NOT MATCHED THEN 
							INSERT (tipostrum,
									codicecliente,
									codicerapporto,
									tipo,
									sottorapporto,
									codicebanca,
									codiceagenzia,
									stato,
									idrapporto,
									idptf,
									descrizionetitolo,
									codicetitolo,
									datasaldo,
									valoresaldo,
									sumqta,
									diff,
									datains,
									dataagg,
									counter)
							VALUES (A.tipostrum,
									A.codicecliente,
									A.codicerapporto,
									A.tipo,
									A.sottorapporto,
									A.codicebanca,
									A.codiceagenzia,
									A.stato,
									A.idrapporto,
									A.idptf,
									A.descrizionetitolo,
									A.codicetitolo,
									A.DATA,
									A.valoresaldo,
									A.sumqta,
									A.differenza,
									A.datains,
									A.dataagg,
									A.counter
							);	
				
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Squadrature QTA 2018 libretti: ' || I || ' record'); 
		COMMIT;		        
	            
	END LOOP;
	
	CLOSE squadrature_qta_lib;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Squadrature QTA 2018 libretti: ' || totale);
		COMMIT;

	
	--Cancello squadrature rientrate
		DELETE FROM squadrature_2018
		WHERE dataagg IS NOT NULL
		AND TRUNC(sysdate) - TRUNC(dataagg) >= 1;
		
		count_deleted := count_deleted +  SQL%rowcount;
		
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Squadrature QTA 2018. Squadrature eliminate: ' || count_deleted);
		COMMIT;
		       
END;