DECLARE

CURSOR update_qta IS 
	SELECT /*+ PARALLEL(8) */ mov.idrapporto AS idrapporto,
		mov.numreg AS numreg,
		mov.qta,
		mov.qta - nvl(mov.caricamento,0) - nvl(mov.diritto_fisso,0) - nvl(mov.caricamento,0) - nvl(mov.provv_acquisto,0) - nvl(mov.provv_incasso,0) - nvl(mov.interesse_mora,0) AS qta_new
			FROM tmp_pfmov_inc_coass P
				INNER JOIN rapporto R
					ON R.codicerapporto = lpad(TRIM(P.numero_polizza),12,'0')
					AND R.tipo = '13'
			INNER JOIN movimento_ramo_terzo mov
					ON P.numero_polizza||'_'||P.codice_prodotto||'_'||P.ramo||'_'||P.tipo_titolo||'_'||P.data_valuta||'_'||P.codice_motivo_storno
						||'_'||P.data_carico||'_'||P.data_competenza||'_'||P.data_effetto_titolo = mov.numreg
					AND R.ID = mov.idrapporto;

I NUMBER(38,0):=0;


BEGIN
				
	FOR cur_item IN update_qta
    	LOOP
        I := I+1;

		UPDATE movimento_ramo_terzo mov
		SET mov.qta = cur_item.qta_new
		WHERE mov.idrapporto = cur_item.idrapporto
		AND mov.numreg = cur_item.numreg;
	
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE QTA MOVIMENTO RAMO TERZO INCSSATO - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE QTA MOVIMENTO RAMO TERZO INCSSATO - COMMIT ON ROW: ' || I);
	COMMIT;
END;