DECLARE

--Movimenti polizze switch private
CURSOR cerca_swprivate_r3 IS 
	SELECT 	/*+ PARALLEL(8) */	  
			r.id																							AS idrapporto,
			numero_polizza||'_'||fondo||'_'||data_nav														AS numreg,
			LPAD(trim(P.numero_polizza),12,'0')																AS numero_polizza,
			b.codicetitolo																					AS codicetitolo,
			TO_CHAR(TO_DATE(data_nav, 'YYYY-MM-DD'), 'YYYYMMDD')											AS data,
			'13_' || tipo_movimento																			AS causale,		
			'13' 																							AS c_procedura,
			quote																							AS qta,
			nav																								AS prezzo,
			importo																							AS ctv
	FROM TMP_PFMOV_SWPRIVATE p
		INNER JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	INNER JOIN tbl_bridge b
		ON p.fondo = b.cod_universo
	WHERE r.codicetitolo_multiramo is not null
	AND p.fondo != '70'
	and p.cod_linea is null
	ORDER BY r.id, numero_polizza||'_'||fondo||'_'||data_nav;
	
CURSOR cerca_swprivate_r1 IS 
	SELECT 	/*+ PARALLEL(8) */	  
			r.id																							AS idrapporto,
			numero_polizza||'_'||fondo||'_'||data_nav														AS numreg,
			LPAD(trim(P.numero_polizza),12,'0')																AS numero_polizza,
			b.codicetitolo																					AS codicetitolo,
			TO_CHAR(TO_DATE(data_nav, 'YYYY-MM-DD'), 'YYYYMMDD')											AS data,
			'13_' || tipo_movimento																			AS causale,		
			'13' 																							AS c_procedura,
			quote																							AS qta,
			nav																								AS prezzo,
			importo																							AS ctv
	FROM TMP_PFMOV_SWPRIVATE p
		INNER JOIN rapporto r
			ON r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			AND r.tipo = '13'
	INNER JOIN tbl_bridge b
		ON p.fondo = b.cod_universo
		and r.codicetitolo_multiramo = b.codicetitolo_multiramo
	WHERE r.codicetitolo_multiramo is not null
	AND p.fondo = '70'
	and p.cod_linea is null
	ORDER BY r.id, numero_polizza||'_'||fondo||'_'||data_nav;

I NUMBER(38,0):=0;
totale NUMBER(38,0):=0;


BEGIN
				
	FOR cur_item IN cerca_swprivate_r3
    	LOOP
        I := I+1;

		MERGE INTO movimento mov
		  USING (SELECT cur_item.idrapporto           			AS idrapporto,
						cur_item.numreg           				AS numreg,
						cur_item.numero_polizza           		AS numero_polizza,
						cur_item.data           				AS data,
						cur_item.codicetitolo           		AS codicetitolo,
						cur_item.c_procedura           			AS c_procedura,
						cur_item.causale           				AS causale,
						cur_item.qta           					AS qta,
						cur_item.prezzo           				AS prezzo,
						cur_item.ctv           					AS ctv
			FROM dual
			) tomerge
		  ON (mov.idrapporto = tomerge.idrapporto
		  	 AND mov.numreg = tomerge.numreg)
		   
	WHEN MATCHED THEN UPDATE
		  SET
				mov.numero_polizza = tomerge.numero_polizza,
				mov.data = tomerge.data,
				mov.codicetitolo = tomerge.codicetitolo,
				mov.c_procedura = tomerge.c_procedura,
				mov.causale = tomerge.causale,
				mov.qta = tomerge.qta,
				mov.prezzo = tomerge.prezzo,
				mov.ctv = tomerge.ctv	
  	
	WHEN NOT MATCHED THEN 
			INSERT (	idrapporto,
						numreg,
						numero_polizza,
						data,
						codicetitolo,
						c_procedura,
						causale,
						qta,
						prezzo,
						ctv		
					)
  			VALUES (tomerge.idrapporto,
					tomerge.numreg,
					tomerge.numero_polizza,
					tomerge.data,
					tomerge.codicetitolo,
					tomerge.c_procedura,
					tomerge.causale,
					tomerge.qta,
					tomerge.prezzo,
					tomerge.ctv	
				);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_SWPRIVATE - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;

	totale:=totale+I;
	
	END LOOP;
	
	I:=0;
	
	FOR cur_item IN cerca_swprivate_r1
    	LOOP
        I := I+1;

		MERGE INTO movimento mov
		  USING (SELECT cur_item.idrapporto           			AS idrapporto,
						cur_item.numreg           				AS numreg,
						cur_item.numero_polizza           		AS numero_polizza,
						cur_item.data           				AS data,
						cur_item.codicetitolo           		AS codicetitolo,
						cur_item.c_procedura           			AS c_procedura,
						cur_item.causale           				AS causale,
						cur_item.qta           					AS qta,
						cur_item.prezzo           				AS prezzo,
						cur_item.ctv           					AS ctv
			FROM dual
			) tomerge
		  ON (mov.idrapporto = tomerge.idrapporto
		  	 AND mov.numreg = tomerge.numreg)
		   
	WHEN MATCHED THEN UPDATE
		  SET
				mov.numero_polizza = tomerge.numero_polizza,
				mov.data = tomerge.data,
				mov.codicetitolo = tomerge.codicetitolo,
				mov.c_procedura = tomerge.c_procedura,
				mov.causale = tomerge.causale,
				mov.qta = tomerge.qta,
				mov.prezzo = tomerge.prezzo,
				mov.ctv = tomerge.ctv	
  	
	WHEN NOT MATCHED THEN 
			INSERT (	idrapporto,
						numreg,
						numero_polizza,
						data,
						codicetitolo,
						c_procedura,
						causale,
						qta,
						prezzo,
						ctv		
					)
  			VALUES (tomerge.idrapporto,
					tomerge.numreg,
					tomerge.numero_polizza,
					tomerge.data,
					tomerge.codicetitolo,
					tomerge.c_procedura,
					tomerge.causale,
					tomerge.qta,
					tomerge.prezzo,
					tomerge.ctv	
				);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_SWPRIVATE - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	totale:=totale+I;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_SWPRIVATE - COMMIT ON ROW: ' || totale);
	COMMIT;
END;