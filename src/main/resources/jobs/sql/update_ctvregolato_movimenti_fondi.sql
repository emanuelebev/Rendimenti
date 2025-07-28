DECLARE

CURSOR upd_ctv_mov_scar IS
	SELECT DISTINCT M.ROWID, ss.valore AS prezzo, M.quantita, M.commissioni, M.imposte  
	FROM tmp_pfmovimenti M
	INNER JOIN causale C
		ON C.codicecausale  = M.causale
	INNER JOIN serie_storica ss
	  ON M.codiceinterno = ss.codicetitolo 
	  AND ss.datalivello = (SELECT MAX(ss1.datalivello)
	                        FROM serie_storica ss1
	                        WHERE ss1.codicetitolo = M.codiceinterno 
	                        AND ss1.datalivello <= to_number(to_char(TO_DATE(M.datacontabile, 'YYYY-MM-DD'), 'YYYYMMDD')))
	WHERE causale IN ('ESS', 'QXS', 'TCS', 'QCS', 'FDS')
	AND M.ctvregolato = 0;

CURSOR upd_ctv_mov_car IS
	SELECT DISTINCT M.ROWID, ss.valore AS prezzo, M.quantita, M.commissioni, M.imposte   
	FROM tmp_pfmovimenti M
	INNER JOIN causale C
		ON C.codicecausale  = M.causale
	INNER JOIN serie_storica ss
	  ON M.codiceinterno = ss.codicetitolo 
	  AND ss.datalivello = (SELECT MAX(ss1.datalivello)
	                        FROM serie_storica ss1
	                        WHERE ss1.codicetitolo = M.codiceinterno 
	                        AND ss1.datalivello <= to_number(to_char(TO_DATE(M.datacontabile, 'YYYY-MM-DD'), 'YYYYMMDD')))
	WHERE causale IN ('ECS', 'QYS', 'TSS', 'QSS', 'FCS')
	AND M.ctvregolato = 0;

TYPE upd_ctv_mov_car_type IS TABLE OF upd_ctv_mov_car%rowtype INDEX BY PLS_INTEGER;
TYPE upd_ctv_mov_scar_type IS TABLE OF upd_ctv_mov_scar%rowtype INDEX BY PLS_INTEGER;
	
res_upd_ctv_mov_scar upd_ctv_mov_scar_type;
res_upd_ctv_mov_car upd_ctv_mov_car_type;
	
ROWS      PLS_INTEGER := 10000;
	        
I 				NUMBER(38,0);
totale			NUMBER(38,0):=0;
	

BEGIN

	BEGIN
		
	OPEN upd_ctv_mov_scar;
	LOOP
			FETCH upd_ctv_mov_scar BULK COLLECT INTO res_upd_ctv_mov_scar LIMIT ROWS;
				EXIT WHEN res_upd_ctv_mov_scar.COUNT = 0;  
				
	      I:=0;
	      I:= res_upd_ctv_mov_scar.COUNT;
	      totale := totale + I;
				
			FORALL j IN res_upd_ctv_mov_scar.FIRST .. res_upd_ctv_mov_scar.LAST		

			UPDATE tmp_pfmovimenti mov
			SET mov.ctvregolato = (res_upd_ctv_mov_scar(j).prezzo * res_upd_ctv_mov_scar(j).quantita) + (res_upd_ctv_mov_scar(j).commissioni + res_upd_ctv_mov_scar(j).imposte)
			WHERE mov.ROWID = res_upd_ctv_mov_scar(j).ROWID;
			
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CTV REGOLATO MOVIMENTI DI SCARICO QUOTE FONDI: ' || I || ' RECORD');
			
			COMMIT;		        
	            
	END LOOP;
	CLOSE upd_ctv_mov_scar;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CTV REGOLATO MOVIMENTI DI SCARICO QUOTE FONDI: ' || totale);
		COMMIT;
	END;
		
	BEGIN

	I:=0;
	totale:=0;
		
	OPEN upd_ctv_mov_car;
	LOOP
			FETCH upd_ctv_mov_car BULK COLLECT INTO res_upd_ctv_mov_car LIMIT ROWS;
				EXIT WHEN res_upd_ctv_mov_car.COUNT = 0;  
				
	      I:=0;
	      I:= res_upd_ctv_mov_car.COUNT;
	      totale := totale + I;
				
			FORALL j IN res_upd_ctv_mov_car.FIRST .. res_upd_ctv_mov_car.LAST		
	
			UPDATE tmp_pfmovimenti mov
			SET mov.ctvregolato = (res_upd_ctv_mov_car(j).prezzo * res_upd_ctv_mov_car(j).quantita) - (res_upd_ctv_mov_car(j).commissioni + res_upd_ctv_mov_car(j).imposte)
			WHERE mov.ROWID = res_upd_ctv_mov_scar(j).ROWID;
								
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CTV REGOLATO MOVIMENTI DI CARICO QUOTE FONDI: ' || I || ' RECORD');
			 
			COMMIT;		        
	            
	END LOOP;
	CLOSE upd_ctv_mov_car;
		
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CTV REGOLATO MOVIMENTI DI CARICO QUOTE FONDI: ' || totale);
		COMMIT;
		
	END;	
END;