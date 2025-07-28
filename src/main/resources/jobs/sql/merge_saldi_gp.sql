DECLARE

CURSOR merge_saldi_gp IS
	SELECT 	/*+ PARALLEL(8) */	  
			MAX(R.idptf)															AS idptf,
			'07601'												    				AS codicebanca,
			'55111'												    				AS codicefiliale, 
			MAX(tmp.numero_deposito || tmp.numero_sottodeposito)					AS codicerapporto,
			gp.codicetitolo										    				AS codicetitolo,
			to_number(to_char(TO_DATE(data_saldo, 'YYYY-MM-DD'), 'YYYYMMDD' )) 		AS data,
			SUM(nvl(ctv_mercato, 0))							   					AS ctv,
			to_number(to_char(sysdate, 'YYYYMMDD' ))								AS dataaggiornamento,
			'EUR'												    				AS divisa,
			MAX(R.id)											    				AS id_rapporto
	FROM tmp_pfsaldi_gp tmp
 	INNER JOIN rapporto R
    	ON R.codicerapporto = tmp.numero_deposito || tmp.numero_sottodeposito
    INNER JOIN tbl_bridge_gp gp
    	ON tmp.codicetitolo_interno = gp.codice_linea
    GROUP BY tmp.numero_deposito || tmp.numero_sottodeposito, gp.codicetitolo, tmp.data_saldo
    ORDER BY idptf, codicetitolo, data;
I 		NUMBER(38,0):=0;


BEGIN
	    
	FOR cur_item IN merge_saldi_gp
    	LOOP
        I := I+1;	

		MERGE INTO SALDO_REND sr
		  USING (SELECT cur_item.idptf				    AS idptf,
						cur_item.codicebanca			AS codicebanca,
						cur_item.codicefiliale		    AS codicefiliale, 
						cur_item.codicerapporto		    AS codicerapporto, 
						cur_item.codicetitolo			AS codicetitolo, 
						cur_item.data					AS data, 
						cur_item.ctv					AS ctv,
						cur_item.dataaggiornamento	    AS dataaggiornamento,
						cur_item.divisa				    AS divisa, 
						cur_item.id_rapporto			AS id_rapporto
				FROM dual
			) tomerge
			 ON (sr.idptf = tomerge.idptf
			  	 AND sr.codicetitolo = tomerge.codicetitolo
			  	 AND sr."DATA" = tomerge."DATA")

		WHEN MATCHED THEN UPDATE
				  SET sr.codicebanca = tomerge.codicebanca,
					sr.codicefiliale = tomerge.codicefiliale,
					sr.codicerapporto = tomerge.codicerapporto,
					sr.ctv = tomerge.ctv,
					sr.dataaggiornamento = tomerge.dataaggiornamento,
					sr.divisa = tomerge.divisa,
					sr.id_rapporto = tomerge.id_rapporto
					
		WHEN NOT MATCHED 
			THEN INSERT	(	idptf,
							codicebanca,
							codicefiliale, 
							codicerapporto, 
							codicetitolo, 
							data, 
							ctv,
							dataaggiornamento,
							divisa, 
							id_rapporto
							)
			VALUES( tomerge.idptf,
					tomerge.codicebanca,
					tomerge.codicefiliale, 
					tomerge.codicerapporto, 
					tomerge.codicetitolo, 
					tomerge.data, 
					tomerge.ctv,
					tomerge.dataaggiornamento,
					tomerge.divisa, 
					tomerge.id_rapporto
					);
		
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND GP - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
	
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE SALDO_REND GP - COMMIT ON ROW: ' || I);
	COMMIT;     
	
END;