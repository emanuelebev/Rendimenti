DECLARE
	
CURSOR scarti_saldi_movimp IS
	SELECT /*+ parallel(8) */ R.codicerapporto AS r_codicerapporto, sf.codicetitolo AS sf_codicetitolo, tmp.ROWID, tmp.* 
	FROM tmp_pfsaldi_movimp tmp
	LEFT JOIN rapporto R
		   ON tmp.codicerapporto = R.codicerapporto
		   AND tmp.codicebanca = R.codicebanca
		   AND tmp.tiporapporto = R.tipo 
	LEFT JOIN strumentofinanziario sf
		ON sf.codicetitolo = tmp.codiceinterno
	WHERE (sf.codicetitolo IS NULL OR R.codicerapporto IS NULL);
	
I 						NUMBER(38,0) :=0;
scarti_codicetitolo 	NUMBER:=0;
scarti_codicerapporto 	NUMBER:=0;
	
	
BEGIN
		
FOR cur_item IN scarti_saldi_movimp
		LOOP 
					
		I := I+1;
		
			IF (cur_item.sf_codicetitolo IS NULL) THEN
				
				INSERT INTO tbl_scarti_tmp_pfsaldi_movimp ( codicebanca,
															codiceagenzia,
															codicerapporto,
															codiceinterno,
															datasaldo,
															tiporapporto,
															datasottoscrizione,
															datascadenza,
															quantita,
															controvalore,
															codicerischio,
															prezzo_medio_carico,
															cambio_medio_carico,
															controvalore_vincolato,
															tmstp,             
															motivo_scarto,     
															riproponibile )
												VALUES (	
															cur_item.codicebanca,
															cur_item.codiceagenzia,
															cur_item.codicerapporto,
															cur_item.codiceinterno,
															cur_item.datasaldo,
															cur_item.tiporapporto,
															cur_item.datasottoscrizione,
															cur_item.datascadenza,
															cur_item.quantita,
															cur_item.controvalore,
															cur_item.codicerischio,
															cur_item.prezzo_medio_carico,
															cur_item.cambio_medio_carico,
															cur_item.controvalore_vincolato,
															sysdate,       
															'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',     
															'S'  );
																
				DELETE /*+ nologging */ FROM tmp_pfsaldi_movimp tmp_del
				WHERE tmp_del.ROWID = cur_item.ROWID;
						
				scarti_codicetitolo := scarti_codicetitolo +1;

		ELSIF (cur_item.r_codicerapporto IS NULL) THEN

					INSERT INTO tbl_scarti_tmp_pfsaldi_movimp ( codicebanca,
															codiceagenzia,
															codicerapporto,
															codiceinterno,
															datasaldo,
															tiporapporto,
															datasottoscrizione,
															datascadenza,
															quantita,
															controvalore,
															codicerischio,
															prezzo_medio_carico,
															cambio_medio_carico,
															controvalore_vincolato,
															tmstp,             
															motivo_scarto,     
															riproponibile )
												VALUES (	
															cur_item.codicebanca,
															cur_item.codiceagenzia,
															cur_item.codicerapporto,
															cur_item.codiceinterno,
															cur_item.datasaldo,
															cur_item.tiporapporto,
															cur_item.datasottoscrizione,
															cur_item.datascadenza,
															cur_item.quantita,
															cur_item.controvalore,
															cur_item.codicerischio,
															cur_item.prezzo_medio_carico,
															cur_item.cambio_medio_carico,
															cur_item.controvalore_vincolato,
    														sysdate,       
															'CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA',     
															'S'
															);
										
					DELETE /*+ nologging */ FROM tmp_pfsaldi_movimp tmp_del
					WHERE tmp_del.ROWID = cur_item.ROWID;
					
					scarti_codicerapporto := scarti_codicerapporto +1;
		END IF;

	IF MOD(I,10000) = 0 THEN
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_MOVIMP PER CHIAVE ESTERNA NON CENSITA - COMMIT ON ROW: '|| I);
			COMMIT; 
	END IF;
			
END LOOP;

INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_MOVIMP PER CHIAVE ESTERNA NON CENSITA. RECORD ELABORATI: '|| I);
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_MOVIMP PER CODICETITOLO NON CENSITO. RECORD SCARTATI: '|| scarti_codicetitolo);
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SCARTI TMP_PFSALDI_MOVIMP PER CODICERAPPORTO NON CENSITO. RECORD SCARTATI: '|| scarti_codicerapporto);
	
COMMIT;

END;