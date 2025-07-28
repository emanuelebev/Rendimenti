DECLARE

CURSOR movimenti IS
	SELECT
            rapp.ID                                                                                          AS idrapporto,
            tmov.codice                                                                                      AS numreg,
            tmov.cambio                                                                                      AS cambio,
            tmov.tiporapporto || '_' || tmov.causale                                                         AS causale,
            CASE
            	WHEN tmov.tiporapporto = '02' --PER I LIBRETTI IMPOSTARE FISSO A LIQ_EUR_LIB
					THEN nvl(tmov.codiceinterno,'LIQ_EUR_LIB')
				ELSE tmov.codiceinterno 
			END                                                                               				 AS codicetitolo,
            CASE WHEN (tmov.tiporapporto = '03' AND tmov.ctvregolato < 0) 
            			THEN (tmov.ctvregolato - tmov.imposte - tmov.commissioni)
            	 WHEN (tmov.tiporapporto = '03' AND tmov.ctvregolato >= 0) 
            			THEN (tmov.ctvregolato - tmov.imposte + tmov.commissioni)
            	ELSE tmov.ctvregolato END																	 AS ctv,  	 --(PTR-214)
            CASE WHEN tmov.tiporapporto = '03' THEN tmov.ctvregolato END  									 AS ctvorig, --(PTR-214)
            tmov.ctvregolatodivisa                                                                           AS ctvdivisa,
            tmov.ctvmercato                                                                                  AS ctvnetto,
            CASE 
            	WHEN tmov.tiporapporto = '14' --PER I FONDI (PTR-176)
            		THEN to_number(to_char(TO_DATE(tmov.datacontabile, 'YYYY-MM-DD'), 'YYYYMMDD'))
            	WHEN tmov.tiporapporto = '97' --PER I FONDI ESTERNI (PTR-805)
            		THEN to_number(to_char(TO_DATE(tmov.datacontabile, 'YYYY-MM-DD'), 'YYYYMMDD'))
            	WHEN tmov.tiporapporto = '03' --PER I BFP (PTR-257)
            		THEN to_number(to_char(TO_DATE(tmov.datacontabile, 'YYYY-MM-DD'), 'YYYYMMDD'))
            	ELSE to_number(to_char(TO_DATE(tmov.datavaluta, 'YYYY-MM-DD'), 'YYYYMMDD')) END			 	 AS "DATA",
            to_number(to_char(TO_DATE(tmov.datacontabile, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS datacont,
            CASE 
            	WHEN tmov.tiporapporto = '15' --PER BUONI/FONDI/POLIZZE È FISSA A EUR. PER TITOLI È LA DIVISA DEL PREZZO
            		THEN  (SELECT divisa 
            			  FROM serie_storica 
            			  WHERE codicetitolo = tmov.codiceinterno 
            			  AND datalivello = (SELECT MAX(datalivello)
            			  			  		 FROM serie_storica 
            			  			  		 WHERE codicetitolo = tmov.codiceinterno))
            	ELSE 'EUR'
            END 																							 AS divisa,
            NULL                                                                                             AS flagpct,
            tmov.prezzo                                                                                      AS prezzo,
            CASE
            	WHEN tmov.tiporapporto = '02' --PER I LIBRETTI INVECE IL CAMPO VA CARICATO CON IL CONTROVALORE REGOLATO
            		THEN tmov.ctvregolato
            	ELSE 
            		tmov.quantita
            END																								 AS qta,
            tmov.rateolordo                                                                                  AS rateolordo,
            tmov.rateonetto                                                                                  AS rateonetto,
            tmov.commissioni                                                                                 AS spesecomm,
            tmov.imposte                                                                                     AS tassazione,
            to_number(to_char(TO_DATE(tmov.datavaluta, 'YYYY-MM-DD'), 'YYYYMMDD'))                           AS valuta,
            tmov.flagstorno                                                                                  AS storno,
            tmov.ctvmercato                                                                                  AS ctv_mercato,
            tmov.ctvmercatodivisa                                                                            AS ctv_mercato_divisa,
            to_number(to_char(TO_DATE(tmov.datacontabile, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS data_registrazione,
            to_number(to_char(TO_DATE(tmov.dataordine, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS data_sottoscrizione,
            tmov.prezzomercato                                                                               AS prezzo_mercato,
            tmov.codicestorno                                                                                AS n_operazione_storno,
            tmov.flagcancellato                                                                              AS f_cancellato,
            NULL                                                                                             AS c_canale,
            NULL                                                                                             AS z_canale,
            NULL                                                                                             AS qta_capitale,
            NULL                                                                                             AS provenienzacausale,
            to_number(to_char(TO_DATE(tmov.dataaggiornamento, 'YYYY-MM-DD HH24:MI:SS'),
                              'YYYYMMDDHH24MISS'))                                                           AS d_aggiornamento,
            tmov.tiporapporto                                                                                AS c_procedura,
            NULL                                                                                             AS banca_da,
            NULL                                                                                             AS codiceagenzia_da,
            NULL                                                                                             AS codicerapporto_da,
            NULL                                                                                             AS banca_a,
            NULL                                                                                             AS codiceagenzia_a,
            NULL                                                                                             AS codicerapporto_a,
            rapp.codiceagenzia                                                                               AS codicefiliale,
            CASE 
            	WHEN tmov.tiporapporto = '03'
            		THEN substr(tmov.codicerapporto, 0, instr(tmov.codicerapporto, '-')-1)
            	ELSE NULL
            END 																							 AS codicerapporto_ori,
            tmov.causale																					 AS causale_ori
          FROM
            tmp_pfmovimenti tmov
          INNER JOIN rapporto rapp
          	ON tmov.codicerapporto = rapp.codicerapporto
          	AND tmov.codicebanca = rapp.codicebanca
          	AND tmov.tiporapporto = rapp.tipo;
          	
TYPE movimenti_type IS TABLE OF movimenti%rowtype INDEX BY PLS_INTEGER;

res_movimenti movimenti_type;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;
totale	NUMBER(38,0):=0;
          	
BEGIN
							
		OPEN movimenti;
		LOOP
			FETCH movimenti BULK COLLECT INTO res_movimenti LIMIT ROWS;
				EXIT WHEN res_movimenti.COUNT = 0;  
			
			I:=0;
			I:= res_movimenti.COUNT;
			totale := totale + I;
				
		FORALL j IN res_movimenti.FIRST .. res_movimenti.LAST		

			INSERT /*+ APPEND */ INTO movimento (idrapporto,
											     numreg,
											     cambio,
											     causale,
											     codicetitolo,
											     ctv,
											     ctvorig,
											     ctvdivisa,
											     ctvnetto,
											     DATA,
											     datacont,
											     divisa,
											     flagpct,
											     prezzo,
											     qta,
											     rateolordo,
											     rateonetto,
											     spesecomm,
											     tassazione,
											     valuta,
											     storno,
											     ctv_mercato,
											     ctv_mercato_divisa,
											     data_registrazione,
											     data_sottoscrizione,
											     prezzo_mercato,
											     n_operazione_storno,
											     f_cancellato,
											     c_canale,
											     z_canale,
											     qta_capitale,
											     provenienzacausale,
											     d_aggiornamento,
											     c_procedura,
											     banca_da,
											     codiceagenzia_da,
											     codicerapporto_da,
											     banca_a,
											     codiceagenzia_a,
											     codicerapporto_a,
											     codicerapporto_ori,
											     causale_ori)
											  VALUES (	res_movimenti(j).idrapporto,
													    res_movimenti(j).numreg,
													    res_movimenti(j).cambio,
													    res_movimenti(j).causale,
													    res_movimenti(j).codicetitolo,
													    res_movimenti(j).ctv,
													    res_movimenti(j).ctvorig,
													    res_movimenti(j).ctvdivisa,
													    res_movimenti(j).ctvnetto,
													    res_movimenti(j).DATA,
													    res_movimenti(j).datacont,
													    res_movimenti(j).divisa,
													    res_movimenti(j).flagpct,
													    res_movimenti(j).prezzo,
													    res_movimenti(j).qta,
													    res_movimenti(j).rateolordo,
													    res_movimenti(j).rateonetto,
													    res_movimenti(j).spesecomm,
													    res_movimenti(j).tassazione,
													    res_movimenti(j).valuta,
													    res_movimenti(j).storno,
													    res_movimenti(j).ctv_mercato,
													    res_movimenti(j).ctv_mercato_divisa,
													    res_movimenti(j).data_registrazione,
													    res_movimenti(j).data_sottoscrizione,
													    res_movimenti(j).prezzo_mercato,
													    res_movimenti(j).n_operazione_storno,
													    res_movimenti(j).f_cancellato,
													    res_movimenti(j).c_canale,
													    res_movimenti(j).z_canale,
													    res_movimenti(j).qta_capitale,
													    res_movimenti(j).provenienzacausale,
													    res_movimenti(j).d_aggiornamento,
													    res_movimenti(j).c_procedura,
													    res_movimenti(j).banca_da,
													    res_movimenti(j).codiceagenzia_da,
													    res_movimenti(j).codicerapporto_da,
													    res_movimenti(j).banca_a,
													    res_movimenti(j).codiceagenzia_a,
													    res_movimenti(j).codicerapporto_a,
													    res_movimenti(j).codicerapporto_ori,
													    res_movimenti(j).causale_ori);
    
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' INSERT MOVIMENTI - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
	CLOSE movimenti;
	
	INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' INSERT MOVIMENTI - COMMIT ON ROW: ' || totale);
		COMMIT;
		
	BEGIN
		dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'MOVIMENTO', degree => 4, estimate_percent=>10, cascade=>true); 
	END;
END;