declare

cursor scarti_movimenti_altro is
	 select /*+ parallel(8) */ DISTINCT R.id as idrapporto,
				SF.codicetitolo as codicetitolo,
				p.ROWID,
	      		p.*
	from TMP_PFMOV_SWPRIVATE P
	inner join tbl_bridge X 
		on p.cod_universo = x.cod_universo
        and p.cod_linea = x.cod_linea
	left join strumentofinanziario sf
		on sf.codicetitolo = x.codicetitolo
	left join rapporto R
		on R.codicerapporto = LPAD(trim(P.numero_polizza),12,'0')
		and R.tipo = '13'
	where p.cod_linea is not null
    and (sf.codicetitolo IS NULL OR r.id is null);
		
  I                     	NUMBER(38, 0) := 0;
  SCARTI_IDRAPPORTO		 	NUMBER := 0;
  SCARTI_CODICETITOLO	 	NUMBER := 0;
  
  
  
begin
  
  for cur_item in scarti_movimenti_altro

  LOOP
    I := I + 1;

    if (cur_item.idrapporto is null)
    then
     insert into TBL_SCARTI_TMP_PFMOV_SWPRIVATE (	numero_polizza,
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
										values (	cur_item.numero_polizza,
													cur_item.fondo,
													cur_item.data_nav,
													cur_item.isin,
													cur_item.tipo_movimento,
													cur_item.nav,
													cur_item.quote,
													cur_item.importo,
													SYSDATE,
													'CHIAVE ESTERNA "IDRAPPORTO" NON CENSITA',
													'S',
													cur_item.cod_linea,
													cur_item.data_mov,
													cur_item.cod_universo,
													cur_item.costo_etf
												);
	
	SCARTI_IDRAPPORTO := SCARTI_IDRAPPORTO + 1;	
	
      DELETE FROM TMP_PFMOV_SWPRIVATE DEL_TMP_MOV
      WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
								
	ELSIF (CUR_ITEM.codicetitolo IS NULL) THEN
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
										VALUES (	cur_item.numero_polizza,
													cur_item.fondo,
													cur_item.data_nav,
													cur_item.isin,
													cur_item.tipo_movimento,
													cur_item.nav,
													cur_item.quote,
													cur_item.importo,
													SYSDATE,
													'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
													'S',
													cur_item.cod_linea,
													cur_item.data_mov,
													cur_item.cod_universo,
													cur_item.costo_etf
												);
								
	SCARTI_CODICETITOLO := SCARTI_CODICETITOLO + 1;
	
  DELETE FROM TMP_PFMOV_SWPRIVATE DEL_TMP_MOV
  WHERE DEL_TMP_MOV.ROWID = CUR_ITEM.ROWID;
	
	END IF;
	
    IF MOD(I, 10000) = 0
    THEN
      INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: ' || I);
      COMMIT;
    END IF;

  END LOOP;
  
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE PER CHIAVE ESTERNA NON CENSITA. NUMERO RECORD ELABORATI: '|| I);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE FK NON CENSITA (IDRAPPORTO): ' || SCARTI_IDRAPPORTO);
  INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFMOV_SWPRIVATE FK NON CENSITA (CODICETITOLO): ' || SCARTI_CODICETITOLO);
 
END;