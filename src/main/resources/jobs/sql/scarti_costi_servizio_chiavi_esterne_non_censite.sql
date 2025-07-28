DECLARE

CURSOR SCARTI_COSTI_SERV IS
	SELECT /*+ parallel(8) */
			rapp.id   as idrapporto,
			XXX.id    as id_XXX,
			tc.codice,
			tmp.ROWID,
	      	tmp.*
	FROM TMP_PFCOSTI_SERV tmp
	LEFT JOIN RAPPORTO rapp 
      ON rapp.codicebanca = tmp.codicebanca 
        AND substr(rapp.codicerapporto,1,12) = substr(tmp.codicerapporto,1,12)
        AND rapp.tipo = tmp.tiporapporto
	LEFT JOIN TIPO_COSTO tc
		ON tmp.codicebanca = tc.codice_banca
		 AND tmp.codicecosto = tc.codice
	LEFT JOIN rapporto xxx
		ON  xxx.tipo = (CASE WHEN tmp.codicerapporto = '01000000000300000' THEN '14' END)	  	    
		AND tmp.codicecliente = XXX.ndg
	WHERE (rapp.id IS NULL OR tc.codice IS NULL OR XXX.id IS NULL);

I                     	NUMBER(38, 0) := 0;
scarti_idrapporto	 	NUMBER		  := 0;
scarti_tipo_costo		NUMBER		  := 0;

  
BEGIN

	FOR cur_item IN scarti_costi_serv

  		LOOP

    I := I + 1;

    IF (cur_item.idrapporto IS NULL AND cur_item.id_XXX IS NULL) THEN
      INSERT INTO TBL_SCARTI_TMP_PFCOSTI_SERV(	codicebanca,
												codicecliente,
												codicemovimento,
												codicecosto,
												codiceagenzia,
												codicerapporto,
												tiporapporto,
												datacontabile,
												datavaluta,
												datada,
												dataa,
												importo,
												dataaggiornamento,
												tmstp,
												motivo_scarto,
												riproponibile) 
                       VALUES (	cur_item.codicebanca,
								cur_item.codicecliente,
								cur_item.codicemovimento,
								cur_item.codicecosto,
								cur_item.codiceagenzia,
								cur_item.codicerapporto,
								cur_item.tiporapporto,
								cur_item.datacontabile,
								cur_item.datavaluta,
								cur_item.datada,
								cur_item.dataa,
								cur_item.importo,
								cur_item.dataaggiornamento,
								sysdate,
								'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
								'S'
								);
	
	scarti_idrapporto := scarti_idrapporto + 1;	
	
      DELETE FROM TMP_PFCOSTI_SERV del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
								
	ELSIF (cur_item.codice IS NULL)	THEN
	 INSERT INTO TBL_SCARTI_TMP_PFCOSTI_SERV(	codicebanca,
												codicecliente,
												codicemovimento,
												codicecosto,
												codiceagenzia,
												codicerapporto,
												tiporapporto,
												datacontabile,
												datavaluta,
												datada,
												dataa,
												importo,
												dataaggiornamento,
												tmstp,
												motivo_scarto,
												riproponibile) 
                       VALUES (	cur_item.codicebanca,
								cur_item.codicecliente,
								cur_item.codicemovimento,
								cur_item.codicecosto,
								cur_item.codiceagenzia,
								cur_item.codicerapporto,
								cur_item.tiporapporto,
								cur_item.datacontabile,
								cur_item.datavaluta,
								cur_item.datada,
								cur_item.dataa,
								cur_item.importo,
								cur_item.dataaggiornamento,
								sysdate,
								'CHIAVE ESTERNA "CODICE_COSTO" NON CENSITA',
								'S'
								);
								
	scarti_tipo_costo := scarti_tipo_costo + 1;	
	
      DELETE FROM TMP_PFCOSTI_SERV del_tmp_mov
      WHERE del_tmp_mov.ROWID = cur_item.ROWID;
	
	END IF;

    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_SERV PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

	END LOOP;
  
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_SERV PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_SERV FK NON CENSITA (IDRAPPORTO): ' || scarti_idrapporto);
  INSERT INTO output_print_table VALUES (to_number(to_char(sysdate, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFCOSTI_SERV FK NON CENSITA (TIPO_COSTO): ' || scarti_tipo_costo);
  
  COMMIT;
END;