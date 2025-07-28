DECLARE

cursor cerca_mov is 
SELECT
            RAPP.ID                                                                                          AS IDRAPPORTO,
            TMOV.CODICE                                                                                      AS NUMREG,
            TMOV.CAMBIO                                                                                      AS CAMBIO,
            TMOV.TIPORAPPORTO || '_' || TMOV.CAUSALE                                                         AS CAUSALE,
            CASE
            	WHEN TMOV.TIPORAPPORTO = '02' --PER I LIBRETTI IMPOSTARE FISSO A LIQ_EUR_LIB
					THEN NVL(TMOV.CODICEINTERNO,'LIQ_EUR_LIB')
				ELSE TMOV.CODICEINTERNO 
			END                                                                                  AS CODICETITOLO,
            CTVREGOLATO 		                                                                     AS CTV,
            TMOV.CTVREGOLATODIVISA                                                                           AS CTVDIVISA,
            TMOV.CTVMERCATO                                                                                  AS CTVNETTO,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAVALUTA, 'YYYY-MM-DD'), 'YYYYMMDD'))                           AS "DATA",
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATACONTABILE, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS DATACONT,
            CASE 
            	WHEN TMOV.TIPORAPPORTO = '15' --PER  BUONI/FONDI/POLIZZE È FISSA A EUR. PER TITOLI È LA DIVISA DEL PREZZO
            		THEN  (SELECT DIVISA 
            			  FROM SERIE_STORICA 
            			  WHERE CODICETITOLO = TMOV.CODICEINTERNO 
            			  AND DATALIVELLO = (SELECT MAX(DATALIVELLO)
            			  			  		 FROM SERIE_STORICA 
            			  			  		 WHERE CODICETITOLO = TMOV.CODICEINTERNO))
            	ELSE 'EUR'
            END 																							 AS DIVISA,
            NULL                                                                                             AS FLAGPCT,
            TMOV.PREZZO                                                                                      AS PREZZO,
            CASE
            	WHEN TMOV.TIPORAPPORTO = '02' --PER I LIBRETTI INVECE IL CAMPO VA CARICATO CON IL CONTROVALORE REGOLATO
            		THEN TMOV.CTVREGOLATO
            	ELSE 
            		TMOV.QUANTITA
            END																								 AS QTA,
            TMOV.RATEOLORDO                                                                                  AS RATEOLORDO,
            TMOV.RATEONETTO                                                                                  AS RATEONETTO,
            TMOV.COMMISSIONI                                                                                 AS SPESECOMM,
            TMOV.IMPOSTE                                                                                     AS TASSAZIONE,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAVALUTA, 'YYYY-MM-DD'), 'YYYYMMDD'))                           AS VALUTA,
            TMOV.FLAGSTORNO                                                                                  AS STORNO,
            CASE 
            	WHEN (TMOV.TIPORAPPORTO = '03' AND TMOV.CAUSALE = '500')
            		THEN TMOV.CTVREGOLATO
            	ELSE TMOV.CTVMERCATO 
            END	                                                                                             AS CTV_MERCATO,
            TMOV.CTVMERCATODIVISA                                                                            AS CTV_MERCATO_DIVISA,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATACONTABILE, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS DATA_REGISTRAZIONE,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAORDINE, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS DATA_SOTTOSCRIZIONE,
            TMOV.PREZZOMERCATO                                                                               AS PREZZO_MERCATO,
            TMOV.CODICESTORNO                                                                                AS N_OPERAZIONE_STORNO,
            TMOV.FLAGCANCELLATO                                                                              AS F_CANCELLATO,
            NULL                                                                                             AS C_CANALE,
            NULL                                                                                             AS Z_CANALE,
            NULL                                                                                             AS QTA_CAPITALE,
            NULL                                                                                             AS PROVENIENZACAUSALE,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAAGGIORNAMENTO, 'YYYY-MM-DD HH24:MI:SS'),
                              'YYYYMMDDHH24MISS'))                                                           AS D_AGGIORNAMENTO,
            TMOV.TIPORAPPORTO                                                                                AS C_PROCEDURA,
            NULL                                                                                             AS BANCA_DA,
            NULL                                                                                             AS CODICEAGENZIA_DA,
            NULL                                                                                             AS CODICERAPPORTO_DA,
            NULL                                                                                             AS BANCA_A,
            NULL                                                                                             AS CODICEAGENZIA_A,
            NULL                                                                                             AS CODICERAPPORTO_A,
            RAPP.CODICEAGENZIA                                                                               AS CODICEFILIALE,
            CASE 
            	WHEN TMOV.TIPORAPPORTO = '03'
            		THEN SUBSTR(TMOV.CODICERAPPORTO, 0, INSTR(TMOV.CODICERAPPORTO, '-')-1)
            	ELSE NULL
            END 																							 AS CODICERAPPORTO_ORI,
            TMOV.CAUSALE																					 AS CAUSALE_ORI
          FROM
            tmp_pfmov_fondi TMOV
          INNER JOIN RAPPORTO RAPP
          	ON CASE
      		WHEN TMOV.TIPORAPPORTO = '03'
      			THEN SUBSTR(TMOV.CODICERAPPORTO, INSTR(TMOV.CODICERAPPORTO, '-')+1)
      		ELSE
      			TMOV.CODICERAPPORTO 
      		END = RAPP.CODICERAPPORTO
          	AND TMOV.CODICEBANCA = RAPP.CODICEBANCA
          	AND TMOV.TIPORAPPORTO = RAPP.TIPO;

VAR_PERC NUMBER;
I NUMBER(38,0):=0;

BEGIN
	
VAR_PERC := 26/100;

 FOR CUR_ITEM IN cerca_mov
    LOOP
        I := I+1;

	begin
		MERGE   INTO
		    MOVIMENTO MOV
		  USING (select 
				cur_item.IDRAPPORTO          AS IDRAPPORTO,
				cur_item.NUMREG              AS NUMREG,
				cur_item.CAMBIO              AS CAMBIO,
				cur_item.CAUSALE             AS CAUSALE,
				cur_item.CODICETITOLO        AS CODICETITOLO,
				CASE 
			    	WHEN (cur_item.C_PROCEDURA = '03' AND cur_item.CAUSALE = '500') --INTERESSI DEI LIBRETTI
			    		THEN (cur_item.CTV - (cur_item.CTV * VAR_PERC))
			    	ELSE cur_item.CTV 
			   	END	       		     AS CTV,
				cur_item.CTVDIVISA           AS CTVDIVISA,
				cur_item.CTVNETTO            AS CTVNETTO,
				cur_item."DATA"              AS "DATA",
				cur_item.DATACONT            AS DATACONT,
				cur_item.DIVISA              AS DIVISA,
				cur_item.FLAGPCT             AS FLAGPCT,
				cur_item.PREZZO              AS PREZZO,
				cur_item.QTA                 AS QTA,
				cur_item.RATEOLORDO          AS RATEOLORDO,
				cur_item.RATEONETTO          AS RATEONETTO,
				cur_item.SPESECOMM           AS SPESECOMM,
				cur_item.TASSAZIONE          AS TASSAZIONE,
				cur_item.VALUTA              AS VALUTA,
				cur_item.STORNO              AS STORNO,
				cur_item.CTV_MERCATO         AS CTV_MERCATO,
				cur_item.CTV_MERCATO_DIVISA  AS CTV_MERCATO_DIVISA,
				cur_item.DATA_REGISTRAZIONE  AS DATA_REGISTRAZIONE,
				cur_item.DATA_SOTTOSCRIZIONE AS DATA_SOTTOSCRIZIONE,
				cur_item.PREZZO_MERCATO      AS PREZZO_MERCATO,
				cur_item.N_OPERAZIONE_STORNO AS N_OPERAZIONE_STORNO,
				cur_item.F_CANCELLATO        AS F_CANCELLATO,
				cur_item.C_CANALE            AS C_CANALE,
				cur_item.Z_CANALE            AS Z_CANALE,
				cur_item.QTA_CAPITALE        AS QTA_CAPITALE,
				cur_item.PROVENIENZACAUSALE  AS PROVENIENZACAUSALE,
				cur_item.D_AGGIORNAMENTO     AS D_AGGIORNAMENTO,
				cur_item.C_PROCEDURA         AS C_PROCEDURA,
				cur_item.BANCA_DA            AS BANCA_DA,
				cur_item.CODICEAGENZIA_DA    AS CODICEAGENZIA_DA,
				cur_item.CODICERAPPORTO_DA   AS CODICERAPPORTO_DA,
				cur_item.BANCA_A             AS BANCA_A,
				cur_item.CODICEAGENZIA_A     AS CODICEAGENZIA_A,
				cur_item.CODICERAPPORTO_A    AS CODICERAPPORTO_A,
				cur_item.CODICEFILIALE       AS CODICEFILIALE,
				cur_item.CODICERAPPORTO_ORI  AS CODICERAPPORTO_ORI,
				cur_item.CAUSALE_ORI         AS CAUSALE_ORI
			from dual
			  
		       ) TOMERGE
		  ON
		  (MOV.IDRAPPORTO = TOMERGE.IDRAPPORTO
		   AND MOV.NUMREG = TOMERGE.NUMREG)
		  WHEN MATCHED THEN UPDATE
		  SET
		    MOV.CAMBIO = TOMERGE.CAMBIO,
		    MOV.CAUSALE = TOMERGE.CAUSALE,
		    MOV.CODICETITOLO = TOMERGE.CODICETITOLO,
		    MOV.CTV = TOMERGE.CTV,
		    MOV.CTVDIVISA = TOMERGE.CTVDIVISA,
		    MOV.CTVNETTO = TOMERGE.CTVNETTO,
		    MOV."DATA" = TOMERGE."DATA",
		    MOV.DATACONT = TOMERGE.DATACONT,
		    MOV.DIVISA = TOMERGE.DIVISA,
		    MOV.FLAGPCT = TOMERGE.FLAGPCT,
		    MOV.PREZZO = TOMERGE.PREZZO,
		    MOV.QTA = TOMERGE.QTA,
		    MOV.RATEOLORDO = TOMERGE.RATEOLORDO,
		    MOV.RATEONETTO = TOMERGE.RATEONETTO,
		    MOV.SPESECOMM = TOMERGE.SPESECOMM,
		    MOV.TASSAZIONE = TOMERGE.TASSAZIONE,
		    MOV.VALUTA = TOMERGE.VALUTA,
		    MOV.STORNO = TOMERGE.STORNO,
		    MOV.CTV_MERCATO = TOMERGE.CTV_MERCATO,
		    MOV.CTV_MERCATO_DIVISA = TOMERGE.CTV_MERCATO_DIVISA,
		    MOV.DATA_REGISTRAZIONE = TOMERGE.DATA_REGISTRAZIONE,
		    MOV.DATA_SOTTOSCRIZIONE = TOMERGE.DATA_SOTTOSCRIZIONE,
		    MOV.PREZZO_MERCATO = TOMERGE.PREZZO_MERCATO,
		    MOV.N_OPERAZIONE_STORNO = TOMERGE.N_OPERAZIONE_STORNO,
		    MOV.F_CANCELLATO = TOMERGE.F_CANCELLATO,
		    MOV.C_CANALE = TOMERGE.C_CANALE,
		    MOV.Z_CANALE = TOMERGE.Z_CANALE,
		    MOV.QTA_CAPITALE = TOMERGE.QTA_CAPITALE,
		    MOV.PROVENIENZACAUSALE = TOMERGE.PROVENIENZACAUSALE,
		    MOV.D_AGGIORNAMENTO = TOMERGE.D_AGGIORNAMENTO,
		    MOV.C_PROCEDURA = TOMERGE.C_PROCEDURA,
		    MOV.BANCA_DA = TOMERGE.BANCA_DA,
		    MOV.CODICEAGENZIA_DA = TOMERGE.CODICEAGENZIA_DA,
		    MOV.CODICERAPPORTO_DA = TOMERGE.CODICERAPPORTO_DA,
		    MOV.BANCA_A = TOMERGE.BANCA_A,
		    MOV.CODICEAGENZIA_A = TOMERGE.CODICEAGENZIA_A,
		    MOV.CODICERAPPORTO_A = TOMERGE.CODICERAPPORTO_A,
		    MOV.CODICERAPPORTO_ORI = TOMERGE.CODICERAPPORTO_ORI,
		    MOV.CAUSALE_ORI = TOMERGE.CAUSALE_ORI
		  WHEN NOT MATCHED THEN INSERT
		    (IDRAPPORTO,
		     NUMREG,
		     CAMBIO,
		     CAUSALE,
		     CODICETITOLO,
		     CTV,
		     CTVDIVISA,
		     CTVNETTO,
		     DATA,
		     DATACONT,
		     DIVISA,
		     FLAGPCT,
		     PREZZO,
		     QTA,
		     RATEOLORDO,
		     RATEONETTO,
		     SPESECOMM,
		     TASSAZIONE,
		     VALUTA,
		     STORNO,
		     CTV_MERCATO,
		     CTV_MERCATO_DIVISA,
		     DATA_REGISTRAZIONE,
		     DATA_SOTTOSCRIZIONE,
		     PREZZO_MERCATO,
		     N_OPERAZIONE_STORNO,
		     F_CANCELLATO,
		     C_CANALE,
		     Z_CANALE,
		     QTA_CAPITALE,
		     PROVENIENZACAUSALE,
		     D_AGGIORNAMENTO,
		     C_PROCEDURA,
		     BANCA_DA,
		     CODICEAGENZIA_DA,
		     CODICERAPPORTO_DA,
		     BANCA_A,
		     CODICEAGENZIA_A,
		     CODICERAPPORTO_A,
		     CODICERAPPORTO_ORI,
		     CAUSALE_ORI)
		  VALUES (TOMERGE.IDRAPPORTO,
		    TOMERGE.NUMREG,
		    TOMERGE.CAMBIO,
		    TOMERGE.CAUSALE,
		    TOMERGE.CODICETITOLO,
		    TOMERGE.CTV,
		    TOMERGE.CTVDIVISA,
		    TOMERGE.CTVNETTO,
		    TOMERGE.DATA,
		    TOMERGE.DATACONT,
		    TOMERGE.DIVISA,
		    TOMERGE.FLAGPCT,
		    TOMERGE.PREZZO,
		    TOMERGE.QTA,
		    TOMERGE.RATEOLORDO,
		    TOMERGE.RATEONETTO,
		    TOMERGE.SPESECOMM,
		    TOMERGE.TASSAZIONE,
		    TOMERGE.VALUTA,
		    TOMERGE.STORNO,
		    TOMERGE.CTV_MERCATO,
		    TOMERGE.CTV_MERCATO_DIVISA,
		    TOMERGE.DATA_REGISTRAZIONE,
		    TOMERGE.DATA_SOTTOSCRIZIONE,
		    TOMERGE.PREZZO_MERCATO,
		    TOMERGE.N_OPERAZIONE_STORNO,
		    TOMERGE.F_CANCELLATO,
		    TOMERGE.C_CANALE,
		    TOMERGE.Z_CANALE,
		    TOMERGE.QTA_CAPITALE,
		    TOMERGE.PROVENIENZACAUSALE,
		    TOMERGE.D_AGGIORNAMENTO,
		    TOMERGE.C_PROCEDURA,
		    TOMERGE.BANCA_DA,
		    TOMERGE.CODICEAGENZIA_DA,
		    TOMERGE.CODICERAPPORTO_DA,
		    TOMERGE.BANCA_A,
		    TOMERGE.CODICEAGENZIA_A,
		    TOMERGE.CODICERAPPORTO_A,
		    TOMERGE.CODICERAPPORTO_ORI,
		    TOMERGE.CAUSALE_ORI);
	
	exception when others then 
		INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' merge tmp_pfmov_fondi - err per idrapporto: '|| cur_item.idrapporto || ' numreg: ' || cur_item.numreg);
	end;

IF MOD(I,10000) = 0 THEN
		    INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' merge tmp_pfmov_fondi - COMMIT ON ROW: '|| I);
		COMMIT;
		END IF;
	END LOOP;
	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' merge tmp_pfmov_fondi - COMMIT ON ROW: ' || I);
	COMMIT;
end;