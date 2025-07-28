DECLARE

CURSOR maxdata_sott IS 
	SELECT /*+ PARALLEL(8) */ pol.idptf, BRI.codicetitolo, MAX(DATA) AS DATA
	FROM saldo_rend_sott_pol pol 
	INNER JOIN polizze_sottostanti ps
		ON ps.codicetitolo = pol.codice_universo_pz
	INNER JOIN TBL_BRIDGE BRI
		ON (BRI.cod_universo = sottostante_pz)
	WHERE ramo = '03'
	GROUP BY pol.idptf, BRI.codicetitolo;
	
CURSOR update_maxdata_sott IS 
	SELECT /*+ PARALLEL(8) */ pol.idptf, MAX(DATA) AS DATA_FONDO
	FROM saldo_rend_sott_pol pol 
	INNER JOIN polizze_sottostanti ps
		ON ps.codicetitolo = pol.codice_universo_pz
	INNER JOIN TBL_BRIDGE BRI
		ON (BRI.cod_universo = sottostante_pz)
	WHERE ramo = '03'
	GROUP BY pol.idptf;	
	
I 				NUMBER(38,0):=0;


BEGIN

FOR cur_item IN maxdata_sott
	LOOP
    I := I+1;
	  	
	INSERT INTO MAX_SALDO_REND_SOTT_POL (	idptf,
											codicetitolo,
											data
										)
								VALUES
										(	cur_item.idptf,
											cur_item.codicetitolo,
											cur_item.data
										);
										
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' CARICO MAX_SALDO_REND_SOTT_POL - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' CARICO MAX_SALDO_REND_SOTT_POL - COMMIT ON ROW: ' || I);
	COMMIT;	
	
	
I:=0;
	
FOR cur_item IN update_maxdata_sott
	LOOP
    I := I+1;
	  	
	UPDATE MAX_SALDO_REND_SOTT_POL 
	SET MAXDATA_FONDO = cur_item.DATA_FONDO;
										
	IF MOD(I,10000) = 0 THEN
		    INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE MAX_SALDO_REND_SOTT_POL - COMMIT ON ROW: '|| I);
		COMMIT;
	END IF;
	
	END LOOP;
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' UPDATE MAX_SALDO_REND_SOTT_POL - COMMIT ON ROW: ' || I);
	COMMIT;	
		
END;	