DECLARE

CURSOR scarti_movimenti_multi IS 	
	SELECT /*+ parallel(8) */  tmp.ROWID, 
			tmp.*
	FROM TMP_PFMOV_SWPRIVATE tmp
	INNER JOIN (SELECT numero_polizza, fondo, data_nav, tipo_movimento,cod_linea,cod_universo
		    FROM TMP_PFMOV_SWPRIVATE 
		    GROUP BY numero_polizza, fondo, data_nav, tipo_movimento,cod_linea,cod_universo
		    HAVING COUNT(*) >1 ) A
	ON tmp.numero_polizza = A.numero_polizza
		AND tmp.fondo = A.fondo
		AND tmp.data_nav = A.data_nav
		and tmp.tipo_movimento = A.tipo_movimento
		and tmp.cod_linea = A.cod_linea
		and tmp.cod_universo = A.cod_universo;

TYPE scarti_movimenti_multi_type IS TABLE OF scarti_movimenti_multi%rowtype INDEX BY PLS_INTEGER;
	
res_scarti_movimenti_multi scarti_movimenti_multi_type;
	
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
															'CHIAVE PRIMARIA "NUMERO_POLIZZA, FONDO, DATA_NAV, TIPO_MOVIMENTO, COD_LINEA, COD_UNIVERSO" DUPLICATA',
															'N',
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
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER CHIAVE (NUMERO_POLIZZA, FONDO, DATA_NAV) DUPLICATA: ' || I || ' RECORD');
			        
	END LOOP;
	CLOSE scarti_movimenti_multi;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER CHIAVE (NUMERO_POLIZZA, FONDO, DATA_NAV) DUPLICATA: ' || totale);
	COMMIT;
	
END;