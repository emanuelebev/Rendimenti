DECLARE

CURSOR salpo_multi IS
	SELECT /*+ PARALLEL(8) */
		CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
			ELSE sp.codiceinterno END																		AS codicetitolo,
		MIN(R.ID) 																							AS id_rapporto
	FROM TMP_PFSALPOSP_RECUP sp
		LEFT JOIN tbl_bridge b
			ON b.cod_universo = sp.codiceinterno
				AND (b.cod_linea = sp.codiceinternomacroprodotto OR 
					(b.cod_linea IS NULL AND sp.codiceinternomacroprodotto IS NULL))
		LEFT JOIN strumentofinanziario sf
			ON sf.codicetitolo = sp.codiceinterno
		INNER JOIN rapporto R
			ON R.codicerapporto = LPAD(trim(sp.codicerapporto),12,'0')
				AND R.tipo = '13'
	WHERE  sp.flagesclusione = '0'
	AND (b.codicetitolo IS NOT NULL OR sf.livello_2 IN ('POLIZZE UNIT LINKED', 'POLIZZE INDEX LINKED'))
	AND R.codicetitolo_multiramo is null
	GROUP BY sp.codicerapporto, 
			 CASE WHEN b.codicetitolo IS NOT NULL THEN  b.codicetitolo
					ELSE sp.codiceinterno END, 
			 sp.dataaggiornamento
	ORDER BY codicetitolo, id_rapporto;
			 
TYPE SALPO_MULTI_TYPE IS TABLE OF SALPO_MULTI%ROWTYPE INDEX BY PLS_INTEGER;

RES_SALPO_MULTI SALPO_MULTI_TYPE;
	
ROWS    PLS_INTEGER := 10000;

I 		NUMBER(38,0):=0;
totale	NUMBER(38,0):=0;


BEGIN
	
	
	OPEN SALPO_MULTI; --Saldi polizze multiramo
		LOOP
			FETCH SALPO_MULTI BULK COLLECT INTO RES_SALPO_MULTI LIMIT ROWS;
				EXIT WHEN RES_SALPO_MULTI.COUNT = 0;  
			
			I:=0;
			TOTALE:=0;
			I:= RES_SALPO_MULTI.COUNT;
			TOTALE := TOTALE + I;
			
			FORALL J IN RES_SALPO_MULTI.FIRST .. RES_SALPO_MULTI.LAST
					
				UPDATE /*+ PARALLEL(8) */ rapporto SET 
				codicetitolo_multiramo = RES_SALPO_MULTI(j).codicetitolo
				WHERE ID = RES_SALPO_MULTI(j).id_rapporto;
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CODICETITOLO_MULTIRAMO SP RECUPERO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
	CLOSE SALPO_MULTI;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CODICETITOLO_MULTIRAMO SP RECUPERO - COMMIT ON ROW: ' || totale);
	COMMIT;
END;