DECLARE

--Movimenti incassati fondo polizze premium
CURSOR cerca_movmulti IS 
	SELECT 	/*+ PARALLEL(8) */	  
			r.id																												AS idrapporto,
			id_titolo||'_'||ramo||'_'||codice_prodotto||'_'||numero_polizza||'_'||tipo_titolo||'_'||data_effetto_titolo
				||'_'||codice_motivo_storno||'_'||data_carico||'_'||codice_fondo												AS numreg,
			ramo																												AS ramo,
			codice_prodotto																										AS codice_prodotto_universo, 
			LPAD(trim(P.numero_polizza),12,'0')																					AS numero_polizza,
			'13' 																												AS c_procedura,
			'13_' || tipo_titolo																								AS causale,
			TO_DATE(data_carico, 'YYYYMMDD')																					AS data_carico,
			b.codicetitolo																										AS codicetitolo,
			quote																												AS qta,
			nav																													AS prezzo,
			importo																												AS ctv,
			TO_NUMBER(TO_CHAR(TO_DATE(data_effetto_titolo, 'YYYY-MM-DD'), 'YYYYMMDD'))											AS data,
			TO_DATE(data_effetto_titolo, 'YYYYMMDD')																			AS data_effetto_titolo,
			costo_etf																											AS costo_etf					
	FROM TMP_PFMOV_INC_FONDO p
		inner join rapporto r
			on r.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
			and r.tipo = '13'
	INNER JOIN tbl_bridge b
	ON p.codice_fondo = b.cod_universo
	where r.codicetitolo_multiramo is not null
	order by r.id, id_titolo||'_'||ramo||'_'||codice_prodotto||'_'||numero_polizza||'_'||tipo_titolo||'_'||data_effetto_titolo
				||'_'||codice_motivo_storno||'_'||data_carico||'_'||codice_fondo;


CURSOR update_f_cancellato IS 	
	SELECT /*+ parallel(8) */ DISTINCT  mov.idrapporto,
	mov.numreg
	FROM TMP_PFMOV_INC_FONDO TMP
	INNER JOIN MOVIMENTO_RAMO_TERZO MOV
	ON tmp.ramo = MOV.ramo
		AND tmp.codice_prodotto = MOV.codice_prodotto_universo
		AND LPAD(trim(tmp.numero_polizza),12,'0') = MOV.numero_polizza
		AND tmp.tipo_titolo = substr(MOV.causale,4)
		AND  TO_DATE(tmp.data_effetto_titolo, 'YYYYMMDD') = MOV.data_effetto_titolo;

I NUMBER(38,0):=0;


BEGIN
				
	FOR cur_item IN cerca_movmulti
    	LOOP
        I := I+1;

		MERGE INTO movimento mov
		  USING (SELECT cur_item.idrapporto 				AS idrapporto,
						cur_item.numreg 					AS numreg,
						cur_item.ramo 						AS ramo,
						cur_item.codice_prodotto_universo 	AS codice_prodotto_universo, 
						cur_item.numero_polizza 			AS numero_polizza,
						cur_item.c_procedura 				AS c_procedura,
						cur_item.causale 					AS causale,
						cur_item.data_carico 				AS data_carico,
						cur_item.codicetitolo 				AS codicetitolo,
						cur_item.qta 						AS qta,
						cur_item.prezzo 					AS prezzo,
						cur_item.ctv 						AS ctv,
						cur_item.data 						AS data,
						cur_item.data_effetto_titolo 		AS data_effetto_titolo,
						cur_item.costo_etf	 				AS costo_etf
						
			FROM dual
			) tomerge
		  ON (mov.idrapporto = tomerge.idrapporto
		  	 AND mov.numreg = tomerge.numreg)
		   
	WHEN MATCHED THEN UPDATE
		  SET
				mov.ramo = tomerge.ramo,
				mov.codice_prodotto_universo  = tomerge.codice_prodotto_universo, 
				mov.numero_polizza = tomerge.numero_polizza,
				mov.c_procedura = tomerge.c_procedura,
				mov.causale = tomerge.causale,
				mov.data_carico = tomerge.data_carico,
				mov.codicetitolo = tomerge.codicetitolo,
				mov.qta = tomerge.qta,
				mov.prezzo = tomerge.prezzo,
				mov.ctv = tomerge.ctv,
				mov.data = tomerge.data,
				mov.data_effetto_titolo = tomerge.data_effetto_titolo,
				mov.costo_etf = tomerge.costo_etf	
  	
	WHEN NOT MATCHED THEN 
			INSERT (idrapporto,
					numreg,
					ramo,
					codice_prodotto_universo, 
					numero_polizza,
					c_procedura,
					causale,
					data_carico,
					codicetitolo,
					qta,
					prezzo,
					ctv,
					data,
					data_effetto_titolo,
					costo_etf		
					)
  			VALUES (tomerge.idrapporto,
					tomerge.numreg,
					tomerge.ramo,
					tomerge.codice_prodotto_universo, 
					tomerge.numero_polizza,
					tomerge.c_procedura,
					tomerge.causale,
					tomerge.data_carico,
					tomerge.codicetitolo,
					tomerge.qta,
					tomerge.prezzo,
					tomerge.ctv,
					tomerge.data,
					tomerge.data_effetto_titolo,
					tomerge.costo_etf		
				);
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_INC_FONDO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_INC_FONDO - COMMIT ON ROW: ' || I);
	COMMIT;

	I:=0;
	
	FOR cur_item IN update_f_cancellato
    	LOOP
        I := I+1;
        
        IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE F_CANCELLATO TMP_PFMOV_INC_FONDO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	UPDATE MOVIMENTO_RAMO_TERZO m3
	SET f_cancellato = 'S'
	WHERE cur_item.idrapporto = m3.idrapporto
	AND cur_item.numreg = m3.numreg;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE F_CANCELLATO TMP_PFMOV_INC_FONDO - COMMIT ON ROW: ' || I);
	COMMIT;

END;