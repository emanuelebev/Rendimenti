declare
    type deletedRows is table of TMP_PFMOV_TITOLI%rowtype;
    delRowsNoRapporto deletedRows;
    delRowsNoCodicetitolo deletedRows;
begin
	loop
		delete TMP_PFMOV_TITOLI t 
		where not exists (select sf.codicetitolo 
				  from STRUMENTOFINANZIARIO sf 
				  where sf.codicetitolo = case
					 		 	when t.tiporapporto = '02'
						      			then nvl(t.codiceinterno,'LIQ_EUR_LIB')
						           	else SUBSTR(T.CODICEINTERNO,2) end) 		
		and rownum < 10000
		returning 
			CODICEBANCA,
			CODICE,
			CODICEAGENZIA,
			CODICERAPPORTO,
			TIPORAPPORTO,
			CODICEINTERNO,
			CAUSALE,
			CTVREGOLATO,
			CTVMERCATO,
			CTVREGOLATODIVISA,
			CTVMERCATODIVISA,
			DIVISA,
			QUANTITA,
			PREZZOMERCATO,
			PREZZO,
			RATEOLORDO,
			RATEONETTO,
			CAMBIO,
			DATAORDINE,
			DATACONTABILE,
			DATAVALUTA,
			FLAGSTORNO,
			CODICESTORNO,
			FLAGCANCELLATO,
			IMPOSTE,
			COMMISSIONI,
			DATAAGGIORNAMENTO,
			GENERATED_CODICERAPPORTO,
			IMPOSTA_REST,
			QUANTITA_DA_SISTEMARE
			bulk collect into delRowsNoCodicetitolo;
			
		if delRowsNoCodicetitolo.count = 0 THEN
			exit;
		else
			forall i in 1..delRowsNoCodicetitolo.count
				INSERT INTO TBL_SCARTI_TMP_PFMOV_TITOLI
					(
						CODICEBANCA,
						CODICE,
						CODICEAGENZIA,
						CODICERAPPORTO,
						TIPORAPPORTO,
						CODICEINTERNO,
						CAUSALE,
						CTVREGOLATO,
						CTVMERCATO,
						CTVREGOLATODIVISA,
						CTVMERCATODIVISA,
						DIVISA,
						QUANTITA,
						PREZZOMERCATO,
						PREZZO,
						RATEOLORDO,
						RATEONETTO,
						CAMBIO,
						DATAORDINE,
						DATACONTABILE,
						DATAVALUTA,
						FLAGSTORNO,
						CODICESTORNO,
						FLAGCANCELLATO,
						IMPOSTE,
						COMMISSIONI,
						DATAAGGIORNAMENTO,
						IMPOSTA_REST,
						QUANTITA_DA_SISTEMARE,
						TMSTP,
						MOTIVO_SCARTO,
						RIPROPONIBILE
					)
					VALUES
					(
						delRowsNoCodicetitolo(i).CODICEBANCA,
						delRowsNoCodicetitolo(i).CODICE,
						delRowsNoCodicetitolo(i).CODICEAGENZIA,
						delRowsNoCodicetitolo(i).CODICERAPPORTO,
						delRowsNoCodicetitolo(i).TIPORAPPORTO,
						delRowsNoCodicetitolo(i).CODICEINTERNO,
						delRowsNoCodicetitolo(i).CAUSALE,
						delRowsNoCodicetitolo(i).CTVREGOLATO,
						delRowsNoCodicetitolo(i).CTVMERCATO,
						delRowsNoCodicetitolo(i).CTVREGOLATODIVISA,
						delRowsNoCodicetitolo(i).CTVMERCATODIVISA,
						delRowsNoCodicetitolo(i).DIVISA,
						delRowsNoCodicetitolo(i).QUANTITA,
						delRowsNoCodicetitolo(i).PREZZOMERCATO,
						delRowsNoCodicetitolo(i).PREZZO,
						delRowsNoCodicetitolo(i).RATEOLORDO,
						delRowsNoCodicetitolo(i).RATEONETTO,
						delRowsNoCodicetitolo(i).CAMBIO,
						delRowsNoCodicetitolo(i).DATAORDINE,
						delRowsNoCodicetitolo(i).DATACONTABILE,
						delRowsNoCodicetitolo(i).DATAVALUTA,
						delRowsNoCodicetitolo(i).FLAGSTORNO,
						delRowsNoCodicetitolo(i).CODICESTORNO,
						delRowsNoCodicetitolo(i).FLAGCANCELLATO,
						delRowsNoCodicetitolo(i).IMPOSTE,
						delRowsNoCodicetitolo(i).COMMISSIONI,
						delRowsNoCodicetitolo(i).DATAAGGIORNAMENTO,
						delRowsNoCodicetitolo(i).IMPOSTA_REST,
						delRowsNoCodicetitolo(i).QUANTITA_DA_SISTEMARE,
						sysdate,
						'CHIAVE ESTERNA "CODICETITOLO" NON CENSITA',
						'S'
					);
		end if;
		INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' INSERT TBL_SCARTI_TMP_PFMOV_TITOLI CHIAVE ESTERNA "CODICETITOLO" NON CENSITA');
		commit;
	end loop;
	
	commit;
	
	execute immediate 'TRUNCATE TABLE TMP_PFMOV_TITOLI_DEL';
	
	insert into TMP_PFMOV_TITOLI_DEL
	select distinct CODICERAPPORTO from TMP_PFMOV_TITOLI t where not exists (select r.codicerapporto 
					  from rapporto r
					  where r.codicerapporto = t.CODICERAPPORTO);

	commit;

	loop
		delete TMP_PFMOV_TITOLI t 
		where CODICERAPPORTO IN (select GENERATED_CODICERAPPORTO from TMP_PFMOV_TITOLI_DEL)
			and rownum < 10000
		returning 
			CODICEBANCA,
			CODICE,
			CODICEAGENZIA,
			CODICERAPPORTO,
			TIPORAPPORTO,
			CODICEINTERNO,
			CAUSALE,
			CTVREGOLATO,
			CTVMERCATO,
			CTVREGOLATODIVISA,
			CTVMERCATODIVISA,
			DIVISA,
			QUANTITA,
			PREZZOMERCATO,
			PREZZO,
			RATEOLORDO,
			RATEONETTO,
			CAMBIO,
			DATAORDINE,
			DATACONTABILE,
			DATAVALUTA,
			FLAGSTORNO,
			CODICESTORNO,
			FLAGCANCELLATO,
			IMPOSTE,
			COMMISSIONI,
			DATAAGGIORNAMENTO,
			GENERATED_CODICERAPPORTO,
			IMPOSTA_REST,
			QUANTITA_DA_SISTEMARE
			bulk collect into delRowsNoRapporto;
		
		if delRowsNoRapporto.count = 0 THEN
			exit;
		else
		forall i in 1..delRowsNoRapporto.count
			INSERT INTO TBL_SCARTI_TMP_PFMOV_TITOLI
				(
						CODICEBANCA,
						CODICE,
						CODICEAGENZIA,
						CODICERAPPORTO,
						TIPORAPPORTO,
						CODICEINTERNO,
						CAUSALE,
						CTVREGOLATO,
						CTVMERCATO,
						CTVREGOLATODIVISA,
						CTVMERCATODIVISA,
						DIVISA,
						QUANTITA,
						PREZZOMERCATO,
						PREZZO,
						RATEOLORDO,
						RATEONETTO,
						CAMBIO,
						DATAORDINE,
						DATACONTABILE,
						DATAVALUTA,
						FLAGSTORNO,
						CODICESTORNO,
						FLAGCANCELLATO,
						IMPOSTE,
						COMMISSIONI,
						DATAAGGIORNAMENTO,
						IMPOSTA_REST,
						QUANTITA_DA_SISTEMARE,
						TMSTP,
						MOTIVO_SCARTO,
						RIPROPONIBILE
				)
				VALUES
				(
					delRowsNoRapporto(i).CODICEBANCA,
					delRowsNoRapporto(i).CODICE,
					delRowsNoRapporto(i).CODICEAGENZIA,
					delRowsNoRapporto(i).CODICERAPPORTO,
					delRowsNoRapporto(i).TIPORAPPORTO,
					delRowsNoRapporto(i).CODICEINTERNO,
					delRowsNoRapporto(i).CAUSALE,
					delRowsNoRapporto(i).CTVREGOLATO,
					delRowsNoRapporto(i).CTVMERCATO,
					delRowsNoRapporto(i).CTVREGOLATODIVISA,
					delRowsNoRapporto(i).CTVMERCATODIVISA,
					delRowsNoRapporto(i).DIVISA,
					delRowsNoRapporto(i).QUANTITA,
					delRowsNoRapporto(i).PREZZOMERCATO,
					delRowsNoRapporto(i).PREZZO,
					delRowsNoRapporto(i).RATEOLORDO,
					delRowsNoRapporto(i).RATEONETTO,
					delRowsNoRapporto(i).CAMBIO,
					delRowsNoRapporto(i).DATAORDINE,
					delRowsNoRapporto(i).DATACONTABILE,
					delRowsNoRapporto(i).DATAVALUTA,
					delRowsNoRapporto(i).FLAGSTORNO,
					delRowsNoRapporto(i).CODICESTORNO,
					delRowsNoRapporto(i).FLAGCANCELLATO,
					delRowsNoRapporto(i).IMPOSTE,
					delRowsNoRapporto(i).COMMISSIONI,
					delRowsNoRapporto(i).DATAAGGIORNAMENTO,
					delRowsNoRapporto(i).IMPOSTA_REST,
					delRowsNoRapporto(i).QUANTITA_DA_SISTEMARE,
					sysdate,
					'CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA',
					'S'
				);
		end if;
		INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' INSERT TBL_SCARTI_TMP_PFMOV_TITOLI CHIAVE ESTERNA "CODICERAPPORTO" NON CENSITA');
		commit;
	end loop;
	
	commit;
	
	  INSERT INTO CAUSALE (	  CODICECAUSALE,
                                  CAUCONTR,
                                  DATAAGGIORNAMENTO,
                                  DATAINSERIMENTO,
                                  DESCRIZIONE,
                                  FLAGAGGSALDI,
                                  SEGNO,
                                  TIPOCAUSALE,
                                  SOTL,
                                  CODICEBANCA,
                                  CANALE,
                                  TIPOLOGIA_CAUSALE,
                                  CODICECAUSALE_ORI)
               SELECT DISTINCT
               	 t.TIPORAPPORTO || '_' || t.CAUSALE, --CODICECAUSALE
                 NULL,  --CAUCONTR
                 NULL, --DATAAGGIORNAMENTO
                 TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')), --DATAINSERIMENTO
                 t.CAUSALE, --DESCRIZIONE
                 '1', --FLAGAGGSALDI
                 NULL, --SEGNO
                 '4', --TIPOCAUSALE
                 null, --SOTL
                 '07601', --CODICEBANCA
	         t.tiporapporto, --CANALE
                 CASE --TIPOLOGIA_CAUSALE
                 WHEN (t.QUANTITA IS NOT NULL AND t.QUANTITA > 0)
                   THEN 'VER'
                 WHEN (t.QUANTITA IS NOT NULL AND t.QUANTITA < 0)
                   THEN 'PREL'
                 WHEN (t.QUANTITA IS NULL AND t.CTVREGOLATO < 0)
                   THEN 'PREL'
                 WHEN (t.QUANTITA IS NULL AND t.CTVREGOLATO > 0)
                   THEN 'VER'
                 END,
                 t.causale --CODICECAUSALE_ORI
               FROM TMP_PFMOV_TITOLI t
               WHERE NOT EXISTS
               (SELECT 1
                FROM CAUSALE c
                WHERE c.CODICECAUSALE = t.TIPORAPPORTO || '_' || t.CAUSALE);
   
    commit;                        
end;