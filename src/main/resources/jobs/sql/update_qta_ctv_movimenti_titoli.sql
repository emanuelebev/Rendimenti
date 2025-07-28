DECLARE

--update della quantità
CURSOR upd_qta_mov IS
SELECT M.ROWID, M.quantita_da_sistemare, C.segno
	FROM tmp_pfmov_titoli M
	INNER JOIN causale C
		ON C.codicecausale_ori = M.causale
	WHERE C.codicecausale_ori IN ('ESWR','RIMB','SCA','SCCT','VNCM','VNCO','ABWS','ACRT','ADOC','ESWV','SCCO','SCDI','SCGD','SCGT','SCOC')
	AND C.codicecausale not in ('GP_RIMB');

--update della quantità senza logiche
CURSOR upd_qta_mov_other IS
SELECT M.ROWID, M.quantita_da_sistemare
	FROM tmp_pfmov_titoli M
	WHERE M.quantita is null;
	
--update del controvalore
CURSOR upd_ctv_mov IS
	SELECT M.ROWID, M.quantita, M.cambio, ss.valore AS prezzo, to_number(sf.i_moltiplicatore, '999999999999999999999999999.999999999999999999999999999') AS moltiplicatore
	FROM tmp_pfmov_titoli M
	INNER JOIN causale C
		ON C.codicecausale_ori = M.causale
	INNER JOIN serie_storica ss
	  ON substr(M.codiceinterno, 2) = ss.codicetitolo 
	  	AND ss.datalivello = (SELECT MAX(ss1.datalivello)
		                        FROM serie_storica ss1
		                        WHERE ss1.codicetitolo = substr(M.codiceinterno, 2)
		                        AND ss1.datalivello <= to_number(to_char(TO_DATE(M.datavaluta, 'YYYY-MM-DD'), 'YYYYMMDD')))
	INNER JOIN strumentofinanziario sf
	  ON substr(M.codiceinterno, 2) = sf.codicetitolo 	                        
	WHERE C.codicecausale_ori IN ('CAR','SCA','CAGD','CAGT','SCGD','SCGT')
	AND M.cambio != 0;
	
TYPE upd_qta_mov_type IS TABLE OF upd_qta_mov%rowtype INDEX BY PLS_INTEGER;
TYPE upd_qta_mov_other_type IS TABLE OF upd_qta_mov_other%rowtype INDEX BY PLS_INTEGER;
TYPE upd_ctv_mov_type IS TABLE OF upd_ctv_mov%rowtype INDEX BY PLS_INTEGER;
	
res_upd_qta_mov upd_qta_mov_type;
res_upd_qta_mov_other upd_qta_mov_other_type;
res_upd_ctv_mov upd_ctv_mov_type;
	
ROWS      PLS_INTEGER := 10000;
	        
I 		  NUMBER(38,0);
totale	  NUMBER(38,0):=0;
	

BEGIN
	
	 OPEN upd_qta_mov;
		LOOP
			FETCH upd_qta_mov BULK COLLECT INTO res_upd_qta_mov LIMIT ROWS;
				EXIT WHEN res_upd_qta_mov.COUNT = 0;  
					
		      I:=0;
		      I:= res_upd_qta_mov.COUNT;
		      totale := totale + I;
					
				FORALL j IN res_upd_qta_mov.FIRST .. res_upd_qta_mov.LAST		
		
					UPDATE tmp_pfmov_titoli mov
					SET mov.quantita = (res_upd_qta_mov(j).quantita_da_sistemare * res_upd_qta_mov(j).segno)
					WHERE mov.ROWID = res_upd_qta_mov(j).ROWID;
					
				INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE QTA MOVIMENTI TITOLI: ' || I || ' RECORD');
					        
				COMMIT;		        
		            
		END LOOP;
		CLOSE upd_qta_mov;
		
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE QTA MOVIMENTI TITOLI: ' || totale);
		COMMIT;
		
	 OPEN upd_qta_mov_other;
		LOOP
			FETCH upd_qta_mov_other BULK COLLECT INTO res_upd_qta_mov_other LIMIT ROWS;
				EXIT WHEN res_upd_qta_mov_other.COUNT = 0;  
					
		      I:=0;
		      I:= res_upd_qta_mov_other.COUNT;
		      totale := totale + I;
					
				FORALL j IN res_upd_qta_mov_other.FIRST .. res_upd_qta_mov_other.LAST		
		
					UPDATE tmp_pfmov_titoli mov
					SET mov.quantita = res_upd_qta_mov_other(j).quantita_da_sistemare
					WHERE mov.ROWID = res_upd_qta_mov_other(j).ROWID;
					
				INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE QTA MOVIMENTI TITOLI: ' || I || ' RECORD');
					        
				COMMIT;		        
		            
		END LOOP;
		CLOSE upd_qta_mov_other;
		
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE QTA RESTANTI MOVIMENTI TITOLI: ' || totale);
		COMMIT;
		
	OPEN upd_ctv_mov;
		LOOP
			FETCH upd_ctv_mov BULK COLLECT INTO res_upd_ctv_mov LIMIT ROWS;
				EXIT WHEN res_upd_ctv_mov.COUNT = 0;  
					
		      I:=0;
		      I:= res_upd_ctv_mov.COUNT;
		      totale := totale + I;
					
				FORALL j IN res_upd_ctv_mov.FIRST .. res_upd_ctv_mov.LAST		
		
					UPDATE tmp_pfmov_titoli mov
					SET mov.ctvregolato = (res_upd_ctv_mov(j).prezzo * res_upd_ctv_mov(j).quantita * res_upd_ctv_mov(j).moltiplicatore / res_upd_ctv_mov(j).cambio) * (-1)
					WHERE mov.ROWID = res_upd_ctv_mov(j).ROWID;
					
				INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CTV MOVIMENTI TITOLI: ' || I || ' RECORD');
					        
				COMMIT;		        
		            
		END LOOP;
		CLOSE upd_ctv_mov;
		
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE CTV MOVIMENTI TITOLI: ' || totale);
		COMMIT;
		
END;