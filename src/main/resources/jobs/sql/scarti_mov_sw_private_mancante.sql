DECLARE

CURSOR scarti_movimenti_multi IS 	
    SELECT /*+ parallel(8) */  tmp.ROWID,
			tmp.*
	FROM TMP_PFMOV_SWPRIVATE TMP
    INNER JOIN tbl_bridge b
		ON TMP.fondo = b.cod_universo
	LEFT JOIN MOVIMENTO MOV
	ON LPAD(trim(tmp.numero_polizza),12,'0') = MOV.numero_polizza
		AND b.codicetitolo = MOV.codicetitolo
	WHERE MOV.idrapporto is null
	AND TMP.tipo_movimento = 'Fondo Precedente'
	and TMP.fondo != '70'
	and tmp.cod_linea is null;
	
	
CURSOR scarti_movimenti_multi_70 IS 	
    SELECT /*+ parallel(8) */  tmp.ROWID,
			tmp.*
	FROM TMP_PFMOV_SWPRIVATE TMP
    INNER JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(tmp.numero_polizza),12,'0')
			AND r.tipo = '13'
	INNER JOIN tbl_bridge b
		ON tmp.fondo = b.cod_universo
		and r.codicetitolo_multiramo = b.codicetitolo_multiramo
	LEFT JOIN MOVIMENTO MOV
	ON r.id = MOV.idrapporto
		AND b.codicetitolo = MOV.codicetitolo
	WHERE MOV.idrapporto is null
	AND TMP.tipo_movimento = 'Fondo Precedente'
	and TMP.fondo = '70'
	and tmp.cod_linea is null;

TYPE scarti_movimenti_multi_type IS TABLE OF scarti_movimenti_multi%rowtype INDEX BY PLS_INTEGER;
TYPE scarti_movimenti_multi_70_type IS TABLE OF scarti_movimenti_multi_70%rowtype INDEX BY PLS_INTEGER;

res_scarti_movimenti_multi scarti_movimenti_multi_type;
res_scarti_movimenti_multi_70 scarti_movimenti_multi_70_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_movimenti_multi;
	LOOP
			FETCH scarti_movimenti_multi BULK COLLECT INTO res_scarti_movimenti_multi LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_multi.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_multi.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_SWPRIVATE (numero_polizza,
															fondo,
															data_nav,
															isin,
															tipo_movimento,
															nav,
															quote,
															importo,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile,
															cod_linea,
															data_mov,
															cod_universo,
															costo_etf
														)
												VALUES (	res_scarti_movimenti_multi(j).numero_polizza,
															res_scarti_movimenti_multi(j).fondo,
															res_scarti_movimenti_multi(j).data_nav,
															res_scarti_movimenti_multi(j).isin,
															res_scarti_movimenti_multi(j).tipo_movimento,
															res_scarti_movimenti_multi(j).nav,
															res_scarti_movimenti_multi(j).quote,
															res_scarti_movimenti_multi(j).importo,
															SYSDATE,
															'MOVIMENTO PRECEDENTE NON TROVATO',
															'S',
															res_scarti_movimenti_multi(j).cod_linea,
															res_scarti_movimenti_multi(j).data_mov,
															res_scarti_movimenti_multi(j).cod_universo,
															res_scarti_movimenti_multi(j).costo_etf
														);
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_multi.FIRST .. res_scarti_movimenti_multi.LAST
			        	
			        DELETE FROM TMP_PFMOV_SWPRIVATE tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_multi(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER MOVIMENTO PRECEDENTE NON TROVATO: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_multi;
	
	
	I:=0;
	
	
	OPEN scarti_movimenti_multi_70;
	LOOP
			FETCH scarti_movimenti_multi_70 BULK COLLECT INTO res_scarti_movimenti_multi_70 LIMIT ROWS;
				EXIT WHEN res_scarti_movimenti_multi_70.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_movimenti_multi_70.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_movimenti_multi_70.FIRST .. res_scarti_movimenti_multi_70.LAST		
	
				INSERT INTO TBL_SCARTI_TMP_PFMOV_SWPRIVATE (numero_polizza,
															fondo,
															data_nav,
															isin,
															tipo_movimento,
															nav,
															quote,
															importo,
															tmstp, 							
															motivo_scarto, 				 
															riproponibile,
															cod_linea,
															data_mov,
															cod_universo,
															costo_etf
														)
												VALUES (	res_scarti_movimenti_multi_70(j).numero_polizza,
															res_scarti_movimenti_multi_70(j).fondo,
															res_scarti_movimenti_multi_70(j).data_nav,
															res_scarti_movimenti_multi_70(j).isin,
															res_scarti_movimenti_multi_70(j).tipo_movimento,
															res_scarti_movimenti_multi_70(j).nav,
															res_scarti_movimenti_multi_70(j).quote,
															res_scarti_movimenti_multi_70(j).importo,
															SYSDATE,
															'MOVIMENTO PRECEDENTE NON TROVATO',
															'S',
															res_scarti_movimenti_multi_70(j).cod_linea,
															res_scarti_movimenti_multi_70(j).data_mov,
															res_scarti_movimenti_multi_70(j).cod_universo,
															res_scarti_movimenti_multi_70(j).costo_etf
														);
			        COMMIT;		
			        
			        FORALL j IN res_scarti_movimenti_multi_70.FIRST .. res_scarti_movimenti_multi_70.LAST
			        	
			        DELETE FROM TMP_PFMOV_SWPRIVATE tmp_del
					WHERE tmp_del.ROWID = res_scarti_movimenti_multi_70(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER MOVIMENTO PRECEDENTE NON TROVATO: ' || I || ' RECORD');
			        
	             totale:=totale+I;
	             
	END LOOP;
	CLOSE scarti_movimenti_multi_70;
	
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER MOVIMENTO PRECEDENTE NON TROVATO: ' || totale);
	COMMIT;
	
END;