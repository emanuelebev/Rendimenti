-- PTR-258 BFP_gestione id buono originario

DECLARE
	
CURSOR update_id_buono_orig	IS
	SELECT codice, 
		   CASE 
		   	WHEN tiporapporto = '02' 
		   		THEN nvl(codiceinterno,'LIQ_EUR_LIB')
		   	ELSE codiceinterno
		   	END AS codiceinterno, 
		   	codicerapporto
	FROM tmp_pfmovimenti
	WHERE codicerapporto LIKE '%-%' 
	AND id_buono_originario IS NULL;
	
TYPE update_id_buono_orig_type IS TABLE OF update_id_buono_orig%rowtype INDEX BY PLS_INTEGER;
	
res_update_id_buono_orig update_id_buono_orig_type;
	
ROWS      PLS_INTEGER := 10000;
        
I 			NUMBER(38,0);
totale		NUMBER(38,0):=0;


BEGIN

	OPEN update_id_buono_orig;
		LOOP
			FETCH update_id_buono_orig BULK COLLECT INTO res_update_id_buono_orig LIMIT ROWS;
				EXIT WHEN res_update_id_buono_orig.COUNT = 0;  
					
		      I:=0;
		      I:= res_update_id_buono_orig.COUNT;
		      totale := totale + I;
					
				FORALL j IN res_update_id_buono_orig.FIRST .. res_update_id_buono_orig.LAST		
				
				UPDATE tmp_pfmovimenti 
					SET id_buono_originario = substr(res_update_id_buono_orig(j).codicerapporto, 1, instr(res_update_id_buono_orig(j).codicerapporto, '-')-1)
				WHERE codice = res_update_id_buono_orig(j).codice 
				AND codiceinterno = res_update_id_buono_orig(j).codiceinterno
				AND codicerapporto = res_update_id_buono_orig(j).codicerapporto;
				
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' ID_BUONO_ORIGINARIO TMP_PFMOVIMENTI RIGHE AGGIORNATE: ' || I );
					        
				COMMIT;		        
		            
		END LOOP;
	CLOSE update_id_buono_orig;
		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' ID_BUONO_ORIGINARIO TMP_PFMOVIMENTI TOTALE RIGHE AGGIORNATE: ' || totale);
	COMMIT;				
	  
END;