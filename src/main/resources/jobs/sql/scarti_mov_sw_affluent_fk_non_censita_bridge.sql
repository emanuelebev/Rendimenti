declare

cursor scarti_tbl_bridge is 	
    select /*+ parallel(8) */  tmp.rowid,
			tmp.*
	from tmp_pfmov_swprivate tmp
    where not exists (	select cod_linea, cod_universo
    					from tbl_bridge b
    					where tmp.cod_linea = b.cod_linea 
    					and tmp.cod_universo = b.cod_universo
    				 )
    and tmp.cod_linea is not null
    and tmp.cod_universo is not null;
	
TYPE scarti_tbl_bridge_type IS TABLE OF scarti_tbl_bridge%rowtype INDEX BY PLS_INTEGER;

res_scarti_tbl_bridge scarti_tbl_bridge_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN
	
	OPEN scarti_tbl_bridge;
	LOOP
			FETCH scarti_tbl_bridge BULK COLLECT INTO res_scarti_tbl_bridge LIMIT ROWS;
				EXIT WHEN res_scarti_tbl_bridge.COUNT = 0;  
				
	      I:=0;
	      I:= res_scarti_tbl_bridge.COUNT;
	      totale := totale + I;
				
				FORALL j IN res_scarti_tbl_bridge.FIRST .. res_scarti_tbl_bridge.LAST		
	
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
												VALUES (	res_scarti_tbl_bridge(j).numero_polizza,
															res_scarti_tbl_bridge(j).fondo,
															res_scarti_tbl_bridge(j).data_nav,
															res_scarti_tbl_bridge(j).isin,
															res_scarti_tbl_bridge(j).tipo_movimento,
															res_scarti_tbl_bridge(j).nav,
															res_scarti_tbl_bridge(j).quote,
															res_scarti_tbl_bridge(j).importo,
															SYSDATE,
															'CHIAVE ESTERNA CODICETITOLO NON PRESENTE SU TBL_BRIDGE',
															'S',
															res_scarti_tbl_bridge(j).cod_linea,
															res_scarti_tbl_bridge(j).data_mov,
															res_scarti_tbl_bridge(j).cod_universo,
															res_scarti_tbl_bridge(j).costo_etf
														);
			        COMMIT;		
			        
			        FORALL j IN res_scarti_tbl_bridge.FIRST .. res_scarti_tbl_bridge.LAST
			        	
			        DELETE FROM TMP_PFMOV_SWPRIVATE tmp_del
					WHERE tmp_del.ROWID = res_scarti_tbl_bridge(j).ROWID;
					
					COMMIT;
			        	
	            
	             INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER CODICETITOLO NON PRESENTE SU TBL_BRIDGE: ' || I || ' RECORD');
	             
	               totale:=totale+I;
			        
	END LOOP;
	CLOSE scarti_tbl_bridge;
	
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER CODICETITOLO NON PRESENTE SU TBL_BRIDGE: ' || totale);
	COMMIT;
	
END;